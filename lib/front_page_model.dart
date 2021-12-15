// import 'package:ctg_service/firebase_service.dart' as fbs;

List<FrontPageContent>? content = content2;

Future<List<FrontPageContent>> getInstance() async {
  if (content != null) {
    return content!;
  }
  // content = await load();
  return content!;
}

// Future<List<FrontPageContent>> load() async {
//   var docs = await fbs.getList('/ctg/ctg/front-page-messages');
//   return docs.map((json) => FrontPageContent.fromJson(json)).toList();
// }

class FrontPageContent {
  static const base = 'img';
  final String url;
  String? subtitle;
  final String title;

  FrontPageContent(url, this.title, String subtitle) : this.url = '$base/$url' {
    this.subtitle = subtitle.replaceAll('\\n', '\n\n');
  }

  factory FrontPageContent.fromJson(Map<String, dynamic> json) {
    return FrontPageContent(json['image-name'], json['headline'], json['text']);
  }
}

var content2 = <FrontPageContent>[
  FrontPageContent(
    'pawel-nolbert-xe-ss5Tg2mo-unsplash.jpg',
    'Cloud Terms Guide',
    '''
Understand your rights and obligations when subscribing to (or reselling) cloud services from 
Microsoft, Amazon, Google or Alibaba.
      ''',
  ),
  FrontPageContent(
    'commercial-role.jfif',
    'Your Contract Assessed by Legal Experts',
    '''
When subscribing to a cloud service the contract is often a large set of complex legal documents. A standard contract with Microsoft consists of x documents.

The terms and conditions of these contracts are not always compliant with EU law, so to avoid non-compliance, contracts need to be cross-checked against existing legislation.

On top of this both your contract with the cloud service (and to a lesser extent the EU legal framework) is continously updated. This means there is a lot to keep track of, and that is where we can help.

Cloudtermsguide® provides tools to help you understand your contract, and suggesting policies and steps you can take to ensure compliance.
The terms of your contract will regularly be assessed by experienced legal professionals, and the guide kept up to date.
''',
  ),
];
