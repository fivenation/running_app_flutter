import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  String? id;
  String? email;

  AuthUser.fromFirebase(User? user){
    email = user!.email;
    id = user.uid;
  }
}