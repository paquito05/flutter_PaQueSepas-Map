import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:foodorderapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodorderapp/signup.dart';
import 'dart:developer';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _isObscure = true;

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 120,
                    ),

                    Column(
                      children: [
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(50),
                            width: 300,
                            height: 130,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        AssetImage("asset/images/Logo_6.png"),
                                    fit: BoxFit.cover)),
                          ),
                        ),
                        Center(
                          child: Text('PA QUE SEPAS',
                              style: TextStyle(
                                  color: Color(0xFF59706F),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),

                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        buildInputForm('Email', false, emailController),
                        buildInputForm('Password', true, passwordController),
                      ],
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    InkWell(
                      //falta implemetar por ingescion de codigo
                      onTap: emailController.text == "" ||
                              passwordController.text == ""
                          ? null
                          : () {
                              setState(() {
                                _isLoading = true;
                              });
                              signIn(emailController.text,
                                  passwordController.text);
                            },
                      child: Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.greenAccent),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ).copyWith(color: Color(0xFFFFFFFF)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text('¿ Eres nuevo en la Aplicacion?',
                            style: TextStyle(
                                color: Color(0xFF59706F),
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Registrate',
                            style: TextStyle(
                              color: Color(0xFF1B383A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationThickness: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //LoginOption(),
                  ],
                ),
              ),
            ),
    );
  }

  signIn(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {'email': email, 'password': pass, 'gettoken': true};
    var jsonResponse = null;

    var response = await http.post(
        Uri.parse('https://paquesepas-api.herokuapp.com/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'));

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);

      print(response.body);

      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });

        sharedPreferences.setString("token", jsonResponse['token']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MyHomePage()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  Padding buildInputForm(
      String label, bool pass, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: pass ? _isObscure : false,
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Color(0xFF979797),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1B383A)),
            ),
            suffixIcon: pass
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    icon: _isObscure
                        ? Icon(
                            Icons.visibility_off,
                            color: Color(0xFF979797),
                          )
                        : Icon(
                            Icons.visibility,
                            color: Color(0xFF1B383A),
                          ),
                  )
                : null),
      ),
    );
  }
}
