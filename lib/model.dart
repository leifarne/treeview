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
