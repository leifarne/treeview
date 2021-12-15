import 'page_model.dart';

const List<MDPageNode> allPages = [
  MDPageNode(title: 'Being a Cloud Reseller'),
  MDPageNode(title: 'MS Reseller Overview', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}),
  MDPageNode(title: 'MS CSP', provider: CloudProviders.MSAzure, programs: {Programs.CSP}, roles: {Roles.Reseller}),
  MDPageNode(title: 'MS Partner Agreement', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller}),
  MDPageNode(
    title: 'MS Customer Agreement',
    provider: CloudProviders.MSAzure,
    roles: {Roles.Reseller},
    programs: {Programs.CSPIndirectReseller},
    children: [
      MDPageNode(title: 'Key findings', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller}),
      MDPageNode(title: 'Detailed walkthrough', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller}),
    ],
  ),
  MDPageNode(title: 'Distributor Agreement', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller}),
  MDPageNode(title: 'Hosting Exception', provider: CloudProviders.MSAzure, roles: {Roles.Reseller}, programs: {Programs.CSPIndirectReseller, Programs.CSP}),
  MDPageNode(title: 'MOSA', provider: CloudProviders.MSAzure, roles: {Roles.Reseller, Roles.Customer}, programs: {Programs.MOSA}),
  MDPageNode(title: 'Google Reseller Overview', provider: CloudProviders.Google),
];
