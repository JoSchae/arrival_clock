import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

///
/// Test app
///
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrival Time',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: 'Arrival Time',
      ),
    );
  }
}

///
/// Home page
///
class MyHomePage extends StatefulWidget {
  ///
  /// AppBar title
  ///
  final String title;

  /// Home page
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

///
/// Page state
///
class MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now().add(Duration(days: 360));
  File? _pickedImage;

  final CountdownController _controller = CountdownController(autoStart: true);

  @override
  void initState() {
    super.initState();
    loadData().then((data) {
      setState(() {
        _pickedImage = File(data['imagePath']);
        _selectedDate = data['chosenDateTime'];
        _startCountdown();
      });
    });
  }

  void _startCountdown() {
    _controller.start();
  }

  void updateDateTime(DateTime newDateTime) {
    setState(() {
      _selectedDate = newDateTime;
      _startCountdown();
    });
    saveDate(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final clipper = HeartClipper();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
        backgroundColor: Colors.green[500],
        actions: <Widget>[
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Text("Change Arrival Date"),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text("Change Image"),
              ),
            ],
            onSelected: (value) {
              if (value == 1) {
                showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                ).then((date) {
                  if (date != null) {
                    showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                    ).then((time) {
                      if (time != null) {
                        _selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                        updateDateTime(_selectedDate);
                      }
                    });
                  }
                });
              } else if (value == 2) {
                final picker = ImagePicker();
                picker
                    .pickImage(source: ImageSource.gallery)
                    .then((pickedFile) {
                  if (pickedFile != null) {
                    setState(() {
                      _pickedImage = File(pickedFile.path);
                    });
                    saveImagePath(pickedFile.path);
                  }
                });
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.green[500],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: ClipPath(
                      clipper: clipper,
                      child: Image(
                        image: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : const AssetImage('images/lover_picture_2.png')
                                as ImageProvider,
                      ),
                    ),
                  ),
                ],
              ),
              Countdown(
                controller: _controller,
                seconds: _getTimeDifferenceUntilArrival(),
                build: (_, double time) => Text(
                  _getRemainingAsString(time),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                ),
                interval: const Duration(milliseconds: 1000),
                onFinished: () {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Timer is done!'),
                      ),
                    );
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _getTimeDifferenceUntilArrival() {
    final now = DateTime.now().toLocal();
    final arrivalTime = _selectedDate.toLocal();
    final difference = arrivalTime.difference(now);
    return difference.inSeconds;
  }

  _getRemainingAsString(double timeInSeconds) {
    final days = (timeInSeconds / 86400).floor();
    final hours = ((timeInSeconds / 3600) % 24).floor();
    final minutes = ((timeInSeconds / 60) % 60).floor();
    final seconds = (timeInSeconds % 60).floor();

    return '${days.toString()} days, ${hours.toString().padLeft(2, '0')} hours, ${minutes.toString().padLeft(2, '0')} minutes, ${seconds.toString().padLeft(2, '0')} seconds';
  }
}

class HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    // Define your heart shape here
    // This is just a simple example, you might need to adjust it to fit your needs
    path.moveTo(size.width * 0.9192285, size.height * 0.1420413);
    path.cubicTo(
        size.width * 0.8668648,
        size.height * 0.08967757,
        size.width * 0.7975412,
        size.height * 0.06105775,
        size.width * 0.7235537,
        size.height * 0.06105775);
    path.cubicTo(
        size.width * 0.6495661,
        size.height * 0.06105775,
        size.width * 0.5800306,
        size.height * 0.08988957,
        size.width * 0.5276669,
        size.height * 0.1422532);
    path.lineTo(size.width * 0.5003191, size.height * 0.1696011);
    path.lineTo(size.width * 0.4725472, size.height * 0.1418293);
    path.cubicTo(
        size.width * 0.4201835,
        size.height * 0.08946557,
        size.width * 0.3504360,
        size.height * 0.06042175,
        size.width * 0.2764484,
        size.height * 0.06042175);
    path.cubicTo(
        size.width * 0.2026729,
        size.height * 0.06042175,
        size.width * 0.1331373,
        size.height * 0.08925357,
        size.width * 0.08098562,
        size.height * 0.1414053);
    path.cubicTo(
        size.width * 0.02862194,
        size.height * 0.1937689,
        size.width * -0.0002098787,
        size.height * 0.2633045,
        size.width * 0.000002119987,
        size.height * 0.3372921);
    path.cubicTo(
        size.width * 0.000002119987,
        size.height * 0.4112796,
        size.width * 0.02904594,
        size.height * 0.4806032,
        size.width * 0.08140962,
        size.height * 0.5329669);
    path.lineTo(size.width * 0.4795432, size.height * 0.9311004);
    path.cubicTo(
        size.width * 0.4850552,
        size.height * 0.9366124,
        size.width * 0.4924751,
        size.height * 0.9395804,
        size.width * 0.4996831,
        size.height * 0.9395804);
    path.cubicTo(
        size.width * 0.5068910,
        size.height * 0.9395804,
        size.width * 0.5143110,
        size.height * 0.9368244,
        size.width * 0.5198229,
        size.height * 0.9313124);
    path.lineTo(size.width * 0.9188045, size.height * 0.5338149);
    path.cubicTo(
        size.width * 0.9711682,
        size.height * 0.4814512,
        size.width * 1.000000,
        size.height * 0.4119156,
        size.width * 1.000000,
        size.height * 0.3379281);
    path.cubicTo(
        size.width * 1.000212,
        size.height * 0.2639405,
        size.width * 0.9715922,
        size.height * 0.1944049,
        size.width * 0.9192285,
        size.height * 0.1420413);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Function to save the date and time
Future<void> saveDate(DateTime chosenDateTime) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('chosenDateTime', chosenDateTime.millisecondsSinceEpoch);
}

// Function to save the image path
Future<void> saveImagePath(String imagePath) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('imagePath', imagePath);
}

// Function to load data
Future<Map<String, dynamic>> loadData() async {
  final prefs = await SharedPreferences.getInstance();
  final imagePath = prefs.getString('imagePath');
  final chosenDateTimeMillis = prefs.getInt('chosenDateTime');
  final chosenDateTime = chosenDateTimeMillis != null
      ? DateTime.fromMillisecondsSinceEpoch(chosenDateTimeMillis)
      : null;

  return {
    'imagePath': imagePath,
    'chosenDateTime': chosenDateTime,
  };
}
