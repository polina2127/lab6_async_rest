import 'package:flutter/material.dart';

import '../services/async_demo.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  late final Future<String> _future;
  late final Stream<int> _stream;
  int _futureBuilds = 0;
  int _streamBuilds = 0;

  @override
  void initState() {
    super.initState();
    _future = simulateLoading(); // джерело 1: одне значення через 2 секунди
    _stream = counterStream(); // джерело 2: нове значення кожні 2 секунди
  }

  Widget _card(String title, Widget content, int builds) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            content,
            const SizedBox(height: 12),
            Text(
              'Перебудов віджета: $builds',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FutureBuilder vs StreamBuilder')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<String>(
            future: _future,
            builder: (context, snapshot) {
              _futureBuilds++;
              Widget content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                content = Text('Помилка: ${snapshot.error}');
              } else {
                content = Text('${snapshot.data}');
              }
              return _card(
                'FutureBuilder: одне значення',
                content,
                _futureBuilds,
              );
            },
          ),
          const SizedBox(height: 16),
          StreamBuilder<int>(
            stream: _stream,
            builder: (context, snapshot) {
              _streamBuilds++;
              Widget content;
              if (snapshot.hasError) {
                content = Text('Помилка: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                content = const Text('Очікування першого значення...');
              } else {
                content = Text(
                  'Значення: ${snapshot.data}',
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              }
              return _card(
                'StreamBuilder: багато значень',
                content,
                _streamBuilds,
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Future завершується один раз, тому його віджет перебудовується '
            'двічі (очікування → результат). Stream видає події постійно, '
            'тому StreamBuilder перебудовується при кожному новому значенні.',
          ),
        ],
      ),
    );
  }
}