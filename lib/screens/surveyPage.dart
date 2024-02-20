import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtuetracker/api/users.dart';
import 'package:virtuetracker/controllers/surveyPageController.dart';
import 'package:virtuetracker/widgets/toastNotificationWidget.dart';

// Color palette
const Color appBarColor = Color(0xFFC4DFD3);
const Color mainBackgroundColor = Color(0xFFF3E8D2);
const Color buttonColor = Color(0xFFCEC0A1);
const Color bottomNavBarColor = Color(0xFFA6A1CC);
const Color iconColor = Color(0xFF000000);
const Color textColor = Colors.white;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SurveyPage(),
    );
  }
}

class SurveyPage extends StatefulWidget {
  @override
  SurveyPageState createState() => SurveyPageState();
}

class SurveyPageState extends State<SurveyPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  ToastNotificationWidget toast = ToastNotificationWidget();

  // Text editing controllers for each TextField
  TextEditingController careerPosition = TextEditingController();
  TextEditingController careerLength = TextEditingController();
  TextEditingController reasons = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController notificationTime = TextEditingController();
  // Phone verification
  bool phoneVerified = false;
  // Location of user
  GeoPoint? userLocation;
  // Selected values for dropdowns
  String currentCommunity = 'Legal';
  String shareEntries = 'No';
  String shareLocation = 'No';
  String allowNotifications = 'No';

  String formattedPhoneNumber = '';

  // Dropdown values for each page
  List<String> careerDropdownValues = [
    'Legal',
    'Education',
    'Technology',
    'Healthcare'
  ];
  List<String> yesNoDropdownValues = ['Yes', 'No'];

  // List to store answers
  List<String> answers = ['', '', '', '', '', '', '', '', ''];

  bool _shouldShowContent = false;
  TimeOfDay? selectedTime;

