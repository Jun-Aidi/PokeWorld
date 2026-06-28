import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  static const _key = 'favorite_pokemon';

  List<String> _favoriteIds = []; // stored as "id:name:imageUrl"

  List<String> get favoriteIds => _favoriteIds;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList(_key) ?? [];
    notifyListeners();
  }

  bool isFavorite(String id) => _favoriteIds.any((e) => e.startsWith('$id:'));

  Future<void> toggleFavorite(String id, String name, String imageUrl) async {
    final entry = '$id:$name:$imageUrl';
    final prefs = await SharedPreferences.getInstance();

    if (isFavorite(id)) {
      _favoriteIds.removeWhere((e) => e.startsWith('$id:'));
    } else {
      _favoriteIds.add(entry);
    }

    await prefs.setStringList(_key, _favoriteIds);
    notifyListeners();
  }

  List<Map<String, String>> get favoriteList {
    return _favoriteIds.map((e) {
      final parts = e.split(':');
      return {
        'id': parts[0],
        'name': parts.length > 1 ? parts[1] : '',
        'imageUrl': parts.length > 2 ? parts.sublist(2).join(':') : '',
      };
    }).toList();
  }
}
