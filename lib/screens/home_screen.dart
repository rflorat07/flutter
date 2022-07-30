import 'package:flutter/material.dart';

import '../widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../search/search_delegate.dart';
import 'package:fl_peliculas/providers/movies_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moviesProviders = Provider.of<MoviesProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Películas en cines'),
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () => showSearch(
                    context: context, delegate: MovieSearchDelegate()),
                icon: const Icon(Icons.search_outlined))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Tarjetas ptincipales
              CradSwiper(movies: moviesProviders.onDisplayMovies),

              // Slider de palículas
              MovieSlider(
                  movies: moviesProviders.onPopularMovies,
                  title: 'Populares',
                  onNextPage: () => moviesProviders.getPopularMovies())
            ],
          ),
        ));
  }
}
