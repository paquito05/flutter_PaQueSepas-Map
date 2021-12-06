
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'DirectionProvider.dart';
import 'package:provider/provider.dart';
import 'models/restaurante_model.dart';

class MapPage extends StatefulWidget {

  final RestauranteModel restaurant;
  MapPage({Key key, @required this.restaurant}) : super (key: key);

  @override
  _mapState createState() => _mapState();

}

class _mapState extends State<MapPage>{
  GoogleMapController _mapController;
  double latitudRes = 0;
  double longitudRes = 0;
  bool _isLoading = true;
  double latitud = 0;
  double longitud = 0;
  var linesRuta = [];
  @override
  void initState() {
    super.initState();
    cargarDatos();
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
      latitud = geopostion.latitude;
      longitud = geopostion.longitude;
      print(latitud);
      print(longitud);
    });
  }

  cargarDatos () async{
    await _determinePosition();
    if (latitud != null && longitud != null){
      setState(() {
        _isLoading = false;
        latitudRes = double.parse(widget.restaurant.latitud);
        longitudRes = double.parse(widget.restaurant.longitud);
      });
    }else{
      print("Error");
    }
  }

  Widget button (IconData icon){
    return FloatingActionButton(
        onPressed: () =>{
          Navigator.pop(context)
        },
        materialTapTargetSize: MaterialTapTargetSize.padded,
        child: Icon(
          icon,
          size: 20,
          color: Colors.white,
        ),
    );
  }



  @override
  Widget build(BuildContext context){
    LatLng latLng = LatLng(latitud, longitud);
    CameraPosition cameraPosition = CameraPosition(target: latLng,
        zoom: 16,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isLoading
      ? Center(child: CircularProgressIndicator())
          : Scaffold(
          body: Consumer<DirectionProvider>(
            builder: (BuildContext context, DirectionProvider api, Widget child){
              return 
                GoogleMap(
                  initialCameraPosition: cameraPosition,
                  polylines: api.currentRoute,
                  markers: _createMarkers(),
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
              );
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    button(Icons.arrow_back),

                  ],
                ),
              );
            },
          ),
            floatingActionButton:(
                button(Icons.arrow_back)
            ),
      ),
    );
  }
  Set<Marker> _createMarkers(){
    var tmp = Set<Marker>();
    tmp.add(Marker(
        markerId: MarkerId("Restaurant"),
        position: LatLng(latitudRes, longitudRes),
    ));
    return tmp;
  }
  void _onMapCreated(GoogleMapController controller){
    _mapController = controller;
    _centerView();
  }
  _centerView() {
    var api = Provider.of<DirectionProvider>(context, listen:false);

    print("buscando direcciones");
    LatLng fromPoint = LatLng(latitud, longitud);
    LatLng toPoint = LatLng(latitudRes, longitudRes);

    api.findDirections(fromPoint, toPoint);

    var left = min(fromPoint.latitude, toPoint.latitude);
    var right = max(fromPoint.latitude, toPoint.latitude);
    var top = max(fromPoint.longitude, toPoint.longitude);
    var bottom = min(fromPoint.longitude, toPoint.longitude);

    api.currentRoute.first.points.forEach((point) {
      left = min(left, point.latitude);
      right = max(right, point.latitude);
      top = max(top, point.longitude);
      bottom = min(bottom, point.longitude);
    });

    var bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    _mapController.animateCamera(cameraUpdate);
  }

}