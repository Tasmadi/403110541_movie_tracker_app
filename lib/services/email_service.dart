import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/api_config.dart';

class EmailService {
  final http.Client client;

  EmailService({
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<void> sendPasswordResetCode({
    required String email,
    required String username,
    required String code,
  }) async {
    if (ApiConfig.emailJsServiceId.isEmpty ||
        ApiConfig.emailJsTemplateId.isEmpty ||
        ApiConfig.emailJsPublicKey.isEmpty) {
      throw Exception(
        'تنظیمات سرویس ایمیل کامل نیست.',
      );
    }

    Uri uri = Uri.parse(
      'https://api.emailjs.com/api/v1.0/email/send',
    );

    try {
      http.Response response = await client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'service_id': ApiConfig.emailJsServiceId,
              'template_id': ApiConfig.emailJsTemplateId,
              'user_id': ApiConfig.emailJsPublicKey,
              'template_params': {
                'to_email': email,
                'username': username,
                'reset_code': code,
              },
            }),
          )
          .timeout(
            const Duration(
              seconds: 20,
            ),
          );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'ارسال ایمیل بازیابی با خطا مواجه شد.',
        );
      }
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }

      throw Exception(
        'ارتباط با سرویس ایمیل برقرار نشد.',
      );
    }
  }
}
