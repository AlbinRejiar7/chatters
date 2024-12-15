extension GroupBy<K, V> on Iterable<V> {
  Map<K, List<V>> groupBy(K Function(V) keyFunction) {
    final Map<K, List<V>> map = {};
    for (var element in this) {
      final key = keyFunction(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }
}
