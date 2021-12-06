

import 'package:http/http.dart' as http;

class CallApi {
  final String _urlbase = 'https://paquesepas-api.herokuapp.com/api/';
  final String _authority = "paquesepas-api.herokuapp.com";
  final String _imgUrl = 'http://mark.dbestech.com/uploads/';
  final String tokenMapbox =
      'pk.eyJ1Ijoic2FtdTA1IiwiYSI6ImNrdmZmejFybDF5dXoydXMxb2hoY3hkc3MifQ.zT-kZfvNm7jm9HTTOTFkPw';

  getImage() {
    return _imgUrl;
  }

  getRestauranteData(apiUrl, distrito, provincia) async {
    var provi = provincia.trim();
    var distri = distrito.trim();

    http.Response response = await http.get(Uri.https(_authority,
        '/api/${apiUrl}', {"provincia": provi, "distrito": distri}));

    try {
      print(response.statusCode);
      if (response.statusCode == 200) {
        return response;
      } else {
        return 'failed';
      }
    } catch (e) {
      print(e);
      return 'failed';
    }
  }

  getPlatosRestaurante(apiUrl, token) async {
    http.Response response = await http.get(
        Uri.https(_authority, '/api/${apiUrl}'),
        headers: {"Authorization": "${token}"});

    try {
      print(response.statusCode);
      if (response.statusCode == 200) {
        return response;
      } else {
        return 'failed';
      }
    } catch (e) {
      print(e);
      return 'failed';
    }
  }



}