// bool _shouldShowContent = false; // Declare _shouldShowContent here

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Set initial values for text fields
    careerPosition.text = '';
    careerLength.text = '';
    reasons.text = '';
    phoneNumber.text = '';
    phoneNumber.addListener(_formatPhoneNumberOnType);
    notificationTime.text = '';
  }

  void showToasty(msg, bool success, BuildContext context) {
    print('calling toast widget');
    toast.successOrError(context, msg, success);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      // Watches survey page controller, and updates fields whenever we run api calls, like location and sumbit survey info.
      ref.watch(surveyPageControllerProvider).when(
            loading: () => CircularProgressIndicator(),
            error: (error, stackTrace) {
              Future.delayed(Duration.zero, () {
                showToasty(error.toString(), false, context);
              });
            },
            data: (response) async {
              // If response is location and not string then update userLocation
              if (response is GeoPoint) {
                print('User Location : $response');
                userLocation = response;
                return;
              }
              print("What is the response survey: $response");
              // If user has now been created in Users collection then go to Tutorial Page
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                GoRouter.of(context).go(response);
              });
            },
          );
      return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: mainBackgroundColor,
          appBar: AppBar(
            backgroundColor: appBarColor,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.account_circle, size: 30, color: iconColor),
                onPressed: () {},
              ),
              SizedBox(width: 12),
            ],
          ),
          body: Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFFFFDF9),
                border: Border.all(color: Color(0xFFFEFE5CC), width: 9.0),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: <Widget>[
                        // Page 1
                        letUsGetToKnowYouScreen(context),
                        // Page 2
                        privacyScreen(context),
                        // Page 3
                        notificationsScreen(context)
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.bottomCenter,
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: 3,
                          effect: WormEffect(
                            activeDotColor: buttonColor,
                            dotColor: mainBackgroundColor,
                          ),
                          onDotClicked: (index) {
                            _pageController.animateToPage(
                              index,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget letUsGetToKnowYouScreen(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return ListView(
        // PAGE 1
        padding: const EdgeInsets.all(5),
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              'Let us get to know you.',
              style: GoogleFonts.tinos(
                textStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Text(
            'What is your career?',
            style: GoogleFonts.tinos(
              textStyle: TextStyle(),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFFCEC0A1),
                width: 2.0, // Set the border width
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: TextField(
              controller: careerPosition,
              onChanged: (newValue) {
                setState(() {
                  answers[0] = newValue;
                });
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintText: 'Eg. lawyer',
                hintStyle: GoogleFonts.tinos(
                    textStyle: TextStyle(color: Colors.black)),
                border: InputBorder.none, // Hide the default border
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'How long have you been in this career?',
            style: GoogleFonts.tinos(
              textStyle: TextStyle(),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFFCEC0A1),
                width: 2.0, // Set the border width
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: TextField(
              controller: careerLength,
              onChanged: (newValue) {
                setState(() {
                  answers[1] = newValue;
                });
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintText: 'Eg. 2 years',
                hintStyle: GoogleFonts.tinos(
                    textStyle: TextStyle(color: Colors.black)),
                border: InputBorder.none, // Hide the default border
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a community that best fits your reason for joining Virtuous.',
                style: GoogleFonts.tinos(
                  textStyle: TextStyle(),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Learn more about communities.',
                  style: GoogleFonts.tinos(
                    textStyle: TextStyle(
                      decoration: TextDecoration.underline, // Add underline
                      decorationColor: Color(0xFFCEC0A1),
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFCEC0A1),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 3,
          ),
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFFCEC0A1),
                width: 2.0, // Set the border width
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: currentCommunity,
                    items: careerDropdownValues
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                          height: 30.0, // Adjust the height of each item
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              value,
                              style: GoogleFonts.tinos(textStyle: TextStyle()),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        currentCommunity = newValue!;
                        answers[2] = newValue!;
                      });
                    },
                    dropdownColor: Colors
                        .white, // Set the background color of the dropdown
                    isDense: true, // Reduce height
                    icon: Icon(Icons.arrow_drop_down,
                        color: Colors.black), // Align the arrow to the right
                    isExpanded: true, // Extend the button to the right
                    underline: Container(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Please describe your reasons for joining Virtuous.',
            style: GoogleFonts.tinos(textStyle: TextStyle()),
          ),
          SizedBox(
            height: 3,
          ),
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFFCEC0A1),
                width: 2.0, // Set the border width
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Enter text...',
                hintStyle: GoogleFonts.tinos(textStyle: TextStyle()),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                border: InputBorder.none,
              ),
              controller: reasons,
              onChanged: (newValue) {
                setState(() {
                  answers[3] = newValue;
                });
              },
            ),
          ),
        ],
      );
    });
  }

  Widget privacyScreen(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return ListView(
        // PAGE 222222222222222222222222222222222
        padding: const EdgeInsets.all(5),
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              'Privacy',
              style: GoogleFonts.tinos(
                textStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Text(
            'Would you like to participate in entry sharing?',
            style: GoogleFonts.tinos(textStyle: TextStyle()),
          ),
          Text(
            'If you select “Yes,” your data may be shown to other users. Your personal information won’t be shared, only your virtue usage.',
            style: GoogleFonts.tinos(
              textStyle: TextStyle(
                fontStyle: FontStyle.italic,
                color: Color(0xFFCEC0A1),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFFCEC0A1),
                width: 2.0, // Set the border width
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: shareEntries,
                    items: yesNoDropdownValues.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                          height: 30.0, // Adjust the height of each item
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(value,
                                style:
                                    GoogleFonts.tinos(textStyle: TextStyle())),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        shareEntries = newValue!;
                        answers[4] = newValue!;
                      });
                    },
                    dropdownColor: Colors
                        .white, // Set the background color of the dropdown
                    isDense: true, // Reduce height
                    icon: Icon(Icons.arrow_drop_down,
                        color: Colors.black), // Align the arrow to the right
                    isExpanded: true, // Extend the button to the right
                    underline: Container(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Text(
            'Would you like to share your location?',
            style: GoogleFonts.tinos(textStyle: TextStyle()),
          ),
          Text(
            'We will not share your location with other users. However you can’t use some features without location tuned on.',
            style: GoogleFonts.tinos(
              textStyle: TextStyle(
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(255, 90, 84, 70),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFFCEC0A1),
                width: 2.0, // Set the border width
              ),
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: shareLocation,
                    items: yesNoDropdownValues.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                          height: 30.0, // Adjust the height of each item
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              value,
                              style: GoogleFonts.tinos(textStyle: TextStyle()),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      // When user agrees to share location, call controller to getLocation of user
                      setState(() {
                        if (newValue == "Yes")
                          // call controller to get location
                          ref
                              .read(surveyPageControllerProvider.notifier)
                              .getLocation();
                        shareLocation = newValue!;
                        answers[5] = newValue!;
                      });
                    },
                    dropdownColor: Colors
                        .white, // Set the background color of the dropdown
                    isDense: true, // Reduce height
                    icon: Icon(Icons.arrow_drop_down,
                        color: Colors.black), // Align the arrow to the right
                    isExpanded: true, // Extend the button to the right
                    underline: Container(),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget notificationsScreen(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return ListView(
        // PAGE 33333333333333333333333333333333
        padding: const EdgeInsets.all(5),
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              'Notifications',
              style: GoogleFonts.tinos(
                textStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Text(
            'Turn on notifications?',
            style: GoogleFonts.tinos(
              textStyle: TextStyle(),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFFCEC0A1),
                width: 2.0, // Set the border width
              ),
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: allowNotifications,
                    items: yesNoDropdownValues.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                          height: 30.0, // Adjust the height of each item
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              value,
                              style: GoogleFonts.tinos(
                                textStyle: TextStyle(),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        allowNotifications = newValue!;
                        answers[6] = newValue!;
                      });
                    },
                    dropdownColor: Colors
                        .white, // Set the background color of the dropdown
                    isDense: true, // Reduce height
                    icon: Icon(Icons.arrow_drop_down,
                        color: Colors.black), // Align the arrow to the right
                    isExpanded: true, // Extend the button to the right
                    underline: Container(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),

          // Sean implementation
          // Visibility(
          //   visible: allowNotifications ==
          //       'Yes', // Set this to true when 'Yes' is selected
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         'Enter your phone number.',
          //         style: GoogleFonts.tinos(
          //           textStyle: TextStyle(),
          //         ),
          //       ),
          //       SizedBox(
          //         height: 3,
          //       ),
          //       Container(
          //         padding: EdgeInsets.all(3.0),
          //         decoration: BoxDecoration(
          //           border: Border.all(
          //             color: Color(0xFFCEC0A1),
          //             width: 2.0, // Set the border width
          //           ),
          //           borderRadius: BorderRadius.circular(5.0),
          //         ),
          //         child: TextField(
          //           controller: phoneNumber,
          //           keyboardType: TextInputType.phone,
          //           decoration: InputDecoration(
          //             contentPadding: EdgeInsets.zero,
          //             isDense: true,
          //             border: InputBorder
          //                 .none, // Hide the default border
          //             hintText: '(999)-999-9999',
          //             hintStyle: GoogleFonts.tinos(
          //               textStyle:
          //                   TextStyle(color: Colors.black),
          //             ),
          //           ),
          //         ),
          //       ),
          //       SizedBox(
          //         height: 20,
          //       ),
          // Rachel Implementation
          Visibility(
            visible: allowNotifications ==
                "Yes", // Set this to true when 'Yes' is selected
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter your phone number.'),
                Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFCEC0A1),
                        width: 2.0, // Set the border width
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            prefixText: "+1 ",
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            border: InputBorder.none, // Hide the default border
                            hintText: '(999)-999-9999'),
                        validator: (value) {
                          if (value!.length != 10)
                            return "Invalid phone number";
                          return null;
                        },
                      ),
                    )),
                SizedBox(
                  height: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Users().sendOtp(
                            phone: _phoneController.text,
                            errorStep: () => ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    "Error sending OTP",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                )),
                            nextStep: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text("OTP Verification"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Enter 6 digit OTP"),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Form(
                                              key: _formKey1,
                                              // text field is kinda invisible someone pls make it visible
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: _otpController,
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  isDense: true,
                                                  // border: InputBorder.
                                                ),
                                                validator: (value) {
                                                  if (value!.length != 6)
                                                    return "Invalid OTP";
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                if (_formKey1.currentState!
                                                    .validate()) {
                                                  Users()
                                                      .confirmOtp(
                                                          otp: _otpController
                                                              .text)
                                                      .then((value) {
                                                    if (value == "Success") {
                                                      phoneVerified = true;
                                                      Navigator.pop(context);
                                                      print(
                                                          "Phone number verified");
                                                    } else {
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                        content: Text(
                                                          value,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ));
                                                    }
                                                  });
                                                }
                                              },
                                              child: Text("Submit"))
                                        ],
                                      ));
                            });
                      }
                    },
                    child: Center(
                      child: Text('Verify'),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white),
                  ),
                ),
                Text(
                  'Select a time to receive notifications.',
                  style: GoogleFonts.tinos(
                    textStyle: TextStyle(),
                  ),
                ),
                Center(
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: Text(
                        'Select Time',
                        style: TextStyle(
                          color: Color(0xFFFFFDF9),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.amber,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    selectedTime != null
                        ? 'Time Selected: ${selectedTime!.hourOfPeriod}:${selectedTime!.minute} ${selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}'
                        : 'Time not selected',
                    style: GoogleFonts.tinos(
                      textStyle: TextStyle(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  print(careerPosition.text);
                  print(careerLength.text);
                  print(currentCommunity);
                  print(reasons.text);
                  print(shareEntries);
                  print(shareLocation);
                  print(allowNotifications);
                  print(phoneNumber.text);
                  print(notificationTime.text);
                  print(userLocation.toString());

                  if (careerPosition.text == "" ||
                      careerLength.text == "" ||
                      currentCommunity.isEmpty ||
                      reasons.text == "") {
                    print('Fields missing');
                    return;
                  } else {
                    ref.read(surveyPageControllerProvider.notifier).surveyInfo(
                        careerPosition.text,
                        careerLength.text,
                        currentCommunity,
                        reasons.text,
                        shareEntries == "Yes" ? true : false,
                        shareLocation == "Yes" ? true : false,
                        allowNotifications == "Yes" ? true : false,
                        phoneNumber.text,
                        notificationTime.text,
                        phoneVerified,
                        userLocation!);
                  }
                },
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                  // Change button color to beige
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _formatPhoneNumberOnType() {
    final newValue = phoneNumber.text.replaceAll(RegExp(r'\D'), '');
    final formattedValue = _formatPhoneNumber(newValue);
    setState(() {
      phoneNumber.value = phoneNumber.value.copyWith(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    });
  }

  String _formatPhoneNumber(String input) {
    if (input.length <= 3) {
      return input;
    } else if (input.length <= 6) {
      return '${input.substring(0, 3)}-${input.substring(3)}';
    } else {
      return '${input.substring(0, 3)}-${input.substring(3, 6)}-${input.substring(6, 10)}';
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        print(pickedTime.format(context));
        String timey = pickedTime.format(context).toString();
        selectedTime = pickedTime;
        answers[8] =
            '${selectedTime!.hour}:${selectedTime!.minute} ${selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}';
        notificationTime.text =
            '${selectedTime!.hour}:${selectedTime!.minute} ${selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}';
      });
    }
  }

  @override
  void dispose() {
    // Dispose the controllers to avoid memory leaks
    careerPosition.dispose();
    careerLength.dispose();
    reasons.dispose();
    phoneNumber.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
