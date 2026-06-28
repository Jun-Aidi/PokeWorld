import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/api_service.dart';

class PokemonProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<String> _categories = [];
  List<String> get categories => _categories;

  List<Pokemon> _featuredTypesPokemon = [];
  List<Pokemon> get featuredTypesPokemon => _featuredTypesPokemon;

  int _focusedFeaturedIndex = 0;
  int get focusedFeaturedIndex => _focusedFeaturedIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PokemonProvider() {
    _initData();
  }

  void setFocusedFeaturedIndex(int index) {
    if (_focusedFeaturedIndex != index) {
      _focusedFeaturedIndex = index;
      notifyListeners();
    }
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Fetch categories
      _categories = await _apiService.getCategories();
      
      // Let's take 8 visually distinct categories for "Featured Types" to speed up loading
      // E.g., fire, water, grass, electric, psychic, fighting, dragon, dark
      final selectedCategories = ['fire', 'water', 'grass', 'electric', 'psychic', 'fighting', 'dragon', 'dark'];
      
      List<Pokemon> featured = [];
      for (var category in selectedCategories) {
        // Double check if category exists in fetched list (just in case)
        if (_categories.contains(category)) {
          final list = await _apiService.getPokemonByCategory(category);
          if (list.isNotEmpty) {
             final detail = await _apiService.getPokemonDetail(list.first.url);
             featured.add(detail);
          }
        }
      }
      _featuredTypesPokemon = featured;
      
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHome() async {
    _errorMessage = null;
    await _initData();
  }
}
