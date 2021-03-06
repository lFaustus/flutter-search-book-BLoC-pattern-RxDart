import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:demo_bloc_pattern/model/book_model.dart';
import 'package:meta/meta.dart';

part 'fav_books_state.g.dart';

abstract class FavBooksState
    implements Built<FavBooksState, FavBooksStateBuilder> {
  bool get isLoading;

  BuiltList<FavBookItem> get books;

  FavBooksState._();

  factory FavBooksState([updates(FavBooksStateBuilder b)]) = _$FavBooksState;

  factory FavBooksState.initial() {
    return FavBooksState((b) => b
      ..isLoading = true
      ..books = ListBuilder<FavBookItem>());
  }
}

abstract class FavBookItem implements Built<FavBookItem, FavBookItemBuilder> {
  bool get isLoading;

  String get id;

  @nullable
  String get title;

  @nullable
  String get subtitle;

  @nullable
  String get thumbnail;

  FavBookItem._();

  factory FavBookItem([updates(FavBookItemBuilder b)]) = _$FavBookItem;

  Book toBookModel() {
    return Book(
      publishedDate: null,
      largeImage: null,
      authors: null,
      description: null,
      thumbnail: thumbnail,
      id: id,
      subtitle: subtitle,
      title: title,
    );
  }
}

@immutable
abstract class FavBookPartialChange {}

class FavIdsListChange implements FavBookPartialChange {
  final List<String> ids;

  const FavIdsListChange(this.ids);
}

class LoadedFavBookChange implements FavBookPartialChange {
  final Book book;

  const LoadedFavBookChange(this.book);
}

class ErrorFavBookChange implements FavBookPartialChange {
  final error;

  const ErrorFavBookChange(this.error);
}
