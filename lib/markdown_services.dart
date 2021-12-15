import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:treeview/page_model.dart';
import 'package:treeview/risk_model.dart';
import 'dart:convert' as convert;
// import 'markdown_page.dart' as pd;
import 'markdown2.dart' as pd;
import 'page_data.dart';

abstract class TreeReader {
  List<MDPageNode>? tree;
  Future<List<MDPageNode>>? treeFuture;
  Future<List<MDPageNode>> load();
}

class StaticTreeReader extends TreeReader {
  @override
  Future<List<MDPageNode>> load() {
    return Future.value(allPages);
  }
}

class StaticJSONTreeReader extends TreeReader {
  static const fileServiceMap = <String, dynamic>{
    'Being a Cloud Reseller': null,
    'MS Reseller Overview': null,
    'MS CSP': null,
    'MS Partner Agreement': null,
    'MCA': {
      'Key findings': null,
      'Detailed walkthrough': null,
    },
    'Distributor Agreement': null,
  };

  StaticJSONTreeReader() {
    this.tree = fileServiceMap.entries.map<MDPageNode>((e) {
      return MDPageNode(
        title: e.key,
        children: (e.value is Map) ? (e.value as Map<String, dynamic>).entries.map((e) => MDPageNode(title: e.key)).toList() : null,
      );
    }).toList();
  }

  @override
  Future<List<MDPageNode>> load() {
    return Future.value(tree);
  }
}

class FileTreeReader extends TreeReader {
  // static const JSONFileName = 'tree.json';
  final String fileName;
  final FileLoader fileLoader;

  FileTreeReader({required this.fileLoader, required this.fileName});

  @override
  Future<List<MDPageNode>> load() async {
    /*
    future builder Tree view
    samme mønster som markdown
    den trenger ikke å si fra til noen
    TreeViewWidget med futurebuilder
    */

    if (this.tree == null) {
      String jsonString = await fileLoader.load(fileName);
      var json = convert.jsonDecode(jsonString) as List<dynamic>;
      this.tree = json.map<MDPageNode>((e) => MDPageNode.fromJson(e)).toList();
    }

    return this.tree!;
  }
}

/// Markdown services section
///

abstract class MarkdownService {
  final String imageDir;

  MarkdownService(this.imageDir);

  Future<void> init();
  Future<String?>? load(String name);
}

class MemoryMarkdownService extends MarkdownService {
  static const pageMap = {
    'Being a Cloud Reseller': pd.md,
    'MS Reseller Overview': 'No data for node',
    'MS CSP': 'No data for node',
    'MS Partner Agreement': 'No data for node',
    'MS Customer Agreement': 'No data for node',
  };

  MemoryMarkdownService({String imageDir = './'}) : super(imageDir);

  @override
  Future<void> init() {
    return Future.value();
  }

  @override
  Future<String?>? load(String nodeName) {
    final md = pageMap[nodeName] ?? 'No node';
    return Future.value(md);
  }
}

class FileMarkdownService extends MarkdownService {
  static const media = './';

  // static const fileServiceMap = <String, dynamic>{
  //   'Being a Cloud Reseller': 'being-a-cloud-reseller.md',
  //   'MS Reseller Overview': 'ms-reseller-overview.md',
  //   'MS CSP': 'ms-csp.md',
  //   'MS Partner Agreement': 'ms-mpa.md',
  //   'Key findings': 'ms-mca-key-findings.md',
  //   'Detailed walkthrough': 'ms-mca-detailed-walkthrough.md',
  //   'Distributor Agreement': 'ms-distributor-agreement.md',
  //   'Hosting Exception': 'ms-hosting-exception.md',
  //   'MOSA': 'ms-mosa.md',
  //   'Google Reseller Overview': 'goog-reseller-overview.md',
  // };

  final FileLoader markdownLoader;

  FileMarkdownService({String imageDir = media, required this.markdownLoader}) : super(imageDir);

  @override
  Future<void> init() async {
    return Future.value();
  }

  // TODO: Hvorfor stopper denne på exception i debuggeren?
  //
  @override
  Future<String?>? load(String fileName) async {
    // final fileName = fileServiceMap[nodeName];
    try {
      return await markdownLoader.load(fileName);
    } on Exception {
      return null;
    }
  }
}

/// Loader section
///

abstract class FileLoader {
  Future<String> load(String fileName);
  Future<Uint8List> loadAsBytes(String fileName);
}

class GoogleStorageHttpLoader extends FileLoader {
  static const scheme = 'https';
  static const host = 'storage.googleapis.com';

  // This is where we find the markdown files on Google Storage.
  // https://storage.googleapis.com/rokrust-fs2.appspot.com/sky
  //
  final String bucket;
  final String dir;

  GoogleStorageHttpLoader({this.dir = 'sky', this.bucket = 'rokrust-fs2.appspot.com'});

  // String get imageDir => '$scheme://$host/$bucket/$dir/';

  Future<String> load(String fileName) async {
    final path = '$bucket/$dir/$fileName';
    Uri uri = Uri(scheme: scheme, host: host, path: path);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final html = convert.utf8.decode(response.bodyBytes);
      return html;
    } else {
      throw Exception('[${response.statusCode}] $fileName does not exist.');
    }
  }

  Future<Uint8List> loadAsBytes(String fileName) async {
    final path = '$bucket/$dir/$fileName';
    Uri uri = Uri(scheme: scheme, host: host, path: path);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('[${response.statusCode}] $fileName does not exist.');
    }
  }
}

class FileSystemLoader extends FileLoader {
  @override
  Future<String> load(String fileName) async {
    final bytes = await File(fileName).readAsString();
    return bytes;
  }

  @override
  Future<Uint8List> loadAsBytes(String fileName) async {
    final bytes = await File(fileName).readAsBytes();
    return bytes;
  }
}

/// Excel section
/// = "c:\\ms-risks.xlsx"

class ExcelService {
  FileLoader loader;

  ExcelService({required this.loader});

  Future<List<Risk>> load(String fileName) async {
    final bytes = await loader.loadAsBytes(fileName);
    final excel = Excel.decodeBytes(bytes);

    List<Risk> risks = <Risk>[];

    excel.tables.keys.forEach((table) {
      print(table);
      print(excel.tables[table]?.maxCols);
      print(excel.tables[table]?.maxRows);

      excel.tables[table]!.rows.forEach((row) {
        final e = RiskEntity.fromExcel(row);
        if (e != null) risks.add(e.toRisk());
      });

      print('Risks read from xlsx: ${risks.length}');
    });

    return risks;
  }
}
