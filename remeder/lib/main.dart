import 'package:flutter/material.dart';

void main() {
  // Entry point of the application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the theme colors for the app
    final primaryColor = Color(0xFF6ECCAF); // Light mint green
    final accentColor = Color(0xFFAED9E0);  // Light blue

    // Print statement for debugging
    print("Building MyApp widget");

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      title: 'reMEDer',
      // Set up the theme with light, friendly colors
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
        ),
        fontFamily: 'Montserrat',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      home: LoginScreen(), // Set the login screen as the home page
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Variable to track loading state
  bool _isLoading = false;

  // Placeholder function for Google Sign-In
  // We'll implement the actual authentication later
  void _handleSignIn() {
    // Debug print
    print("Sign-in button pressed");

    setState(() {
      _isLoading = true;
    });

    // Simulate authentication delay
    Future.delayed(Duration(seconds: 2), () {
      // Debug print
      print("Moving to introduction page");

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Navigate to introduction page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => IntroductionPage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final size = MediaQuery.of(context).size;

    // Debug print
    print("Building LoginScreen widget");

    return Scaffold(
      // Use a light background color
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo
                  // If you don't have a logo yet, use a placeholder
                  Image.asset(
                    'assets/logo.png', // Make sure to add your logo to the assets folder
                    height: size.height * 0.2,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading logo: $error");
                      return Icon(
                        Icons.medical_services,
                        size: size.height * 0.2,
                        color: Theme.of(context).primaryColor,
                      );
                    },
                  ),
                  SizedBox(height: 30),

                  // Welcome text
                  Text(
                    'Hello! Welcome to reMEDer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),

                  // Subtitle text
                  Text(
                    'Your personal medication reminder assistant',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50),

                  // Google Sign-In button (placeholder for now)
                  _isLoading
                      ? CircularProgressIndicator() // Show loading indicator when signing in
                      : ElevatedButton.icon(
                    icon: Icon(Icons.login),
                    label: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    onPressed: _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Additional information text
                  Text(
                    'By signing in, you agree to our Terms of Service and Privacy Policy',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class IntroductionPage extends StatefulWidget {
  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  // Controllers for the text fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // Function to handle form submission
  void _handleContinue() {
    // Debug print
    print("Continue button pressed");

    // Validate the form
    if (_formKey.currentState!.validate()) {
      print("Form is valid");
      print("Name: ${_nameController.text}");
      print("Age: ${_ageController.text}");

      // Navigate to permissions page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PermissionsPage(),
        ),
      );
    } else {
      print("Form is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug print
    print("Building IntroductionPage widget");

    return Scaffold(
      appBar: AppBar(
        title: Text('Tell us about yourself'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'We need some basic information to personalize your experience',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 30),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Age field
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Your Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),

                // Continue button
                ElevatedButton(
                  onPressed: _handleContinue,
                  child: Text(
                    'Continue',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class PermissionsPage extends StatefulWidget {
  @override
  _PermissionsPageState createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  // Permission status variables
  bool _notificationsGranted = false;
  bool _cameraGranted = false;

  // Function to request notification permissions
  // This is just a placeholder for now
  void _requestNotificationPermission() {
    // Debug print
    print("Requesting notification permission");

    setState(() {
      _notificationsGranted = true;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification permission granted')),
    );
  }

  // Function to request camera permissions
  // This is just a placeholder for now
  void _requestCameraPermission() {
    // Debug print
    print("Requesting camera permission");

    setState(() {
      _cameraGranted = true;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Camera permission granted')),
    );
  }

  // Function to handle completion
  void _handleComplete() {
    // Debug print
    print("Complete button pressed");
    print("Notifications granted: $_notificationsGranted");
    print("Camera granted: $_cameraGranted");

    // Navigate to home page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug print
    print("Building PermissionsPage widget");

    return Scaffold(
      appBar: AppBar(
        title: Text('App Permissions'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'We need a few permissions to provide you with the best experience',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 30),

              // Notification permission card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Allow notifications to receive medicine reminders',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _notificationsGranted ? null : _requestNotificationPermission,
                        child: Text(_notificationsGranted ? 'Granted' : 'Allow'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _notificationsGranted ? Colors.grey : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Camera permission card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Camera',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Allow camera access to scan medicine labels',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _cameraGranted ? null : _requestCameraPermission,
                        child: Text(_cameraGranted ? 'Granted' : 'Allow'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _cameraGranted ? Colors.grey : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),

              // Complete button
              ElevatedButton(
                onPressed: _handleComplete,
                child: Text(
                  'Complete Setup',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Debug print
    print("Building HomePage widget");

    return Scaffold(
      appBar: AppBar(
        title: Text('reMEDer'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Setup Complete!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You\'re all set to start using reMEDer',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Add Your First Medication'),
              onPressed: () {
                print("Add medication button pressed");
                // This would navigate to a medication entry form in a real app
              },
            ),
          ],
        ),
      ),
    );
  }
}


