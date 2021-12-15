typedef JSON = Map<String, dynamic>;

enum Programs { MOSA, CSPIndirectReseller, CSP }
enum Roles { Reseller, SystemIntegrator, Customer }
enum CloudProviders { AWS, MSAzure, Google }
enum Industries { Finance, Retail, Public, Telecom, Energy }
enum Jurisdictions { Norway, Sweden, Denmark, EU, UK, US }

class MDPageNode {
  final String title;
  final String? markDownFile;
  final List<MDPageNode>? children;
  final Set<Programs>? programs;
  final Set<Roles>? roles;
  final CloudProviders? provider;
  final Set<Industries>? industries = const {Industries.Public};
  final Set<Jurisdictions>? jurisdictions = const {Jurisdictions.Norway};

  const MDPageNode({
    required this.title,
    this.markDownFile,
    this.children,
    this.provider,
    this.roles,
    this.programs,
  });

  factory MDPageNode.fromJson(JSON e) {
    if (e['children'] != null) {
      List<dynamic> jsonList = e['children'];
      var children = jsonList.map<MDPageNode>((e) => MDPageNode.fromJson(e)).toList();
      return MDPageNode(title: e['name'], children: children);
    } else {
      return MDPageNode(title: e["name"] as String, markDownFile: e["file"] as String);
    }
  }
}
