class RestauranteReponse {
  int total = 0;
  int pages = 0;
  List empresa = [RestauranteModel];
}

class RestauranteModel {
  String id = "";
  String nombre = "";
  String d_identidad = "";
  String provincia = "";
  String distrito = "";
  String direccion = "";
  String descripcion = "";
  String longitud = "";
  String latitud = "";
  String imagen = "";
  String estado = "";

  RestauranteModel(
      String id,
      String nombre,
      String d_identidad,
      String provincia,
      String distrito,
      String direccion,
      String descripcion,
      String longitud,
      String latitud,
      String imagen,
      String estado,
      String created_at,
      String author) {
    this.id = id;
    this.nombre = nombre;
    this.d_identidad = d_identidad;
    this.provincia = provincia;
    this.distrito = distrito;
    this.direccion = direccion;
    this.descripcion = descripcion;
    this.longitud = longitud;
    this.latitud = latitud;
    this.imagen = imagen;
    this.estado = estado;
  }

  RestauranteModel.fromJson(Map json)
      : id = json['_id'],
        nombre = json['nombre'],
        d_identidad = json['d_identidad'],
        provincia = json['provincia'],
        distrito = json['distrito'],
        direccion = json['direccion'],
        descripcion = json['descripcion'],
        longitud = json['longitud'],
        latitud = json['latitud'],
        imagen = json['imagen'],
        estado = json['estado'];
}
