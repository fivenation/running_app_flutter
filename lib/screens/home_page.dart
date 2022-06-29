import 'package:flutter/material.dart';
import 'package:running_app_flutter/domain/services/auth_service.dart';
import 'package:running_app_flutter/screens/running_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Run App Flutter'),
        actions: [
          FlatButton.icon(
            onPressed: (){
              AuthService().logOut();
            },
            icon: const Icon(Icons.exit_to_app, color: Colors.white,),
            label: const SizedBox.shrink(),
          ),
        ],
      ),
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