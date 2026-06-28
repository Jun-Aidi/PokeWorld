class EvolutionNode {
  final String name;
  final String id;
  final String imageUrl;
  final List<EvolutionNode> evolvesTo;

  EvolutionNode({
    required this.name,
    required this.id,
    required this.imageUrl,
    required this.evolvesTo,
  });

  factory EvolutionNode.fromJson(Map<String, dynamic> json) {
    final species = json['species'];
    final name = species['name'] as String;
    final url = species['url'] as String;
    
    // Extract ID from url (e.g., https://pokeapi.co/api/v2/pokemon-species/1/)
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    // The id is usually the second to last segment (since it ends with a slash)
    String id = '';
    if (segments.length >= 2) {
      id = segments[segments.length - 2];
    } else {
      id = segments.last; 
    }
    
    final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    var evolvesToList = json['evolves_to'] as List? ?? [];
    List<EvolutionNode> evolvesTo = evolvesToList
        .map((e) => EvolutionNode.fromJson(e as Map<String, dynamic>))
        .toList();

    return EvolutionNode(
      name: name,
      id: id,
      imageUrl: imageUrl,
      evolvesTo: evolvesTo,
    );
  }
}
