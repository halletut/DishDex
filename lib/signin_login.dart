import 'package:final_project/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? email;
  String? password;
  String? error;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 241, 243),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/dishdex.png"),
            SizedBox(
              height: 60,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "Login",
                  style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: const Color.fromARGB(255, 13, 42, 20)),
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Container(
                color: const Color.fromARGB(255, 255, 255, 255),
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Email Address",
                        style: GoogleFonts.mulish(
                            color: const Color.fromARGB(255, 98, 98, 98),
                            fontSize: 15),
                      ),
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                          hintText: 'sample@gmail.com',
                          hintStyle: GoogleFonts.mulish(
                              color: const Color.fromARGB(255, 166, 166, 166)),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          fillColor: const Color.fromARGB(255, 238, 243, 237),
                          filled: true,
                        ),
                        maxLength: 64,
                        onChanged: (value) => email = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        }),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Password",
                        style: GoogleFonts.mulish(
                            color: const Color.fromARGB(255, 98, 98, 98),
                            fontSize: 15),
                      ),
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          hintStyle: GoogleFonts.mulish(
                              color: const Color.fromARGB(255, 166, 166, 166)),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          fillColor: const Color.fromARGB(255, 238, 243, 237),
                          filled: true,
                        ),
                        obscureText: true,
                        onChanged: (value) => password = value,
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Your password must contain at least 8 characters.';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                    Color.fromARGB(255, 55, 72, 58)),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder()),
                                shadowColor: WidgetStatePropertyAll(
                                    Color.fromARGB(255, 40, 83, 46))),
                            child: Text(
                              'Login',
                              style: GoogleFonts.mulish(
                                  color:
                                      const Color.fromARGB(255, 207, 231, 216)),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                tryLogin();
                              }
                            })),
                    SizedBox(
                        height: 36,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Dont have an account? ",
                                style: TextStyle(fontSize: 15)),
                            SelectableText(onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ));
                            }, "Sign up now",
                                style: GoogleFonts.mulish(
                                  fontSize: 15,
                                  color: const Color.fromARGB(255, 12, 125, 74),
                                ))
                          ],
                        )),
                    if (error != null)
                      Text(
                        "Error: $error",
                        style: TextStyle(color: Colors.red[800], fontSize: 12),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void tryLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password!);

      error = null;

      if (mounted) setState(() {});

      if (!mounted) return;

      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        error = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        error = 'Wrong password provided for that user.';
      } else {
        error = 'An error occurred: ${e.message}';
      }
      setState(() {});
    }
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? email;
  String? password;
  String? error;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 241, 243),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/dishdex.png"),
            SizedBox(
              height: 60,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "Create Account",
                  style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: const Color.fromARGB(255, 13, 42, 20)),
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Container(
                color: const Color.fromARGB(255, 255, 255, 255),
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Email Address",
                        style: GoogleFonts.mulish(
                            color: const Color.fromARGB(255, 98, 98, 98),
                            fontSize: 15),
                      ),
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                          hintText: 'sample@gmail.com',
                          hintStyle: GoogleFonts.mulish(
                              color: const Color.fromARGB(255, 166, 166, 166)),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          fillColor: const Color.fromARGB(255, 238, 243, 237),
                          filled: true,
                        ),
                        maxLength: 64,
                        onChanged: (value) => email = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        }),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Password",
                        style: GoogleFonts.mulish(
                            color: const Color.fromARGB(255, 98, 98, 98),
                            fontSize: 15),
                      ),
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                          hintText: "Enter a password",
                          hintStyle: GoogleFonts.mulish(
                              color: const Color.fromARGB(255, 166, 166, 166)),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          fillColor: const Color.fromARGB(255, 238, 243, 237),
                          filled: true,
                        ),
                        obscureText: true,
                        onChanged: (value) => password = value,
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Your password must contain at least 8 characters.';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                    Color.fromARGB(255, 55, 72, 58)),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder()),
                                shadowColor: WidgetStatePropertyAll(
                                    Color.fromARGB(255, 40, 83, 46))),
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.mulish(
                                  color:
                                      const Color.fromARGB(255, 207, 231, 216)),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                trySignUp();
                              }
                            })),
                    SizedBox(
                        height: 36,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? ",
                                style: TextStyle(fontSize: 15)),
                            SelectableText(onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ));
                            }, "Log in here",
                                style: GoogleFonts.mulish(
                                  fontSize: 15,
                                  color: const Color.fromARGB(255, 12, 125, 74),
                                ))
                          ],
                        )),
                    if (error != null)
                      Text(
                        "Error: $error",
                        style: TextStyle(color: Colors.red[800], fontSize: 12),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void trySignUp() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email!, password: password!);
      error = null;
      if (mounted) setState(() {});
      if (!mounted) return;

      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ));
    } on FirebaseAuthException catch (e) {
      error = 'An error occurred: ${e.message}';
    }
    setState(() {});
  }
}
