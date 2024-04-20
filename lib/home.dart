import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:password_generator/function.dart';
import 'package:clipboard/clipboard.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String url = Platform.isAndroid
      ? 'http://10.0.2.2:5000/generate_password'
      : 'http://127.0.0.1:5000/generate_password';
  String strength_url = Platform.isAndroid
      ? 'http://10.0.2.2:5000/check_password?query='
      : 'http://127.0.0.1:5000/check_password?query=';
  var data;
  var output = '';
  var copy_item = '';

  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _textFieldController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generatePassword,
              child: Text('Generate Password'),
            ),
            SizedBox(height: 20),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Generated Password',
                hintText: 'Generated Password',
                suffixIcon: IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    _copyToClipboard(output);
                    copy_item = output;
                  },
                ),
              ),
              controller: _textFieldController,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter Password',
                hintText: 'Enter Password',
                suffixIcon: IconButton(
                    icon: Icon(Icons.paste),
                    onPressed: () {
                      _pasteToClipboard(copy_item);
                    }),
              ),
              controller: _textFieldController2,
              onChanged: (value) {
                _checkStrength();
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _generatePassword() async {
    var responseData = await fetchdata(url);
    data = jsonDecode(responseData);
    setState(() {
      output = data['password'];
      _textFieldController.text = output;
    });
  }

  void _checkStrength() async {
    var strength_output = await fetchdata(
      strength_url + _textFieldController2.text.toString(),
    );
    data = jsonDecode(strength_output);
    _showSnackBar(data['Strength']);
  }

  void _copyToClipboard(String text) {
    FlutterClipboard.copy(text)
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password Copied')),
            ));
  }

  void _pasteToClipboard(String text) {
    FlutterClipboard.paste().then((value) {
      setState(() {
        _textFieldController2.text = value;
      });
    }).then((value) => _checkStrength());
  }

  void _showSnackBar(String strength) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: strength == 'Strong'
            ? Colors.green
            : strength == 'Average'
                ? Colors.amber[400]
                : Colors.red, // Custom background color
        content: Text(
          strength,
          style: TextStyle(color: Colors.white), // Custom text color
        ),
        duration: Duration(seconds: 2), // Set duration
        action: SnackBarAction(
          label: 'Close', // Custom action label
          textColor: Colors.white, // Custom action text color
          onPressed: () {
            ScaffoldMessenger.of(context)
                .hideCurrentSnackBar(); // Close the snackbar when action is pressed
          },
        ),
      ),
    );
  }
}
