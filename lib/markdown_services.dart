import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'markdown_page.dart' as pd;

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

class GoogleStorageMarkdownService extends MarkdownService {
  static const google_storage = 'https://storage.googleapis.com';

  // This is where we find the markdown files on Google Storage.
  //
  static const bucket = 'rokrust-fs2.appspot.com';
  static const dir = 'sky';
  static const media = 'media/';

  static const fileServiceMap = {
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

  GoogleStorageMarkdownService({String imageDir = media}) : super(imageDir);

  @override
  Future<void> init() async {
    return Future.value();
  }

  String get imageDir => '$google_storage/$bucket/$dir/';

  // TODO: Hvorfor stopper denne på exception i debuggeren?
  @override
  Future<String?>? load(String nodeName) async {
    final fileName = fileServiceMap[nodeName];
    return (fileName != null) ? await getFileFromStorage('$bucket/$dir/$fileName') : null;
  }
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
