import 'package:flutter/material.dart';
import 'package:foodorderapp/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreen createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  bool _isObscure = true;
  bool _isLoading = false;

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController nombreController = new TextEditingController();
  final TextEditingController apellidoController = new TextEditingController();
  final TextEditingController nicknameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 70,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Center(
                        child: Text(
                          'CREA TU CUENTA',
                          style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 32,
                              fontWeight: FontWeight.w700),
                        ),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 70),
                      child: Center(
                        child: Row(
                          children: [
                            Text(
                              '¿Ya tienes una cuenta?',
                              style: TextStyle(
                                  color: Color(0xFF59706F),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 5,
                      ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()));
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Color(0xFF1B383A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1,
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        buildInputForm('Nombre', false, nombreController),
                        buildInputForm('Apellido', false, apellidoController),
                        buildInputForm('Apodo', false, nicknameController),
                        buildInputForm('Email', false, emailController),
                        buildInputForm('Password', true, passwordController),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: InkWell(
                        onTap: emailController.text == "" ||
                                passwordController.text == "" ||
                                nombreController.text == "" ||
                                apellidoController.text == "" ||
                                nicknameController.text == ""
                            ? null
                            : () {
                                setState(() {
                                  _isLoading = true;
                                });

                                register(
                                    nombreController.text,
                                    apellidoController.text,
                                    nicknameController.text,
                                    emailController.text,
                                    passwordController.text);
                              },
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.08,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color(0xFF1B383A)),
                          child: Text(
                            "Registrate",
                            style: TextStyle(
                              color: Color(0xFF1B383A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ).copyWith(color: Color(0xFFFFFFFF)),
                          ),
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
    );
  }

  register(String nombre, apellido, nickname, email, pass) async {
    Map data = {
      'nombre': nombre,
      'apellido': apellido,
      'nickname': nickname,
      'email': email,
      'password': pass,
      'role': 'USER_ROLE'
    };

    var response = await http.post(
        Uri.parse('https://paquesepas-api.herokuapp.com/api/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'));

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  Padding buildInputForm(
      String hint, bool pass, TextEditingController controller) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          controller: controller,
          obscureText: pass ? _isObscure : false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFF979797)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1B383A))),
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
                          ))
                : null,
          ),
        ));
  }
}
