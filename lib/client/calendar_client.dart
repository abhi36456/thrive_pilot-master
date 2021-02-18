import 'package:http/http.dart' as http;

class CalendarClient extends http.BaseClient {
  http.Client _httpClient = new http.Client();
  final Map<String, dynamic> _defaultHeaders;
  CalendarClient(this._defaultHeaders);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_defaultHeaders);
    return _httpClient.send(request);
  }
}
