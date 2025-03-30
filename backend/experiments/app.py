import streamlit as st
import json
import datetime
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
import os.path
import pytz

NY_TZ = pytz.timezone('America/New_York')
time_slots = {
    'morning': datetime.time(8, 0),  # 8:00 AM
    'afternoon': datetime.time(13, 0),  # 1:00 PM
    'evening': datetime.time(18, 0),  # 6:00 PM
    'night': datetime.time(22, 0)  # 10:00 PM
}

SCOPES = ['https://www.googleapis.com/auth/calendar']

def get_calendar_service():
    """Set up and return Google Calendar API service"""
    creds = None
    
    # Check for existing token
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_info(json.load(open('token.json')))
    
    # If credentials don't exist or are invalid
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        
        # Save credentials for next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())
    
    return build('calendar', 'v3', credentials=creds)

def parse_frequency(freq):
    """Parse medication frequency into appropriate time slots"""
    parts = freq.split('-')
    doses = [float(part) for part in parts]
    
    # Handle different frequency formats:
    # 3-part format (1-0-1) means morning-afternoon-night
    # 4-part format (1-1-1-1) means morning-afternoon-evening-night
    if len(parts) == 3:
        # Map to morning, afternoon, night (no evening)
        slot_mapping = ['morning', 'afternoon', 'night']
        result = []
        for i, slot in enumerate(['morning', 'afternoon', 'evening', 'night']):
            if slot == 'evening':
                result.append((slot, 0))  # No dose for evening in 3-part format
            else:
                # Find the correct index in the 3-part dose
                index = slot_mapping.index(slot) if slot in slot_mapping else -1
                result.append((slot, doses[index] if index >= 0 else 0))
        return result
    else:
        # For 4-part format or any other format, pad with zeros to get 4 values
        while len(doses) < 4:
            doses.append(0)
        doses = doses[:4]  # Take only the first 4 values
        
        return list(zip(['morning', 'afternoon', 'evening', 'night'], doses))

def create_medicine_reminders_batch(medicine_data):
    """Create Google Calendar events for medicine reminders using batch requests"""
    service = get_calendar_service()
    
    # Get today's date as the start date
    today = datetime.datetime.now(NY_TZ).date()
    
    # Create a batch request object
    batch = service.new_batch_http_request()
    
    # Counter for tracking the number of events in the current batch
    event_count = 0
    max_batch_size = 50  # Google recommends not exceeding 50 requests per batch
    
    # Function to execute the current batch and start a new one
    def execute_batch_and_create_new():
        nonlocal batch, event_count
        print(f"Executing batch with {event_count} events...")
        batch.execute()
        batch = service.new_batch_http_request()
        event_count = 0
    
    for medicine in medicine_data:
        med_name = medicine["medicine"]
        special_instr = medicine["special_instructions"]
        
        # Parse duration (assume format is "X days")
        duration_days = int(medicine["duration"].split()[0])
        
        # Parse the frequency to determine when to take the medicine
        slot_doses = parse_frequency(medicine["frequency"])
        
        # For each time slot with a non-zero dose
        for slot_name, dose in slot_doses:
            if dose > 0:
                # Create events for each day of the duration
                for day in range(duration_days):
                    event_date = today + datetime.timedelta(days=day)
                    
                    # Get the time for this slot
                    slot_time = time_slots[slot_name]
                    
                    # Create start and end datetime
                    start_datetime = datetime.datetime.combine(event_date, slot_time).replace(tzinfo=NY_TZ)
                    end_datetime = start_datetime + datetime.timedelta(minutes=15)
                    
                    # Format dose text properly
                    if dose == 0.5:
                        dose_text = "half a tablet"
                    elif dose == 1:
                        dose_text = "1 tablet"
                    else:
                        dose_text = f"{dose} tablets"
                    
                    event = {
                        'summary': f"Take {med_name}",
                        'description': f"Take {dose_text} of {med_name}. {special_instr}",
                        'start': {
                            'dateTime': start_datetime.isoformat(),
                            'timeZone': 'America/New_York',
                        },
                        'end': {
                            'dateTime': end_datetime.isoformat(),
                            'timeZone': 'America/New_York',
                        },
                        'reminders': {
                            'useDefault': False,
                            'overrides': [
                                {'method': 'popup', 'minutes': 15},
                            ],
                        },
                    }
                    
                    # Add the event creation request to the batch
                    callback = lambda id, resp, exc: None  # Simple callback that does nothing
                    batch.add(service.events().insert(calendarId='primary', body=event), callback=callback)
                    event_count += 1
                    
                    # If we've reached max batch size, execute the batch and create a new one
                    if event_count >= max_batch_size:
                        execute_batch_and_create_new()
    
    # Execute any remaining requests in the final batch
    if event_count > 0:
        print(f"Executing final batch with {event_count} events...")
        batch.execute()
    
    print("All medicine reminders have been scheduled successfully!")

def delete_medicine_reminders_batch():
    """Delete all medicine reminder events using batch requests"""
    service = get_calendar_service()
    
    # Get current time in New York timezone
    now = datetime.datetime.now(NY_TZ)
    
    # Set time range to look for events (past 30 days to next 30 days)
    time_min = (now - datetime.timedelta(days=1)).isoformat()
    time_max = (now + datetime.timedelta(days=30)).isoformat()
    
    # Search for events with "Take" in the summary
    events_result = service.events().list(
        calendarId='primary',
        timeMin=time_min,
        timeMax=time_max,
        q="Take",  # Search for events with "Take" in the title
        singleEvents=True,
        orderBy='startTime',
        maxResults=2500  # Get up to 2500 events at once
    ).execute()
    
    events = events_result.get('items', [])
    
    if not events:
        print("No medicine reminder events found.")
        return
    
    # Create a batch request object
    batch = service.new_batch_http_request()
    event_count = 0
    max_batch_size = 50
    
    # Function to execute the current batch and start a new one
    def execute_batch_and_create_new():
        nonlocal batch, event_count
        print(f"Executing deletion batch with {event_count} events...")
        batch.execute()
        batch = service.new_batch_http_request()
        event_count = 0
    
    deleted_count = 0
    for event in events:
        # Verify it's a medicine reminder by checking the summary
        if 'summary' in event and event['summary'].startswith('Take'):
            # Add deletion request to batch
            callback = lambda id, resp, exc: None
            batch.add(service.events().delete(calendarId='primary', eventId=event['id']), callback=callback)
            event_count += 1
            deleted_count += 1
            
            # If we've reached max batch size, execute the batch and create a new one
            if event_count >= max_batch_size:
                execute_batch_and_create_new()
    
    # Execute any remaining requests in the final batch
    if event_count > 0:
        print(f"Executing final deletion batch with {event_count} events...")
        batch.execute()
    
    print(f"Successfully deleted {deleted_count} medicine reminder events.")

if not st.experimental_user.is_logged_in:
    if st.button("Log in"):
        st.login()
else:
    if st.button("Log out"):
        st.logout()
    st.write(f"Hello, {st.experimental_user.name}!")
    
    medicine_data = st.text_area("Enter some text")
    if st.button("Submit"):
        medicine_data = json.loads(medicine_data)
        create_medicine_reminders_batch(medicine_data)
        st.success("Reminders created successfully!")

    if st.button("Clear Calendar"):
        try:
            delete_medicine_reminders_batch()
            st.success("All reminders cleared successfully!")
        except Exception as e:
            st.error(f"An error occurred: {e}")