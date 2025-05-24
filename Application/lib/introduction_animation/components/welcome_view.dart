import 'package:NeuroScope/fitness_app/fitness_app_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/material.dart';
import 'dart:io';
class WelcomeView extends StatefulWidget {
  final AnimationController animationController;
  const WelcomeView({Key? key, required this.animationController})
      : super(key: key);

  @override
  _WelcomeViewState createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSuccessfulLogin(BuildContext context) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>  FitnessAppHomeScreen(),
      ),
    );

    Future.microtask(() {
      Phoenix.rebirth(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _firstHalfAnimation =
        Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
            .animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
    ));
    final _secondHalfAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(-1, 0))
            .animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(0.8, 1.0, curve: Curves.fastOutSlowIn),
    ));
    final _welcomeFirstHalfAnimation =
        Tween<Offset>(begin: Offset(2, 0), end: Offset(0, 0))
            .animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
    ));
    final _welcomeImageAnimation =
        Tween<Offset>(begin: Offset(4, 0), end: Offset(0, 0))
            .animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
    ));

    TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

    final emailField = TextField(
      controller: _emailController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
        hintText: "Username",
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
      ),
    );
    final passwordField = TextField(
      controller: _passwordController,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
        hintText: "Password",
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
      ),
    );

    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.black,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        onPressed: () async {
          print("Email: ${_emailController.text}");
          print("Password: ${_passwordController.text}");

          try {
            final credential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: "${_emailController.text}@eegapp.com",
              password: _passwordController.text,
            );

            if (credential.user != null) {
              _handleSuccessfulLogin(context);
            }
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              print('No user found for that email.');
            } else if (e.code == 'wrong-password') {
              print('Wrong password provided for that user.');
            } else {
              print('Error: ${e.message}');
            }
          }
        },
        child: Text(
          "Login",
          textAlign: TextAlign.center,
          style:
              style.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return SlideTransition(
      position: _firstHalfAnimation,
      child: SlideTransition(
        position: _secondHalfAnimation,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment(0, 0.3),
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _welcomeImageAnimation,
                  child: Image.asset(
                    'assets/introduction_animation/welcome.png',
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 30),
                SlideTransition(
                  position: _welcomeFirstHalfAnimation,
                  child: const Text(
                    "sign in",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                emailField,
                const SizedBox(height: 20),
                passwordField,
                const SizedBox(height: 30),
                loginButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
