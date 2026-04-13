import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const _key = 'search_history';
  static const _maxItems = 10;

  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    history.remove(trimmed); // remove duplicate
    history.insert(0, trimmed); // add to top
    if (history.length > _maxItems) {
      history.removeRange(_maxItems, history.length);
    }
    await prefs.setStringList(_key, history);
  }

  static Future<void> removeSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    history.remove(query);
    await prefs.setStringList(_key, history);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
