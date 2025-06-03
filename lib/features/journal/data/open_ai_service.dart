import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class OpenAiService {
  static final OpenAiService _instance = OpenAiService._internal();
  factory OpenAiService() => _instance;

  OpenAiService._internal() {
    _dio = Dio(); // Initialize Dio here
  }

  late final Dio _dio; // Declare Dio instance

  Future<String> getTitle(String journal) async {
    final prefs = await SharedPreferences.getInstance();
    final apiUrl =
        prefs.getString('api_url') ??
        'https://api.openai.com/v1/chat/completions';
    final apiToken = prefs.getString('api_token') ?? '';
    final model = prefs.getString('model') ?? 'gpt-4.1-nano';

    final response = await _dio.postUri(
      Uri.parse(apiUrl),
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        "messages": [
          {
            "role": "system",
            "content":
                """Return a short journal title as summary for this journal and system message if it's not default. Start chat name with one appropriate emoji. Don't answer to my message, just generate a name.""",
          },
          {"role": "user", "content": journal},
        ],
        "model": model,
        "stream": false,
        "temperature": 0.7,
        "max_tokens": 500,
        // "response_format": {"type": "json_object"},
      },
    );

    if (response.statusCode == 200) {
      return response.data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to fetch title: ${response.statusCode}');
    }
  }
}
