import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/pokemon_response.dart';
import '../models/pokemon.dart';
import '../models/pokemon_evolution.dart';

class ApiService {
  Future<PokemonListResponse> getPokemonList({String? url}) async {
    final endpoint = url ?? '${AppConstants.baseUrl}${AppConstants.pokemonEndpoint}?limit=${AppConstants.paginationLimit}';
    
    try {
      final response = await http.get(Uri.parse(endpoint));
      
      if (response.statusCode == 200) {
        return PokemonListResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load pokemon list');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Pokemon> getPokemonDetail(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return Pokemon.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load pokemon details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/type'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'];
        return results.map((e) => e['name'] as String).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<PokemonListItem>> getPokemonByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/type/$category'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List pokemonData = data['pokemon'];
        // Extract up to 20 for this category to mimic pagination/limits
        return pokemonData.take(50).map((e) {
          final p = e['pokemon'];
          return PokemonListItem.fromJson(p);
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<PokemonListItem>> fetchAllPokemon() async {
    try {
      // Fetch up to 1500 to cover all current pokemon for local searching
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}${AppConstants.pokemonEndpoint}?limit=1500'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'];
        return results.map((e) => PokemonListItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<EvolutionNode?> getEvolutionChain(int pokemonId) async {
    try {
      // 1. Get species data to find the evolution chain URL
      final speciesResponse = await http.get(Uri.parse('${AppConstants.baseUrl}/pokemon-species/$pokemonId'));
      if (speciesResponse.statusCode != 200) return null;
      
      final speciesData = jsonDecode(speciesResponse.body);
      final chainUrl = speciesData['evolution_chain']?['url'];
      if (chainUrl == null) return null;

      // 2. Get evolution chain data
      final chainResponse = await http.get(Uri.parse(chainUrl));
      if (chainResponse.statusCode != 200) return null;

      final chainData = jsonDecode(chainResponse.body);
      return EvolutionNode.fromJson(chainData['chain']);
    } catch (e) {
      return null;
    }
  }
}
