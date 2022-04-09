import 'package:desafio_hostaraguaia/models/pokemon.dart';
import 'package:desafio_hostaraguaia/services/pokemon_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'pokemon_stores.g.dart';

class PokemonApiStore = _PokeApiStoreBase with _$PokemonApiStore;

abstract class _PokeApiStoreBase with Store {
  @observable
  List<Pokemon> pokemons = [];

  @observable
  Pokemon pokemon = Pokemon();

  @observable
  bool isFavorite = false;

  @observable
  List<String> historyList = [];

  @action
  getHistoryList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    historyList = prefs.getStringList('history') ?? [];
  }

  @action
  setHistory(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    historyList = prefs.getStringList('history') ?? [];
    if (!historyList.contains(name)) {
      historyList = [name, ...historyList];
      prefs.setStringList('history', historyList);
    }
  }

  @action
  getFavoriteList() async {
    final prefs = await SharedPreferences.getInstance();
    final favorite = prefs.getStringList('pokemons');
    final List<Pokemon> pokemons = [];
    if (favorite != null) {
      for (var element in favorite) {
        final pokemon = Pokemon(name: element);
        pokemons.add(pokemon);
      }
      this.pokemons = pokemons;
    }
  }

  @action
  getFavorite(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final favorite = prefs.getStringList('pokemons');
    if (favorite != null) {
      for (var element in favorite) {
        if (element == name) {
          isFavorite = true;
        }
      }
    }
  }

  @action
  changeFavorite(Pokemon pokemon) async {
    isFavorite = !isFavorite;

    Fluttertoast.showToast(
      msg: isFavorite
          ? "Pokemon Favoritado!"
          : "Pokemon Removido dos Favoritos!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    final prefs = await SharedPreferences.getInstance();
    List<String>? pokemons = prefs.getStringList('pokemons') ?? [];
    if (isFavorite) {
      pokemons = [pokemon.name!, ...pokemons];
    } else {
      pokemons.remove(pokemon.name);
    }
    await prefs.setStringList('pokemons', pokemons);
  }

  @action
  fetchPokemons() async {
    final pokemons = await PokemonApi.fetchPokemonsFromApi();

    this.pokemons = pokemons;
  }

  @action
  searchPokemon(String name) async {
    await fetchPokemons();
    final List<Pokemon> pokemons = this
        .pokemons
        .where(
          (e) => hasWildcardMatch(
            e.name!.toLowerCase(),
            name.toLowerCase(),
          ),
        )
        .toList();

    this.pokemons = pokemons;
  }

  @action
  fetchDataListPokemon() async {
    List<Pokemon> pokemons = [];
    for (var element in this.pokemons) {
      final pokemon = await PokemonApi.fetchDataListPokemon(element.name!);
      pokemons.add(pokemon);
    }
    this.pokemons = pokemons;
  }

  @action
  fetchPokemon(String name) async {
    final pokemon = await PokemonApi.fetchDataListPokemon(name);
    this.pokemon = pokemon;
  }

  bool hasWildcardMatch(String source, String text) {
    final regexp = text.split('').join('.*');

    return RegExp(regexp).hasMatch(source);
  }
}
