import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple receipt validator client.
///
/// In production point this to your server which validates Play/Apple receipts
/// and returns a JSON `{ "valid": true }` response.
class ReceiptValidator {
  final Uri serverUrl;

  ReceiptValidator({required this.serverUrl});

  /// Send [receipt] to the validation server. Returns true if server reports valid.
  Future<bool> validate(String receipt) async {
    final resp = await http.post(serverUrl, body: jsonEncode({'receipt': receipt}), headers: {'content-type': 'application/json'});
    if (resp.statusCode != 200) return false;
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return body['valid'] == true;
  }
}
