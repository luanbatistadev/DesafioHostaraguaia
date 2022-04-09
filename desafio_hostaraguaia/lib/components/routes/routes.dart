import 'package:desafio_hostaraguaia/models/pokemon.dart';
import 'package:desafio_hostaraguaia/screens/favorite_page/favorite_screen.dart';
import 'package:desafio_hostaraguaia/screens/home_page/home_screen.dart';
import 'package:desafio_hostaraguaia/screens/pokemon_page/pokemon_screen.dart';
import 'package:desafio_hostaraguaia/screens/result_page/result_screen.dart';
import 'package:desafio_hostaraguaia/screens/search_page.dart/search_page.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/result':
        // Validation of correct data type
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ResultPage(
              pokemonName: args,
            ),
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchPage());
      case '/favorite':
        return MaterialPageRoute(builder: (_) => const FavoriteScreen());
      case '/pokemon':
        if (args is Pokemon) {
          return MaterialPageRoute(
              builder: (_) => PokemonPage(
                    pokemon: args,
                  ));
        }
        return _errorRoute();
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
