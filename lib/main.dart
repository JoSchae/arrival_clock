import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_count_down.dart';

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
  // Controller
  // final CountdownController _controller = CountdownController(autoStart: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
        backgroundColor: Colors.green[500],
      ),
      body: Container(
        color: Colors.green[500],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Image(
                image: AssetImage('images/lover_picture_2.png'),
              ),
              Countdown(
                // controller: _controller,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Timer is done!'),
                    ),
                  );
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
    final arrivalTime = DateTime(2024, 4, 18, 15, 15).toLocal();
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
