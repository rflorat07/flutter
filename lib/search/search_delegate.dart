import 'package:flutter/material.dart';

import '../models/models.dart';
import 'package:provider/provider.dart';
import 'package:fl_peliculas/providers/movies_provider.dart';

class MovieSearchDelegate extends SearchDelegate {
  @override
  String? get searchFieldLabel => 'Buscar Películas';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text('buildResults');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _emptyContainer();
    }

    final movieProvider = Provider.of<MoviesProvider>(context, listen: false);
    movieProvider.getSuggestiondByQuey(query);

    return StreamBuilder(
        stream: movieProvider.suggestionStream,
        builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
          if (!snapshot.hasData) return _emptyContainer();

          final movie = snapshot.data!;

          return ListView.builder(
              itemCount: movie.length,
              itemBuilder: (_, int index) => _MovieItem(movie: movie[index]));
        });
  }
}

Widget _emptyContainer() {
  return const Center(
      child: Icon(Icons.movie_creation_outlined,
          color: Colors.black38, size: 130));
}

class _MovieItem extends StatelessWidget {
  final Movie movie;

  const _MovieItem({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    movie.heroId = 'search-${movie.id}';

    return ListTile(
      leading: Hero(
        tag: movie.heroId!,
        child: FadeInImage(
          placeholder: const AssetImage('assets/no-image.jpg'),
          image: NetworkImage(movie.fullPosterImg),
          width: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(movie.title),
      subtitle: Text(movie.originalTitle),
      onTap: () {
        Navigator.pushNamed(context, 'details', arguments: movie);
      },
    );
  }
}
