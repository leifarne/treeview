import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

import 'markdown_services.dart';
import 'simple_markdown_view.dart';

void main() {
  runApp(MyApp());
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

const bucket = 'rokrust-fs2.appspot.com';
const dir = 'sky';
const media = 'media';

class _MyHomePageState extends State<MyHomePage> {
  late MarkdownService _service;
  Future<String?>? _markdownFuture;
  late ValueKey<String> _markdownKey;

  @override
  void initState() {
    super.initState();

    _service = GoogleStorageMarkdownService(bucket: bucket, dir: dir);
    // _service = MemoryMarkdownService();

    _markdownFuture = _service.load('Being a Cloud Reseller');
    _markdownKey = ValueKey('Being a Cloud Reseller');
  }

  /// hvor er simpelmarkdownview? state
  /// hvor skal servcie init? i homepagestate inistate
  /// parm til SimpleMarkdown? filename, service?
  /// skifter ikke state, kun rebuild
  ///
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
            SizedBox(width: 800, child: SimpleMarkdownView(_markdownFuture, _service.imageDir, key: _markdownKey)),
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
                  _markdownFuture = _service.load(n.title);
                  _markdownKey = ValueKey(n.title);
                });
              },
            ))
        ]),
      ],
    );
  }
}

enum Programs { MOSA, CSPIndirectReseller, CSP }
enum Roles { Reseller, SystemIntegrator, Customer }
enum CloudProviders { AWS, MSAzure, Google }
enum Industries { Finance, Retail, Public, Telecom, Energy }
enum Jurisdictions { Norway, Sweden, Denmark, EU, UK, US }

class MDPageNode {
  final String title;
  final Set<Programs>? programs;
  final Set<Roles>? roles;
  final CloudProviders? provider;
  final Set<Industries>? industries = const {Industries.Public};
  final Set<Jurisdictions>? jurisdictions = const {Jurisdictions.Norway};

  const MDPageNode({
    required this.title,
    this.provider,
    this.roles,
    this.programs,
  });
}

const List<MDPageNode> allPages = [
  MDPageNode(title: 'Being a Cloud Reseller'),
  MDPageNode(title: 'MS Reseller Overview', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}),
  MDPageNode(title: 'MS CSP', provider: CloudProviders.MSAzure, programs: {Programs.CSP}, roles: {Roles.Reseller}),
  MDPageNode(title: 'MS Partner Agreement', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller}),
  MDPageNode(title: 'MS Customer Agreement', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller}),
  MDPageNode(title: 'Distributor Agreement', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller}),
  MDPageNode(title: 'Hosting Exception', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller, Programs.CSP}),
  MDPageNode(title: 'MOSA', provider: CloudProviders.MSAzure, roles: {Roles.Reseller, Roles.Customer}, programs: {Programs.MOSA}),
  MDPageNode(title: 'Google Reseller Overview', provider: CloudProviders.Google),
];
