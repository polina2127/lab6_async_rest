/// Імітує довге завантаження: чекає 2 секунди й повертає ОДНЕ значення.
Future<String> simulateLoading() async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Дані завантажено через 2 секунди';
}

/// Нескінченний потік (async*-генератор):
/// кожні 2 секунди видає наступне число.
Stream<int> counterStream() async* {
  int counter = 0;
  while (true) {
    await Future.delayed(const Duration(seconds: 2));
    counter++;
    yield counter;
  }
}