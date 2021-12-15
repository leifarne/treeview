import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:treeview/page_model.dart';
import 'config.dart' as cfg;

import 'package:provider/provider.dart';
import 'package:treeview/risk_model.dart';

import 'front_page.dart';
import 'markdown_services.dart';
import 'simple_markdown_view.dart';
import 'simple_tree_view.dart';
import 'theming.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<TreeReader>(
          create: (context) => FileTreeReader(
            fileLoader: GoogleStorageHttpLoader(),
            fileName: 'tree.json',
          ),
        ),
        Provider(create: (context) => ExcelService(loader: GoogleStorageHttpLoader())),
        // Provider<MarkdownService>(create: (context) => MemoryMarkdownService()),
        Provider<MarkdownService>(
            create: (context) => FileMarkdownService(
                  imageDir: 'https://storage.googleapis.com/rokrust-fs2.appspot.com/sky',
                  markdownLoader: GoogleStorageHttpLoader(),
                )),
        ChangeNotifierProvider(create: (context) => CTGModel()),
        ChangeNotifierProvider(create: (context) => CTGPageView('Being a Cloud Reseller', "being-a-cloud-reseller.md")),
        ChangeNotifierProvider(create: (context) => ClientContextModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Terms Guide',
      theme: buildCloudThemeIndigo3(),
      // home: HomePage(title: 'Cloud Terms Guide'),
      routes: {'/': (context) => FrontPage(), '/home': (context) => HomePage(title: 'Cloud Terms Guide')},
      initialRoute: cfg.kInitialRoute,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> ex() async {
    final service = context.read<ExcelService>();
    final risks = await service.load('ms-risks.xlsx');
    final model = context.read<CTGModel>();
    model.setRisks(risks);
  }

  @override
  Widget build(BuildContext context) {
    final clientContext = context.read<ClientContextModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'Dashboard'), Tab(text: 'Library'), Tab(text: 'Risk')],
        ),
        actions: [
          CTGDropdown<Jurisdictions>(Jurisdictions.values, cfg.jurisdictionHint, clientContext.jurisdiction, null),
          CTGDropdown<Industries>(Industries.values, cfg.industryHint, clientContext.industry, (v) => clientContext.industry = v!),
          CTGDropdown<CloudProviders>(CloudProviders.values, cfg.cloudProviderHint, clientContext.cloudProvider, (v) => clientContext.cloudProvider = v!),
          CTGDropdown<Roles>(Roles.values, cfg.commercialRoleHint, clientContext.role, (v) => clientContext.role = v!),
          CTGDropdown<Programs>(Programs.values, cfg.programHint, clientContext.program, (v) => clientContext.program = v!),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [Center(child: Text('Dashboard')), MarkdownLibraryPage(), RiskAssessment()],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: ex,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class RiskAssessment extends StatefulWidget {
  const RiskAssessment({Key? key}) : super(key: key);

  static const _headers = <String>['ID', 'Area', 'Title', 'Term', 'Assessment'];

  @override
  State<RiskAssessment> createState() => _RiskAssessmentState();
}

class _RiskAssessmentState extends State<RiskAssessment> {
  late ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var riskModel = context.watch<CTGModel>().risks;

    return SingleChildScrollView(
      controller: _controller,
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(50),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(4),
        },
        defaultColumnWidth: FixedColumnWidth(90),
        border: TableBorder.all(color: Colors.grey.shade300),
        children: [
          TableRow(
              decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2))),
              children: RiskAssessment._headers.map((e) => PaddedText(e, fontWeight: FontWeight.bold)).toList()),
          for (var i = 0; i < riskModel.length; i++)
            TableRow(children: [
              PaddedText(riskModel[i].id),
              PaddedText(riskModel[i].area),
              PaddedText(riskModel[i].title),
              PaddedText(riskModel[i].term),
              PaddedText(riskModel[i].assessment),
            ]),
        ],
      ),
    );
  }
}

class PaddedText extends StatelessWidget {
  final String text;
  final FontWeight? fontWeight;

  const PaddedText(this.text, {Key? key, this.fontWeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(text, style: TextStyle(fontWeight: this.fontWeight)),
    );
  }
}

/// Markdown library viewer page
/// with Tree view clickable
/// State is which page name is current in CTGModel
class MarkdownLibraryPage extends StatefulWidget {
  MarkdownLibraryPage({Key? key}) : super(key: key);

  @override
  _MarkdownLibraryPageState createState() => _MarkdownLibraryPageState();
}

class _MarkdownLibraryPageState extends State<MarkdownLibraryPage> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final tree = context.read<TreeReader>().tree;
      if (tree != null) {
        context.read<CTGPageView>().setTitle(tree[0].title, tree[0].markDownFile!);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 400,
            height: double.infinity,
            child: Card(
              child: MDTreeView(),
            ),
          ),
          Expanded(
            flex: 5,
            // child: Center(
            //     child: ColoredBox(
            //   color: Colors.red,
            //   child: Text('hei'),
            // )),
            child: Consumer<CTGPageView>(
              builder: (context, value, child) {
                return SimpleMarkdownView(
                  name: value.fileName,
                  key: ValueKey<String>(value.fileName),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CTGDropdown<T> extends StatelessWidget {
  final List<T> items;
  final String hint;
  final T? value;
  final void Function(T?)? onChanged;

  const CTGDropdown(this.items, this.hint, this.value, this.onChanged, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(4)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                items: items
                    .map((label) => DropdownMenuItem<T>(
                          child: Text(describeEnum(label as Enum)),
                          value: label,
                        ))
                    .toList(),
                hint: Text(
                  hint,
                  style: TextStyle(fontStyle: FontStyle.italic),
                  textScaleFactor: 0.9,
                ),
                onChanged: onChanged,
              ),
            )));
  }
}
