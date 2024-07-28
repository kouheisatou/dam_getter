import 'package:flutter/widgets.dart';

/// ListModel for AnimatedList
class ListModel<E> {
  ListModel({
    required this.listKey,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final List<E> _items;

  AnimatedListState? get _animatedList => listKey.currentState;

  /// on insert, register same to AnimatedList
  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList!.insertItem(index);
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);

  bool contains(E item) => _items.contains(item);
}
