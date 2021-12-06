class PlatosReponse {
  int total = 0;
  int pages = 0;
  List producto = [PlatosModel];
}

class PlatosModel {
  String _id = "";
  String empresa = "";
  String fechacreacion = "";
  String nombre = "";
  String tipo_producto = "";
  String descripcion = "";
  String precio = "";
  String imagen = "";
  String estado = "";

  PlatosModel(
      String _id,
      String empresa,
      String fechacreacion,
      String nombre,
      String tipo_producto,
      String descripcion,
      String precio,
      String imagen,
      String estado,
      String created_at,
      String author) {

    this._id = _id;
    this.empresa = empresa;
    this.fechacreacion = fechacreacion;
    this.nombre = nombre;
    this.tipo_producto = tipo_producto;
    this.descripcion = descripcion;
    this.precio = precio;
    this.imagen = imagen;
    this.estado = estado;
  }

  PlatosModel.fromJson(Map json)
      : _id = json['_id'],
        empresa = json['empresa'],
        fechacreacion = json['fechacreacion'],
        nombre = json['nombre'],
        tipo_producto = json['tipo_producto'],
        descripcion = json['descripcion'],
        precio = json['precio'],
        imagen = json['imagen'],
        estado = json['estado'];
}
