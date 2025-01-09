import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _favoritesKey = 'favorites';

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson == null) {
      return [];
    }
    final List<dynamic> decodedList = jsonDecode(favoritesJson);
    return decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> saveFavorites(List<Map<String, dynamic>> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = jsonEncode(favorites);
    await prefs.setString(_favoritesKey, favoritesJson);
  }
}