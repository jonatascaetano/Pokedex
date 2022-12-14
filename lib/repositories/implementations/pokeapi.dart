// ignore_for_file: avoid_print

import 'dart:math';

import 'package:pokedex/models/entities/pokemon.dart';
import 'package:pokedex/repositories/interfaces/pokemon_repository.dart';
import 'package:dio/dio.dart';

class Pokeapi implements PokemonRepository {
  final String url = 'https://pokeapi.co/api/v2/';

  @override
  Future<List<Pokemon>> getMostWantedPokemons() async {
    int number = Random().nextInt(1143);
    List<Pokemon> pokemons = [];
    try {
      var response = await Dio().get('${url}pokemon/?offset=$number&limit=10');
      if (response.statusCode == 200) {
        final map = response.data;
        List<dynamic> list = map['results'];
        for (var names in list) {
          try {
            Pokemon pokemon = await getPokemonByIdOrName(search: names['name']);
            pokemons.add(pokemon);
            print("${pokemons.length} : ${pokemon.name}");
            // ignore: empty_catches
          } catch (e) {}
        }
      } else {
        throw Exception();
      }
      return pokemons;
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Pokemon> getPokemonByIdOrName({required var search}) async {
    try {
      var response1 =
          await Dio().get('${url}pokemon/${search.toString().toLowerCase()}');
      if (response1.statusCode == 200) {
        final map = response1.data;
        Pokemon pokemon = Pokemon(
          id: map['id'].toString(),
          name: map['name'],
          image: map['sprites']['other']['official-artwork']['front_default'],
          description: '',
          type: map['types'][0]['type']['name'].toString(),
          species: map['species']['name'],
          life: double.parse(map['stats'][0]['base_stat'].toString()),
          defense: double.parse(map['stats'][1]['base_stat'].toString()),
          attack: double.parse(map['stats'][2]['base_stat'].toString()),
        );
        return pokemon;
      } else {
        throw Exception();
      }
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<String> getDescriptionPokemon({required var species}) async {
    try {
      var response = await Dio().get('${url}pokemon-species/$species');
      if (response.statusCode == 200) {
        final map = response.data;
        List<dynamic> list = map['flavor_text_entries'];

        return list
            .firstWhere(
                (element) => element['language']['name'] == 'en')['flavor_text']
            .toString()
            .replaceAll('\\', ' ')
            .replaceAll('\n', ' ');
      } else {
        throw Exception();
      }
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<String>> getPokemonNames() async {
    List<String> names = [];
    try {
      var response = await Dio().get('${url}pokemon/?offset=0&limit=2000');
      if (response.statusCode == 200) {
        final map = response.data;
        List<dynamic> list = map['results'];
        for (var pokemon in list) {
          names.add(pokemon['name']);
        }
      } else {
        throw Exception();
      }
      return names;
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Pokemon>> getPokemonsByType({required String type}) async {
    List<Pokemon> pokemons = [];
    try {
      var response = await Dio().get('${url}type/$type');
      if (response.statusCode == 200) {
        final map = response.data;
        List<dynamic> list = map['pokemon'];
        print('quantidade de pokemons recuperados: ${list.length}');
        for (var item in list) {
          try {
            Pokemon pokemon =
                await getPokemonByIdOrName(search: item['pokemon']['name']);
            pokemons.add(pokemon);
            print("${pokemons.length} : ${pokemon.name}");
            // ignore: empty_catches
          } catch (e) {}
        }
      } else {
        throw Exception();
      }
      return pokemons;
    } catch (e) {
      throw Exception();
    }
  }
}
