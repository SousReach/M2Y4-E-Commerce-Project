import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

/// Stores up to 10 recently viewed products locally.
/// Serialises minimal product data so no extra API calls are needed.
class RecentlyViewedService {
  static const _key = 'recently_viewed';
  static const _max = 10;

  static Future<void> add(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    // Remove duplicate
    raw.removeWhere((s) {
      try {
        return (jsonDecode(s) as Map)['id'] == product.id;
      } catch (_) {
        return false;
      }
    });

    final entry = jsonEncode({
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'image': product.images.isNotEmpty ? product.images[0] : '',
      'categoryName': product.categoryName,
    });

    raw.insert(0, entry);
    if (raw.length > _max) raw.removeRange(_max, raw.length);

    await prefs.setStringList(_key, raw);
  }

  static Future<List<Map<String, dynamic>>> get() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
