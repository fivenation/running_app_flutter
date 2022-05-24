import 'package:flutter/material.dart';
import 'package:running_app_flutter/running/running_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run App Flutter'),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlineButton(onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RunningPage())
                );
              },
                child: const Text( 'Run Page'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}