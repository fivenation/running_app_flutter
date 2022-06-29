import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:running_app_flutter/models/posts_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:running_app_flutter/domain/controllers/running_controller.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';

class RunningPage extends StatefulWidget {
  RunningPage({Key? key}) : super(key: key);

  @override
  State<RunningPage> createState() => _RunningPageState();
}

class _RunningPageState extends State<RunningPage> {
  final _controller = RunController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final AuthUser? authUser = Provider.of<AuthUser?>(context);

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Consumer<RunController>(builder: (context, model, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // YANDEX MAP WIDGET
              Expanded(
                flex: 3,
                child: YandexMap(
                  zoomGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  mapObjects: model.mapObjects,
                  onMapCreated: model.onMapCreated,
                ),
              ),
              const SizedBox(height: 20),
              // RUNNING PARAMS
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    // TIME AND DISTANCE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Time Left',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StreamBuilder<int>(
                              stream: model.timerController.getTime,
                              initialData: 0,
                              builder: (context, snapshot) => Text(
                                convertTime(snapshot.data ?? 0),
                                style: const TextStyle(
                                    fontSize: 36.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Distance',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ((model.distance / 100).floorToDouble() / 10)
                                      .toStringAsFixed(1) +
                                  ' km',
                              style: const TextStyle(
                                  fontSize: 36.0, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // TIME AND DISTANCE FOR EVERY KM LEFT
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: model.kmTime.isNotEmpty
                              ? (model.kmTime.length - 1)
                              : 0,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    convertNumber(index + 1) + " km",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    convertTime(model.kmTime[index + 1] -
                                            model.kmTime[index])
                                        .toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                    const SizedBox(height: 4),
                    // STOP RUNNING SESSION BUTTON
                    FloatingActionButton(
                      elevation: 2.0,
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        Navigator.pop(context);
                        if (authUser != null) {
                          stopDialog(
                            context,
                            authUser.email.toString(),
                            model.distance,
                            model.timerController.getLastTime,
                            model.points,
                            model.kmPoints,
                            model.kmTime
                          );
                        }
                      },
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  Future stopDialog(
      BuildContext context,
      String author,
      double distance,
      int time,
      List<Point> points,
      List<Point> kmPoints,
      List<int> kmTime) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final TextEditingController _titleController = TextEditingController();
          return AlertDialog(
            title: const Text('Finish running?'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter title for your running session:',
                  textDirection: TextDirection.ltr,
                ),
                SizedBox(
                  child: _input(
                    const Icon(Icons.short_text, color: Colors.blue,),
                    'Enter title',
                    _titleController,
                    false
                  ),
                )
              ],
            ),
            actions: [
              FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: const Text('ACCEPT'),
                onPressed: () async {
                  if (_titleController.text.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Title field is empty!",
                      textColor: Colors.white,
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT,
                      backgroundColor: Colors.red,
                      timeInSecForIosWeb: 1,
                    );
                    return;
                  }
                  final post = Post(
                    author: author,
                    title: _titleController.text.trim(),
                    datetime: DateTime.now().toString(),
                    distance: distance,
                    time: time,
                    points: points,
                    kmPoints: kmPoints,
                    kmTime: kmTime
                  );
                  print(jsonEncode(post.toJson()));
                  await writePost(post);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Widget _input(Icon icon, String hint, TextEditingController controller, bool obscure) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      width: 300,
      child: TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(
              fontSize: 16,
              color: Colors.black87
          ),
          decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black26,
              ),
              hintText: hint,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                child: IconTheme(
                  data: const IconThemeData(
                    color: Colors.black87,
                  ), child: icon,
                ),
              )
          )
      ),
    );
  }

  // FIREBASE METHODS

  Future<void> writePost(Post post) async {
    final _docPost = FirebaseFirestore.instance.collection('posts');
    _docPost
        .add(post.toJson())
        .then((value) => print("Post Added!"))
        .catchError((error) {
          print("FIREBASE ADD ERROR: $error");
          Fluttertoast.showToast(
            msg: "Something get wrong! Error: $error",
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.red,
            timeInSecForIosWeb: 1,
          );
        }
    );
  }

  // METHODS FOR PERFORMING INT VALUES TO STRING

  String convertTime(int value) {
    int hours = value ~/ 3600;
    int minutes = (value ~/ 60) % 60;
    int seconds = value % 60;
    String hoursFormatted =
        hours.toString().length < 2 ? "0" + hours.toString() : hours.toString();
    String minutesFormatted = minutes.toString().length < 2
        ? "0" + minutes.toString()
        : minutes.toString();
    String secondsFormatted = seconds.toString().length < 2
        ? "0" + seconds.toString()
        : seconds.toString();
    return "$hoursFormatted:$minutesFormatted:$secondsFormatted";
  }

  String convertNumber(int value) {
    String end = "th";
    if (value % 100 ~/ 10 != 1) {
      if (value % 10 == 1) end = 'st';
      if (value % 10 == 2) end = 'nd';
      if (value % 10 == 3) end = 'rd';
    }
    return '$value\'$end';
  }
}
