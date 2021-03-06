import 'package:built_collection/built_collection.dart';
import 'package:demo_bloc_pattern/api/book_api.dart';
import 'package:demo_bloc_pattern/pages/detail_page/detail_bloc.dart';
import 'package:demo_bloc_pattern/pages/detail_page/detail_page.dart';
import 'package:demo_bloc_pattern/pages/fav_page/fav_books_bloc.dart';
import 'package:demo_bloc_pattern/pages/fav_page/fav_books_state.dart';
import 'package:demo_bloc_pattern/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';

class FavoritedBooksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<FavBooksBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorited books'),
      ),
      body: StreamBuilder<FavBooksState>(
        stream: bloc.state$,
        initialData: bloc.state$.value,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state.isLoading) {
            return Container(
              constraints: BoxConstraints.expand(),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return FavBooksList(items: state.books);
        },
      ),
    );
  }
}

class FavBooksList extends StatelessWidget {
  final BuiltList<FavBookItem> items;

  const FavBooksList({Key key, @required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<FavBooksBloc>(context);

    return RefreshIndicator(
      onRefresh: bloc.refresh,
      child: Container(
        constraints: BoxConstraints.expand(),
        child: ListView.builder(
          itemCount: items.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) =>
              FavBookItemWidget(item: items[index]),
        ),
      ),
    );
  }
}

class FavBookItemWidget extends StatelessWidget {
  final FavBookItem item;

  const FavBookItemWidget({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<FavBooksBloc>(context);
    return Dismissible(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return Consumer2<SharedPref, BookApi>(
                  builder: (context, sharedPref, bookApi) {
                    return DetailPage(
                      initBloc: () {
                        return DetailBloc(
                          bookApi,
                          sharedPref,
                          item.toBookModel(),
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
        child: Container(
          constraints: BoxConstraints.expand(height: 250),
          margin: EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Hero(
                  tag: item.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: FadeInImage.assetNetwork(
                      image: item.thumbnail ?? '',
                      width: 64.0 * 1.8,
                      height: 96.0 * 1.8,
                      fit: BoxFit.cover,
                      placeholder: 'assets/no_image.png',
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(right: 64.0 * 1.8 * 0.6),
                  constraints: BoxConstraints.expand(),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 16,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        item.isLoading ? 'Loading...' : item.title,
                        maxLines: 2,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.isLoading
                            ? 'Loading...'
                            : (item.subtitle == null || item.subtitle.isEmpty
                                ? 'No subtitle...'
                                : item.subtitle),
                        maxLines: 2,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => bloc.removeFavorite(item.id),
      key: ValueKey(item.id),
    );
  }
}
