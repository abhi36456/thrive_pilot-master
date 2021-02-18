import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:thrive_pilot/utils/api.dart';
import 'package:thrive_pilot/utils/app_colors.dart';

class FocusPage extends StatefulWidget {
  final String type;

  FocusPage({this.type});

  @override
  _FocusPageState createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> with WidgetsBindingObserver {
  int _selectedTime = 0;
  bool _isStarted = false;
  var _progress = 0.00;
  CountdownTimerController _controller;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  initializeNotification() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("icon");
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: (i, s, s1, s2) {});
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (s) {
      print(s);
      return null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      if (_isStarted) {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails('1', 'notification', 'distracted',
                importance: Importance.max,
                priority: Priority.max,
                showWhen: false);
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
        await _flutterLocalNotificationsPlugin.show(0, 'Got Distracted?',
            'Don\'t lose focus. Tap to return.', platformChannelSpecifics,
            payload: 'item x');
      }
    }
    if (state == AppLifecycleState.resumed) {
      print("Resumed");
    }
  }

  void start() {
    setState(() {
      _isStarted = true;
    });
    // _controller = CountdownTimerController(
    //     endTime:
    //         DateTime.now().millisecondsSinceEpoch + (60000 * _selectedTime),
    //     onEnd: end);
    _controller = CountdownTimerController(
        endTime: DateTime.now().millisecondsSinceEpoch + (1000 * _selectedTime),
        onEnd: end);

    Future.delayed(Duration(seconds: 1), () {
      _controller.addListener(() {
        if (_controller.currentRemainingTime != null) {
          double time = 0;
          if (_controller.currentRemainingTime.hours != null)
            time += _controller.currentRemainingTime.hours * 60;
          if (_controller.currentRemainingTime.min != null)
            time += _controller.currentRemainingTime.min;
          time += _controller.currentRemainingTime.sec / 60;
          setState(() {
            _progress = (_selectedTime - time) * 100 / _selectedTime;
          });
        }
      });
    });
  }

  logFocus(time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.get("key");
    try {
      Dio dio = Dio();
      await dio.post(baseUrl + "save_focus_meditate.php",
          data: FormData.fromMap({
            "type": widget.type,
            "minute": time,
            "email": FirebaseAuth.instance.currentUser.email
          }));
      // prefs.setBool("isStored", true);
    } catch (e) {
      print(e);
    }
  }

  void end() async {
    Fluttertoast.showToast(
        msg: "$_selectedTime minutes focus session is completed");
    logFocus(_selectedTime);
    _selectedTime = 0;
    _progress = 0;
    _controller.removeListener(() {});
    setState(() {
      _isStarted = false;
    });
  }

  Future<bool> backPressed() async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Are you sure you want to give up?"),
            actions: [
              FlatButton(
                child: Text("Resume Session"),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              FlatButton(
                child: Text("End Session"),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                  double time = 0;
                  if (_controller.currentRemainingTime.hours != null)
                    time += _controller.currentRemainingTime.hours * 60;
                  if (_controller.currentRemainingTime.min != null)
                    time += _controller.currentRemainingTime.min;
                  time += _controller.currentRemainingTime.sec / 60;
                  logFocus(_selectedTime - time);
                  setState(() {
                    _selectedTime = 0;
                    _progress = 0;
                    _controller.disposeTimer();
                    _controller.dispose();
                    _isStarted = false;
                  });
                },
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _controller?.removeListener(() {});
    _controller?.disposeTimer();
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeNotification();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return _isStarted
        ? WillPopScope(
            onWillPop: backPressed,
            child: Container(
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     colors: [
              //       AppColors.secondary,
              //       AppColors.primaryColor,
              //     ],
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter,
              //     stops: [0.0, 0.3],
              //   ),
              // ),
              child: Column(
                children: [
                  SleekCircularSlider(
                    max: 100,
                    min: 0,
                    appearance: CircularSliderAppearance(
                      customWidths: CustomSliderWidths(
                        progressBarWidth: 3,
                        trackWidth: 3,
                      ),
                      customColors: CustomSliderColors(
                        trackColor: AppColors.primaryColor.withOpacity(0.3),
                        progressBarColor: AppColors.primaryColor,
                      ),
                      angleRange: 360,
                      startAngle: 270,
                      size: MediaQuery.of(context).size.width * 0.8,
                    ),
                    initialValue: _progress,
                    innerWidget: (value) => Center(
                      child: CountdownTimer(
                        controller: _controller,
                        widgetBuilder:
                            (ctx, CurrentRemainingTime timeRemaining) {
                          if (timeRemaining == null) {
                            return Text("");
                          } else {
                            String time = "";
                            if (timeRemaining.hours != null)
                              time += timeRemaining.hours
                                      .toString()
                                      .padLeft(2, "0") +
                                  ":";
                            if (timeRemaining.min != null)
                              time +=
                                  timeRemaining.min.toString().padLeft(2, "0") +
                                      ":";
                            time +=
                                timeRemaining.sec.toString().padLeft(2, "0");
                            return Container(
                              child: Text(
                                "$time",
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 40,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: backPressed,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: AppColors.primaryColor)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "End",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Column(
            children: [
              SleekCircularSlider(
                initialValue: 0,
                max: 24,
                appearance: CircularSliderAppearance(
                  angleRange: 360,
                  startAngle: 270,
                  size: MediaQuery.of(context).size.width * 0.8,
                  customWidths: CustomSliderWidths(
                      handlerSize: 12, progressBarWidth: 6, trackWidth: 6),
                  customColors: CustomSliderColors(
                      trackColor: Colors.grey,
                      dotColor: AppColors.primaryColor,
                      progressBarColor: AppColors.primaryColor),
                ),
                innerWidget: (value) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [
                              AppColors.secondary,
                              AppColors.primaryColor,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                      ),
                      child: Center(
                        child: Text(
                          "$_selectedTime Mins",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                        ),
                      ),
                    ),
                  );
                },
                onChange: (value) {
                  setState(() {
                    _selectedTime = value.ceil() * 5;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  if (_selectedTime == 0) {
                    // _key.currentState.showSnackBar(SnackBar(
                    //   content: Text("Select time more than 0 Mins"),
                    // ));
                  } else
                    start();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: AppColors.gradient),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    "Start",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
            ],
          );
  }
}
