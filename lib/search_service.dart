import 'package:string_similarity/string_similarity.dart';

class SearchService {
  // Filter services using string similarity comparison
  static List<Map<String, String>> filterServices(
      List<Map<String, String>> services, String query) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) return services;

    // Set a threshold for similarity score (0 to 1 scale)
    double threshold = trimmedQuery.length <= 3 ? 0.8 : 0.6;

    return services.where((service) {
      final title = service['title']!.toLowerCase();

      // First, check if the title contains the query directly.
      if (title.contains(trimmedQuery)) return true;

      // Otherwise, calculate similarity score.
      double similarity = StringSimilarity.compareTwoStrings(title, trimmedQuery);
      return similarity >= threshold;
    }).toList();
  }
}
