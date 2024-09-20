// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat_app/pages/home_page.dart'; // Import your HomePage
import 'package:chat_app/pages/login_page.dart'; // Import your LoginPage

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _loggedInUsername;
  int? _loggedInUserId;
  int? _loggedInUserPhoneNo;

  bool get isLoggedIn => _isLoggedIn;
  String? get loggedInUsername => _loggedInUsername;
  int? get loggedInUserId => _loggedInUserId;
  int? get loggedInUserPhoneNo => _loggedInUserPhoneNo;

  Future<void> login(
    BuildContext context,
    TextEditingController usernameController,
    TextEditingController passwordController,
  ) async {
    final String username = usernameController.text;
    final String password = passwordController.text;

    final url = Uri.parse('http://192.168.1.6:8080/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      _isLoggedIn = true;
      print('Type of userId: ${responseData['userId'].runtimeType}');
      print('Type of username: ${responseData['username'].runtimeType}');
      print('Type of phoneNo: ${responseData['phoneNo'].runtimeType}');
      _loggedInUsername = responseData['username'];
      _loggedInUserId = responseData['userId'];
      _loggedInUserPhoneNo = responseData['phoneNo'];

      notifyListeners();
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid username or password'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> signup(
    BuildContext context,
    TextEditingController usernameController,
    TextEditingController passwordController,
    TextEditingController phoneNoController,
    String? imagePath, // Accept an optional image path parameter
  ) async {
    final String username = usernameController.text;
    final String password = passwordController.text;
    final int phoneNo = int.parse(phoneNoController.text);

    try {
      final url = Uri.parse('http://192.168.1.6:8080/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'phoneNo': phoneNo,
        }),
      );

      if (response.statusCode == 200) {
        notifyListeners();
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return LoginPage();
          },
        ));

        // After successful registration, upload the image separately
        String? imageUrl;
        if (imagePath != null) {
          // Upload image to the server
          imageUrl = await _uploadImageToServer(imagePath, username);
        }
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User already exists'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $error'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<String?> _uploadImageToServer(
      String imagePath, String username) async {
    final url = Uri.parse('http://192.168.1.6:8080/upload');

    // Read image bytes
    List<int> imageBytes = await File(imagePath).readAsBytes();

    // Create a map to store username and image bytes
    Map<String, dynamic> requestBody = {
      'username': username,
      'image': base64Encode(imageBytes), // Encode image bytes as base64 string
    };

    // Encode the map as JSON
    String jsonBody = jsonEncode(requestBody);

    // Send POST request with JSON body
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      // Image uploaded successfully, parse the response body as text
      final String responseText = response.body;
      return responseText;
    } else {
      throw 'Failed to upload image';
    }
  }

  Future<String?> getImageForUsername(String username) async {
    try {
      final url = Uri.parse('http://192.168.1.6:8080/get_image');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['image_url'];
        return imageUrl;
      } else {
        throw 'Failed to get image for username: $username';
      }
    } catch (error) {
      print('Error getting image for username: $error');
      return null;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _loggedInUsername = null;
    notifyListeners();
  }
}
