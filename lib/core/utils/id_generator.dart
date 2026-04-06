String generateEntityId() {
  final micros = DateTime.now().microsecondsSinceEpoch;
  return 'id_$micros';
}
