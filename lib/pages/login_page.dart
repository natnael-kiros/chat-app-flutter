// ignore_for_file: prefer_const_constructors

import 'package:chat_app/pages/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 203, 203, 204),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Login Page",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 27, 112, 182),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: "Username",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 27, 112, 182),
                    width: 1.5,
                  ), // Set the default border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 27, 112, 182),
                    width: 2.5,
                  ), // Set the focused border color
                ),
              ),
              controller: _usernameController,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: "Password",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 27, 112, 182),
                    width: 1.5,
                  ), // Set the default border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 27, 112, 182),
                    width: 2.5,
                  ), // Set the focused border color
                ),
              ),
              controller: _passwordController,
              obscureText: true,
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                // Call the login method from AuthProvider
                await Provider.of<AuthProvider>(context, listen: false).login(
                  context,
                  _usernameController,
                  _passwordController,
                );
              }, // Call login function
              child: Container(
                width: 300,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 27, 112, 182),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                        color: Color.fromARGB(255, 223, 223, 224),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Text("Don't have an account?"),
                TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return SignUpPage();
                        },
                      ));
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.lightBlue),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
