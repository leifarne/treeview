import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

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
  String? _fileName = 'findings.md';
  late GoogleStorageService fileService;
  Future<String>? _fileFuture;
  ValueKey<String> _markdownKey = ValueKey('Findings');

  @override
  void initState() {
    super.initState();
    fileService = GoogleStorageService(bucket: bucket, dir: dir);
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
            SizedBox(width: 800, child: SimpleMarkdownView(_fileFuture, fileService.imageDir, key: _markdownKey)),
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
                  _fileName = fileServiceMap[n.title];
                  _fileFuture = _fileName != null ? fileService.load(_fileName!) : null;
                  _markdownKey = ValueKey<String>(_fileName ?? '');
                });
              },
            ))
        ]),
      ],
    );
  }

  void _showData() {
    setState(() {
      _fileName = fileServiceMap['Being a Cloud Reseller'];
    });
  }

  void _showInfo() {
    setState(() {
      _fileName = fileServiceMap['MS Customer Agreement'];
    });
  }
}

/// Loads a markdown file from Google Storage and displays it. It uses a standard base directory for images referenced in the MD-file.
/// It takes the basic [fileName] of the markdown file as the single parameter.
///
/// Denne skal i bunnen ha en string med markdown.
/// Input-forslag:
/// Future<String>
/// service.load
/// image dir eller image builder
///
///
class SimpleMarkdownView extends StatefulWidget {
  final Future<String>? markdownFuture;
  final String imageDir;

  SimpleMarkdownView(this.markdownFuture, this.imageDir, {Key? key}) : super(key: key);

  @override
  _SimpleMarkdownViewState createState() => _SimpleMarkdownViewState();
}

class _SimpleMarkdownViewState extends State<SimpleMarkdownView> {
  late String _markdown;

  Widget _progressIndicator() => SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Colors.amber));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxWidth: 800,
      child: Card(
        elevation: 4,
        child: FutureBuilder<String>(
          future: widget.markdownFuture,
          initialData: 'No data',
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              _markdown = snapshot.data!;

              return Markdown(
                data: _markdown,
                selectable: true,
                imageDirectory: widget.imageDir,
              );
            }

            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // initial data, men ingen future.
            if (snapshot.connectionState == ConnectionState.none && snapshot.hasData) {
              return Text(snapshot.data!);
            }

            return _progressIndicator();
          },
        ),
      ),
    );
  }
}

abstract class Service {
  late String imageDir;
  Future<void> init();
  Future<String> load(String name);
}

class GoogleStorageService extends Service {
  static const google_storage = 'https://storage.googleapis.com';
  final String bucket;
  final String dir;
  final String media;

  GoogleStorageService({required this.bucket, required this.dir, this.media = ''});

  @override
  Future<void> init() async {
    return Future.value();
  }

  String get imageDir => '$google_storage/$bucket/$dir/';

  // TODO: Denne burde egentlig returnere null og ikke Future(null).
  @override
  Future<String> load(String name) async {
    return await getFileFromStorage('$bucket/$dir/$name');
  }

  // Future<String>? ll() async {
  //   Future<String>? ff = null;
  //   return ff;
  // }
}

Future<String> getFileFromStorage(String fileName) async {
  final scheme = 'https';
  final host = 'storage.googleapis.com';
  Uri uri = Uri(scheme: scheme, host: host, path: fileName);
  // TODO: rewrite getFileFromStorage to await async
  return http.get(uri).then((response) {
    if (response.statusCode == 200) {
      var html = convert.utf8.decode(response.bodyBytes);
      return html;
    } else {
      throw Exception('[${response.statusCode}] $fileName does not exist.');
    }
  });
}

const fileServiceMap = {
  'Being a Cloud Reseller': 'being-a-reseller.md',
  'MS Reseller Overview': 'ms-reseller-overview.md',
  'MS CSP': 'ms-csp.md',
  'MS Partner Agreement': 'ms-mpa.md',
  'MS Customer Agreement': 'ms-mca.md',
  'Distributor Agreement': 'ms-distributor-agreement.md',
  'Hosting Exception': 'ms-hosting-exception.md',
  'MOSA': 'ms-mosa.md',
  'Google Reseller Overview': 'goog-reseller-overview.md',
};

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
  MDPageNode(title: 'Being a Cloud Resellerx'),
  MDPageNode(title: 'MS Reseller Overview', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}),
  MDPageNode(title: 'MS CSP', provider: CloudProviders.MSAzure, programs: {Programs.CSP}, roles: {Roles.Reseller}),
  MDPageNode(title: 'MS Partner Agreement', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller}),
  MDPageNode(title: 'MS Customer Agreement', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller}),
  MDPageNode(title: 'Distributor Agreement', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller}),
  MDPageNode(title: 'Hosting Exception', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller, Programs.CSP}),
  MDPageNode(title: 'MOSA', provider: CloudProviders.MSAzure, roles: {Roles.Reseller, Roles.Customer}, programs: {Programs.MOSA}),
  MDPageNode(title: 'Google Reseller Overview', provider: CloudProviders.Google),
];
