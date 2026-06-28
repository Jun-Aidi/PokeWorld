class PokemonStat {
  final String name;
  final int baseStat;
  
  PokemonStat({required this.name, required this.baseStat});
}

class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final int baseExperience;
  final List<String> types;
  final List<String> abilities;
  final List<String> moves;
  final List<PokemonStat> stats;
  final String imageUrl;
  final String shinyImageUrl;
  final String cryUrl;

  Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.types,
    required this.abilities,
    required this.moves,
    required this.stats,
    required this.imageUrl,
    required this.shinyImageUrl,
    required this.cryUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    var typesList = json['types'] as List? ?? [];
    List<String> types = typesList
        .map((typeObj) => typeObj['type']['name'] as String)
        .toList();

    var abilitiesList = json['abilities'] as List? ?? [];
    List<String> abilities = abilitiesList
        .map((abilityObj) => abilityObj['ability']['name'] as String)
        .toList();

    var movesList = json['moves'] as List? ?? [];
    List<String> moves = movesList
        .map((moveObj) => moveObj['move']['name'] as String)
        .toList();

    var statsList = json['stats'] as List? ?? [];
    List<PokemonStat> stats = statsList.map((statObj) {
      return PokemonStat(
        name: statObj['stat']['name'] as String,
        baseStat: statObj['base_stat'] as int,
      );
    }).toList();

    return Pokemon(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      baseExperience: json['base_experience'] ?? 0,
      types: types,
      abilities: abilities,
      moves: moves,
      stats: stats,
      imageUrl: json['sprites']?['other']?['official-artwork']?['front_default'] ?? 
                json['sprites']?['front_default'] ?? '',
      shinyImageUrl: json['sprites']?['other']?['official-artwork']?['front_shiny'] ?? 
                     json['sprites']?['front_shiny'] ?? '',
      cryUrl: json['cries']?['latest'] ?? '',
    );
  }
}
