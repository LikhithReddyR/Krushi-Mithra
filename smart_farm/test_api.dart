import 'dart:convert';
import 'dart:io';

void main() async {
  final apiKey = 'AIzaSyDvsVYKn0tQ3zpQSlAvTOWIcY9Dk7w8Z5o';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=\$apiKey');
  
  final httpClient = HttpClient();
  try {
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final json = jsonDecode(responseBody);
      final models = json['models'] as List;
      print('Available Models:');
      for (var model in models) {
        print('- ' + model['name'].toString());
      }
    } else {
      print('API Error: \${response.statusCode}');
      print(responseBody);
    }
  } catch (e) {
    print('Failed: \$e');
  } finally {
    httpClient.close();
  }
}
