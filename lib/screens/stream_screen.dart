import 'dart:async';

import 'package:flutter/material.dart';

class StreamScreen extends StatefulWidget {
  const StreamScreen({super.key});

  @override
  State<StreamScreen> createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> {
  // StreamController — «труба»: значення додаємо через add(), екран слухає stream.
  final StreamController<int> _controller = StreamController<int>();
  Timer? _timer;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _counter++;
      _controller.add(_counter);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stream: лічильник')),
      body: Center(
        child: StreamBuilder<int>(
          stream: _controller.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Помилка: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Text('Очікування першого значення...');
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Значення: ${snapshot.data}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text('Стан: ${snapshot.connectionState.name}'),
              ],
            );
          },
        ),
      ),
    );
  }
}