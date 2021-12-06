import 'package:flutter/material.dart';
import 'package:foodorderapp/Style.dart';
import 'package:foodorderapp/map.dart';
import 'package:foodorderapp/models/platos_model.dart';
import 'package:foodorderapp/models/restaurante_model.dart';
import 'package:foodorderapp/service/my_api.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HotelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "mont"),
      home: hotelPage(),
    );
  }
}

class hotelPage extends StatefulWidget {
  final RestauranteModel restaurant;

  hotelPage({Key key, @required this.restaurant}) : super(key: key);

  @override
  _hotelPageState createState() => _hotelPageState();
}

class _hotelPageState extends State<hotelPage> {
  bool _isLoading = true;
  SharedPreferences sharedPreferences;

  var PlatosRestaurantes = <PlatosModel>[];

  @override
  void initState() {
    super.initState();
    getPlatosdelRestaurante();
  }

  getPlatosdelRestaurante() async {
    sharedPreferences = await SharedPreferences.getInstance();

    var token = sharedPreferences.getString("token");

    CallApi()
        .getPlatosRestaurante(
            "get-productos-empresa/${widget.restaurant.id}", token.trim())
        .then((response) {
      var list = json.decode(response.body);
      Iterable listaPlatos = list["producto"];
      print(listaPlatos);

      PlatosRestaurantes =
          listaPlatos.map((model) => PlatosModel.fromJson(model)).toList();

      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: blue,
                              image: DecorationImage(
                                  image: NetworkImage(
                                      "${widget.restaurant.imagen}"),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(40))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 200,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "${widget.restaurant.nombre}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "250 Reviews",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                    child: Center(
                                      child: Icon(
                                        Icons.favorite,
                                        color: Colors.redAccent,
                                        size: 35,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "${widget.restaurant.descripcion}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Platos",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      height: 0.5,
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: PlatosRestaurantes.map((plato) {
                                    return dishWidget(plato);
                                  }).toList(),
                                ),
                              ),
                              SizedBox(
                                height: 18,
                              ),
                              InkWell(
                                onTap:() {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              MapPage(
                                                  restaurant:
                                                  widget.restaurant)));
                                },
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                            color: Colors.white),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                " Como llegar",
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              Icon(
                                                Icons.map_sharp,
                                                color: Colors.green,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Container dishWidget(PlatosModel plato) {
    return Container(
      width: 120,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage("${plato.imagen}"), fit: BoxFit.cover)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${plato.nombre}",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "${plato.descripcion}",
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: black),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          )
        ],
      ),
    );
  }
}
