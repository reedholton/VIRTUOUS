// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:virtuetracker/api/auth.dart';
import 'package:virtuetracker/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtue Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignUpPage(),
    );
  }
}

void callAuthCreateAccount(email, password, fullName) {
  final Auth auth = Auth();
  String emailInput = email.text;
  String fullNameInput = fullName.text;
  String passwordInput = password.text;

  try {
    if (emailInput.isNotEmpty &&
        fullNameInput.isNotEmpty &&
        passwordInput.isNotEmpty) {
      auth
          .createAccount(emailInput, passwordInput, fullNameInput)
          .then((response) => {
        // user has been created in authentication.
        print("success")
      })
          .catchError((error) => {
        // you can show error in message to user
        print(error)
      });
    } else {
      // Show user error and remind them to fill out fields.
    }
  } catch (error) {
    print(error);
  }
}

class SignUpPage extends StatelessWidget {
  TextEditingController email = TextEditingController();
  TextEditingController fullName = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDF9),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Placeholder for the logo
              Image(
                image:
                const AssetImage("assets/images/virtuous_circle_outline.png"),
                height: 100,
              ),
              Text(
                'Your journey starts with just one entry',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15.0),
              ),
              SizedBox(height: 20.0),
              // Email input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              // Full Name input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  controller: fullName,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              // Password input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
                    prefixIcon: Icon(
                      Icons.fingerprint_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              // // Phone Number input field
              // TextField(
              //   decoration: InputDecoration(
              //     labelText: 'Phone Number',
              //     labelStyle:
              //         TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              //     prefixIcon: Icon(Icons.phone),
              //   ),
              //   keyboardType: TextInputType.phone,
              // ),
              SizedBox(height: 20.0),
              // Sign Up button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: ElevatedButton(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    backgroundColor: Color(0xFFC5B898),
                    padding: EdgeInsets.symmetric(vertical: 25.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    shadowColor: Colors.black,
                  ),
                  onPressed: () {
                    // Redirect to Survey or Verify Email page after calling function
                    callAuthCreateAccount(email, password, fullName);
                  },
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black, fontWeight: FontWeight.w400) ),
                  TextButton(
                    child: const Text('Sign In',
                        style: TextStyle(decoration: TextDecoration.underline, fontStyle: FontStyle.italic, color: Colors.black, fontWeight: FontWeight.w400)),
                    onPressed: () {
                      // Redirect to Sign Up page
                    },
                  ),
                ],
              ),

              SizedBox(height: 150),
              Text(
                'We Value Your Privacy\nBy signing up, you agree to our Terms and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}