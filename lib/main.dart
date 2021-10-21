import 'package:flutter/material.dart';

import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:provider/provider.dart';

import 'markdown_services.dart';
import 'model.dart';
import 'simple_markdown_view.dart';

void main() {
  runApp(
    Provider<MarkdownService>(
      create: (context) => GoogleStorageMarkdownService(),
      // create: (context) => MemoryMarkdownService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _initialNode = 'Being a Cloud Reseller';

  Future<String?>? _markdownFuture;
  late ValueKey<String> _markdownKey;

  @override
  void initState() {
    super.initState();

    _markdownFuture = context.read<MarkdownService>().load(_initialNode);
    _markdownKey = ValueKey(_initialNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildMDTreeView(),
                ],
              ),
            ),
            SizedBox(width: 800, child: SimpleMarkdownView(_markdownFuture, context.read<MarkdownService>().imageDir, key: _markdownKey)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  TreeView _buildMDTreeView() {
    return TreeView(
      nodes: [
        TreeNode(content: Text('ddd'), children: [
          for (var n in allPages)
            TreeNode(
                content: TextButton(
              child: Text(n.title),
              onPressed: () {
                setState(() {
                  _markdownFuture = context.read<MarkdownService>().load(n.title);
                  _markdownKey = ValueKey(n.title);
                });
              },
            ))
        ]),
      ],
    );
  }
}
