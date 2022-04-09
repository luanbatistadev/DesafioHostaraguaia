import 'dart:convert';
import 'package:desafio_hostaraguaia/models/evolution.dart';
import 'package:http/http.dart' as http;
import 'package:desafio_hostaraguaia/models/pokemon.dart';

class PokemonApi {
  static Future<List<Pokemon>> fetchPokemonsFromApi() async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=100000'));
    final json = jsonDecode(response.body);
    final pokemonsJson = json['results'] as List;
    final pokemons = pokemonsJson.map((e) => Pokemon.fromJson(e)).toList();
    return pokemons;
  }

  static Future<Pokemon> fetchDataListPokemon(String name) async {
    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'));
    final json = jsonDecode(response.body);
    final pokemonsJson = json as Map<String, dynamic>;
    final pokemon = Pokemon.fromJson(pokemonsJson);

    final responseAbilities = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/evolution-chain/${pokemon.id}'));
    if (responseAbilities.statusCode == 200) {
      final jsonAbilities = jsonDecode(responseAbilities.body);
      final evolutionJson = jsonAbilities as Map<String, dynamic>;
      final evolution = Evolution.fromJson(evolutionJson);
      return pokemon.copyWith(evolution: evolution);
    } else {
      return pokemon;
    }
  }
}
