import 'dart:async';

import 'package:fl_peliculas/helpers/debouncer.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../models/models.dart';

class MoviesProvider extends ChangeNotifier {
  final String _apiKey = '3b122cc1b16808da5a679c3c1c11cd07';
  final String _baseUrl = 'api.themoviedb.org';
  final String _language = 'it-IT';

  List<Movie> onDisplayMovies = [];
  List<Movie> onPopularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  final debouncer = Debouncer(duration: const Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionsStreamController =
      StreamController.broadcast();

  Stream<List<Movie>> get suggestionStream =>
      _suggestionsStreamController.stream;

  MoviesProvider() {
    print('MoviesProvider inicializado!!!');

    getOnDisplayMovies();
    getPopularMovies();
  }

  getOnDisplayMovies() async {
    // Await the http get response
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);

    onDisplayMovies = nowPlayingResponse.results;

    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;
    // Await the http get response
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);

    onPopularMovies = [...onPopularMovies, ...popularResponse.results];

    notifyListeners();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint,
        {'api_key': _apiKey, 'language': _language, 'page': '$page'});

    // Await the http get response
    final response = await http.get(url);
    return response.body;
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    // Await the http get response
    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie',
        {'api_key': _apiKey, 'language': _language, 'query': query});

    // Await the http get response
    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestiondByQuey(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovies(value);
      _suggestionsStreamController.add(results);
    };

    final time = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => time.cancel());
  }
}
