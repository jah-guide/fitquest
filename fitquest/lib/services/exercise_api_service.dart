import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise.dart';

class ExerciseApiService {
  static const _base = 'https://wger.de/api/v2';

  /// Fetch exercises. If [pageUrl] is provided, it will be used (useful for pagination).
  /// Returns a map with keys: 'results' -> List<Exercise>, 'next' -> String? (next page URL)
  Future<Map<String, dynamic>> fetchExercises({
    int limit = 20,
    String? pageUrl,
  }) async {
    final url = pageUrl != null
        ? Uri.parse(pageUrl)
        : Uri.parse('$_base/exercise/?language=2&status=2&limit=$limit');
    final resp = await http.get(url);
    if (resp.statusCode != 200) return {'results': <Exercise>[], 'next': null};

    final data = jsonDecode(resp.body) as Map<String, dynamic>?;
    if (data == null) return {'results': <Exercise>[], 'next': null};
    final resultsRaw = data['results'] as List<dynamic>?;
    if (resultsRaw == null) return {'results': <Exercise>[], 'next': null};
    final results = resultsRaw.cast<Map<String, dynamic>>();

    // fetch categories map
    final categories = await _fetchCategories();

    final List<Exercise> exercises = [];

    for (final item in results) {
      final id = item['id'] is int
          ? item['id'] as int
          : int.tryParse('${item['id']}') ?? 0;
      final name = _extractName(item);
      final description = _extractDescription(item);
      final catId = item['category'] is int
          ? item['category'] as int
          : (item['category'] is String
                ? int.tryParse(item['category'])
                : null);
      final category = (catId != null && categories.containsKey(catId))
          ? categories[catId]!
          : 'General';

      // try to get an image for this exercise
      String? imageUrl = await _fetchFirstImageForExercise(id);
      // Some API items include an image field directly
      if ((imageUrl == null || imageUrl.isEmpty) && item.containsKey('image')) {
        final v = item['image'];
        if (v is String && v.trim().isNotEmpty) imageUrl = v.trim();
      }
      if ((imageUrl == null || imageUrl.isEmpty) &&
          item.containsKey('image_url')) {
        final v = item['image_url'];
        if (v is String && v.trim().isNotEmpty) imageUrl = v.trim();
      }
      if ((imageUrl == null || imageUrl.isEmpty) &&
          item.containsKey('images')) {
        final v = item['images'];
        if (v is List && v.isNotEmpty) {
          final first = v.first;
          if (first is String && first.trim().isNotEmpty)
            imageUrl = first.trim();
          if (first is Map && first['image'] is String)
            imageUrl = (first['image'] as String).trim();
        }
      }

      exercises.add(
        Exercise(
          name: name,
          category: category,
          description: description,
          imageUrl: imageUrl ?? '',
          isSynced: true,
        ),
      );
    }

    final nextRaw = data['next'];
    final next = nextRaw is String ? nextRaw : null;
    return {'results': exercises, 'next': next};
  }

  String _extractName(Map<String, dynamic> item) {
    try {
      // Preferred candidate keys in priority order
      final candidates = [
        'name',
        'name_en',
        'name_original',
        'title',
        'short_name',
      ];
      for (final key in candidates) {
        final v = item[key];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }

      // If 'name' is a map (rare), try to pick the first non-empty string value
      final n1 = item['name'];
      if (n1 is Map) {
        for (final v in n1.values) {
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
      }

      // As a last resort, look for any short string field that seems like a title
      for (final entry in item.entries) {
        final k = entry.key.toLowerCase();
        final v = entry.value;
        if ((k.contains('name') || k.contains('title')) &&
            v is String &&
            v.trim().isNotEmpty) {
          return v.trim();
        }
      }

      // Give a fallback using id so the UI is less generic
      final id = item['id']?.toString() ?? '';
      return id.isNotEmpty ? 'Exercise #$id' : 'Exercise';
    } catch (e) {
      print('Failed to extract name for item: $e');
      return 'Exercise';
    }
  }

  String _extractDescription(Map<String, dynamic> item) {
    try {
      final candidates = [
        'description',
        'comment',
        'comment_en',
        'wiki_description',
      ];
      for (final key in candidates) {
        final v = item[key];
        if (v is String && v.trim().isNotEmpty) return _stripHtml(v).trim();
      }

      // Try any string field that looks like a description
      for (final entry in item.entries) {
        final k = entry.key.toLowerCase();
        final v = entry.value;
        if ((k.contains('desc') ||
                k.contains('comment') ||
                k.contains('text')) &&
            v is String &&
            v.trim().isNotEmpty) {
          return _stripHtml(v).trim();
        }
      }

      return '';
    } catch (_) {
      return '';
    }
  }

  Future<Map<int, String>> _fetchCategories() async {
    final url = Uri.parse('$_base/exercisecategory/');
    final resp = await http.get(url);
    if (resp.statusCode != 200) return {};
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final map = <int, String>{};
    for (final r in results) {
      map[r['id'] as int] = (r['name'] as String).trim();
    }
    return map;
  }

  Future<String?> _fetchFirstImageForExercise(int exerciseId) async {
    try {
      final url = Uri.parse('$_base/exerciseimage/?exercise=$exerciseId');
      final resp = await http.get(url);
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final results = (data['results'] as List<dynamic>);
      if (results.isEmpty) return null;
      final first = results.first as Map<String, dynamic>;
      final image = first['image'] as String?;
      return image;
    } catch (_) {
      return null;
    }
  }

  String _stripHtml(String input) {
    final exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return input.replaceAll(exp, '');
  }
}
