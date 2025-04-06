import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Key Lints Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> items = ['Item 1', 'Item 2', 'Item 3'];

  @override
  Widget build(BuildContext context) {
    // These should be flagged - missing keys
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // This should be flagged - missing key
          Container(
            color: Colors.red,
            child: const Text('Missing key'),
          ),

          // This should be flagged - missing key for each item
          ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                // Missing key here
                title: Text(items[index]),
              );
            },
          ),

          // This should not be flagged - has key
          Container(
            key: const ValueKey('container'),
            color: Colors.green,
            child: const Text('Has key'),
          ),

          // These should not be flagged - exempt or const
          const SizedBox(height: 20),
          const Divider(),

          // This should be flagged - conditional render without key
          if (items.length > 2)
            Container(
              color: Colors.blue,
              child: const Text('Conditional render'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
