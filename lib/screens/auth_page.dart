import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:running_app_flutter/domain/services/auth_service.dart';
import 'package:running_app_flutter/models/user_model.dart';
import 'package:running_app_flutter/screens/home_page.dart';

class LangingPage extends StatelessWidget {
  const LangingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthUser? authUser = Provider.of<AuthUser?>(context);
    final bool isLoggedIn = authUser != null;

    return isLoggedIn ? HomePage() : AuthPage();
  }
}

class AuthPage extends StatefulWidget{
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late String _email;
  late String _password;
  bool showLogin = true;
  
  final _authService = AuthService();

  Future<void> _loginButtonAction() async {
    _email = _emailController.text;
    _password = _passwordController.text;

    if(_email.isEmpty || _password.isEmpty) {
      return;
    }

    AuthUser? authUser = await _authService.signInWithEmailAndPassword(_email.trim(), _password.trim());
    if (authUser == null) {
      Fluttertoast.showToast(
        msg: "Can't SignIn you! Please check your e-mail or password",
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 1,
      );
    } else {
      _emailController.clear();
      _passwordController.clear();
    }
  }

  Future<void> _registerButtonAction() async {
    _email = _emailController.text;
    _password = _passwordController.text;

    if(_email.isEmpty || _password.isEmpty) {
      return;
    }

    AuthUser? authUser = await _authService.registerWithEmailAndPassword(_email.trim(), _password.trim());
    if (authUser == null) {
      Fluttertoast.showToast(
          msg: "Can't register you! Please check your e-mail or password",
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 1,
      );
    } else {
      _emailController.clear();
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _logo() {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Align(
          child: Text(
            'Running App',
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor
            ),
          ),
        ),
      );
    }

    Widget _input(Icon icon, String hint, TextEditingController controller, bool obscure) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black87
          ),
          decoration: InputDecoration(
            hintStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black26,
            ),
            hintText: hint,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black87, width: 2)
            ),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1)
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
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

    Widget _button(String label, void Function() func) {
      return RaisedButton(
        onPressed: func,
        splashColor: Theme.of(context).splashColor,
        highlightColor: Theme.of(context).highlightColor,
        color: Theme.of(context).primaryColor,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      );
    }

    Widget _form(String label, void Function() func) {
      return Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: _input(const Icon(Icons.email), 'E-mail', _emailController, false),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: _input(const Icon(Icons.lock), 'Password', _passwordController, true),
            ),
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.6,
                child: _button(label, func),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _logo(),
          (
            showLogin ?
            Column(
              children: [
                _form('LOGIN', _loginButtonAction),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    child: const Text('Not registered yet? Register!', style: TextStyle(fontSize: 20, color: Colors.blue),),
                    onTap: () {
                      setState(() {showLogin = false;});
                    },
                  ),
                )
              ],
            )
            : Column(
              children: [
                _form('REGISTER', _registerButtonAction),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    child: const Text('Already registered? Login!', style: TextStyle(fontSize: 20, color: Colors.blue),),
                    onTap: () {
                      setState(() {showLogin = true;});
                    },
                  ),
                )
              ],
            )
          )
        ],
      ),
    );
  }
}

