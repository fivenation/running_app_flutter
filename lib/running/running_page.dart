import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:running_app_flutter/running/running_controller.dart';
import 'package:provider/provider.dart';

class RunningPage extends StatefulWidget {
  RunningPage({Key? key}) : super(key: key);

  @override
  State<RunningPage> createState() => _RunningPageState();
}

class _RunningPageState extends State<RunningPage> {
  final _controller = MapController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<MapController>(
        builder: (context, model, child) {
          return Scaffold(
              body: Column(
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
                                  builder: (context, snapshot) => Text(convertTime(snapshot.data??0), style: const TextStyle(fontSize: 36.0, fontWeight: FontWeight.w500),),
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
                                      .toStringAsFixed(1) + ' km',
                                  style: const TextStyle(
                                      fontSize: 36.0,
                                      fontWeight: FontWeight.w500
                                  ),
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
                              itemCount: model.kmTime.isNotEmpty ? (model.kmTime.length - 1) : 0,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        convertNumber(index + 1)+" km",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        convertTime(model.kmTime[index+1] - model.kmTime[index]).toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                          ),
                        ),
                        const SizedBox(height: 4),
                        // STOP RUNNING SESSION BUTTON
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            onPrimary: Theme.of(context).colorScheme.onPrimary,
                            primary: Theme.of(context).colorScheme.primary,
                          ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Stop'),
                        ),
                      ],
                    ),
                  )
                ],
              )
          );
        }
      ),
    );
  }

  // METHODS FOR PERFORMING INT VALUES TO STRING

  String convertTime(int value) {
    int hours = value ~/ 3600;
    int minutes = (value ~/ 60) % 60;
    int seconds = value % 60;
    String hoursFormatted = hours.toString().length < 2 ? "0" + hours.toString() : hours.toString();
    String minutesFormatted = minutes.toString().length < 2 ? "0" + minutes.toString() : minutes.toString();
    String secondsFormatted = seconds.toString().length < 2 ? "0" + seconds.toString() : seconds.toString();
    return "$hoursFormatted:$minutesFormatted:$secondsFormatted";
  }

  String convertNumber(int value) {
    String end = "th";
    if (value % 100 ~/10 != 1) {
      if (value % 10 == 1) end = 'st';
      if (value % 10 == 2) end = 'nd';
      if (value % 10 == 3) end = 'rd';
    }
    return'$value\'$end';
  }
}
