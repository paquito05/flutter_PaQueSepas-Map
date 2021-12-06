import 'package:flutter/material.dart';
import 'package:foodorderapp/Style.dart';
import 'package:foodorderapp/HotelPage.dart';
import 'dart:convert';
import 'package:foodorderapp/models/restaurante_model.dart';
import 'package:http/http.dart' as http;
import 'package:foodorderapp/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:foodorderapp/service/my_api.dart';
import 'DirectionProvider.dart';

void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => DirectionProvider())
        ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'mont'),
        home: MyHomePage(),
      );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;
  var restaurantes = <RestauranteModel>[];
  var restaurantesTop = <RestauranteModel>[];

  SharedPreferences sharedPreferences;
  String longitud = "";
  String latitud = "";

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    } else {
      _determinePosition();
    }
  }

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    var jsonResponse = null;

    // Pruebe si los servicios de ubicación están habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Los servicios de ubicación no están habilitados, no continúen
      // acceder al puesto y solicitar usuarios del
      // Aplicación para habilitar los servicios de ubicación.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Los permisos están denegados, la próxima vez que lo intentes
        // solicitando permisos nuevamente (aquí también es donde
        // Android shouldShowRequestPermissionRationale
        // devolvió verdadero. Según las pautas de Android
        // su aplicación debería mostrar una interfaz de usuario explicativa ahora.
        return Future.error('Location permissions are denied');
      }
    }

    // Cuando llegamos aquí, se otorgan permisos y podemos
    // seguir accediendo a la posición del dispositivo.
    final geopostion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitud = '${geopostion.latitude}';
      longitud = '${geopostion.longitude}';

      print("latitud" + latitud);
      print("Longitud" + longitud);
    });

    var response = await http.get(Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${longitud},${latitud}.json?access_token=pk.eyJ1Ijoic2FtdTA1IiwiYSI6ImNrdmZmejFybDF5dXoydXMxb2hoY3hkc3MifQ.zT-kZfvNm7jm9HTTOTFkPw'));

    try {
      print(response.statusCode);
      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);

        ///print("respone myapi" + response.body);

        if (jsonResponse != null) {
          //setState(() {
          //  _isLoading = false;
          //});

          List<dynamic> Listlocation = jsonResponse['features'];

          ///print(Listlocation);

          Map<String, dynamic> placename = Listlocation[0];

          ///print(placename);

          var place_name = placename['place_name'];

          List<String> place_name_split = place_name.split(",");

          print(place_name_split);
          var provincia = place_name_split[place_name_split.length - 4];
          var distrito = place_name_split[place_name_split.length - 3];

          print("pro " + provincia);
          print("distrito " + distrito);

          CallApi()
              .getRestauranteData('empresas/1', distrito, provincia)
              .then((response) {
            var list = json.decode(response.body);

            Iterable topRestaurantes = list['topEmpresas'];
            print(topRestaurantes);

            restaurantesTop = topRestaurantes
                .map((model) => RestauranteModel.fromJson(model))
                .toList();
            Iterable listrestaurnates = list['notopempresas'];
            print(listrestaurnates);

            restaurantes = listrestaurnates
                .map((model) => RestauranteModel.fromJson(model))
                .toList();

            if (restaurantesTop.length > 0 && restaurantes.length > 0) {
              setState(() {
                _isLoading = false;
              });
            }
          });
        }
      } else {
        print("respone myapi error" + response.body);

        // setState(() {
        //   _isLoading = false;
        // });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pa que Sepas", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              sharedPreferences.clear();
              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage()),
                  (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recomendados",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Disfruta de estos restaurantes top!",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 20),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.55,
                                height: 350,
                                padding: EdgeInsets.symmetric(
                                    vertical: 40, horizontal: 20),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    color: blue,
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 0,
                                          offset: Offset(0, 10),
                                          blurRadius: 0,
                                          color: blue.withOpacity(0.4))
                                    ]),
                                child: new InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => hotelPage(
                                                restaurant:
                                                    restaurantesTop[0])));
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "${restaurantesTop?.length > 0 ? restaurantesTop[0].imagen : ''}")),
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10))),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        "${restaurantesTop?.length > 0 ? restaurantesTop[0].nombre : ''}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          Text(
                                            " 250 Ratings",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${restaurantesTop?.length > 0 ? restaurantesTop[0].descripcion : ''}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      )
                                    ],
                                  ),
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  height: 165,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 20),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      color: green,
                                      boxShadow: [
                                        BoxShadow(
                                            spreadRadius: 0,
                                            offset: Offset(0, 10),
                                            blurRadius: 0,
                                            color: green.withOpacity(0.4))
                                      ]),
                                  child: new InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => hotelPage(
                                                  restaurant:
                                                      restaurantesTop[1])));
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "${restaurantesTop?.length > 0 ? restaurantesTop[1].imagen : ''}")),
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          "${restaurantesTop?.length > 0 ? restaurantesTop[1].nombre : ''}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                new InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => hotelPage(
                                                restaurant:
                                                    restaurantesTop[2])));
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        height: 165,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 20),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                            color: black,
                                            boxShadow: [
                                              BoxShadow(
                                                  spreadRadius: 0,
                                                  offset: Offset(0, 10),
                                                  blurRadius: 0,
                                                  color: black.withOpacity(0.4))
                                            ]),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          "${restaurantesTop?.length > 0 ? restaurantesTop[2].imagen : ''}")),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10),
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                              "${restaurantesTop?.length > 0 ? restaurantesTop[2].nombre : ''}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Places",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
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
                        child: Column(
                          children: restaurantes.map((rest) {
                            return placesWidget(rest);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Row placesWidget(RestauranteModel restaurante) {
    return Row(
      children: [
        Container(
          height: 100,
          width: 100,
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                    "${restaurante.imagen.length > 1 ? restaurante.imagen : ''}"),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10)),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${restaurante.nombre}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.orange,
                  ),
                  Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.orange,
                  ),
                  Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.orange,
                  ),
                  Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.orange,
                  ),
                  Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.orange,
                  ),
                ],
              ),
              Text(
                "${restaurante.descripcion}",
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => hotelPage(restaurant: restaurante)));
          },
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      color: Colors.white),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          " Ver",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
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
    );
  }
}
