import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to handle PayMongo API requests.
/// SECURITY NOTICE: NEVER use your PayMongo Secret Key in the Flutter app.
/// Payment links and intents must be created on your backend (Firebase Functions / Supabase Edge Functions).
class PayMongoService {
  // Use your backend URL here, e.g., Firebase Cloud Function URL
  static const String _backendUrl =
      'https://your-backend-api.com/create-payment';

  /// Example: Call your backend to create a payment link
  Future<String?> createPaymentLink(double amount, String description) async {
    final url = Uri.parse(_backendUrl);

    final payload = {'amount': amount, 'description': description};

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add your app's authentication token here (e.g. Firebase App Check / Auth Token)
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['checkout_url'];
      } else {
        // Use a proper logger instead of print in production
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Note: If you need to tokenize credit cards directly from the app,
  // you can use the PAYMONGO_PUBLIC_KEY from dotenv.env['PAYMONGO_PUBLIC_KEY'].
}
