import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:quick_task_flutter/models/task_model.dart';

// This class represents the structure of a task prioritized by the AI.
// It might differ slightly from the main Task model (e.g., might only contain title, description and priorityScore)
class PrioritizedTask {
  final String title;
  final String description;
  final int priorityScore;

  PrioritizedTask({
    required this.title,
    required this.description,
    required this.priorityScore,
  });

  factory PrioritizedTask.fromJson(Map<String, dynamic> json) {
    return PrioritizedTask(
      title: json['title'] as String,
      description: json['description'] as String? ?? '', // Assuming description can be null from AI
      priorityScore: (json['priorityScore'] as num).toInt(), // AI might send num (double/int)
    );
  }
}


class AIService {
  // IMPORTANT: Replace with your actual Genkit flow endpoint
  // For Android emulator, 10.0.2.2 maps to your host machine's localhost.
  // For iOS simulator or physical devices, use your computer's local network IP.
  // Example: http://192.168.1.100:4000/flows/prioritizeTaskListFlow
  // For deployed flows, use the actual cloud function URL.
  final String _genkitFlowUrl = 'http://10.0.2.2:4000/flows/prioritizeTaskListFlow';

  Future<List<PrioritizedTask>> prioritizeTasks(List<Task> tasks) async {
    if (tasks.isEmpty) {
      return [];
    }

    // Prepare the data in the format expected by the Genkit flow
    // The Genkit flow expects an array of objects with 'title' and 'description'.
    final List<Map<String, String>> tasksToPrioritize = tasks.map((task) {
      return {
        'title': task.title,
        'description': task.description,
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse(_genkitFlowUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tasksToPrioritize), // Send the list directly as the body
      );

      if (response.statusCode == 200) {
        // The Genkit flow is expected to return a list of prioritized tasks directly.
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData
            .map((item) => PrioritizedTask.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        // Attempt to parse error message from response if available
        String errorMessage = 'Failed to prioritize tasks. Status code: ${response.statusCode}';
        try {
            final errorBody = jsonDecode(response.body);
            if (errorBody is Map && errorBody.containsKey('message')) {
                errorMessage += '. Message: ${errorBody['message']}';
            } else if (response.body.isNotEmpty) {
                errorMessage += '. Body: ${response.body}';
            }
        } catch (_) {
            // Ignore if body is not valid JSON or doesn't have expected structure
             if (response.body.isNotEmpty) {
                errorMessage += '. Body: ${response.body}';
            }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Catch network errors or other exceptions during the HTTP request
      print('Error calling AI service: $e');
      throw Exception('Failed to connect to AI prioritization service: $e');
    }
  }
}

// Riverpod provider for the AIService
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});
