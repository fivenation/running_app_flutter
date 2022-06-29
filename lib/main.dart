import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_app_flutter/screens/auth_page.dart';
import 'package:running_app_flutter/domain/services/auth_service.dart';
import 'package:running_app_flutter/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCUHlAEc6OMRbTfvSkPf6wfhfyaDokPVmQ',
        appId: '1:375947941287:android:6688e4c55d13dea21a5282',
        projectId: 'runningappflutter',
        messagingSenderId: '375947941287',
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<AuthUser?>.value(
      value: AuthService().currentUser,
      initialData: null,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LangingPage(),
      ),
    );
  }
}