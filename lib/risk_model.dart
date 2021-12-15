import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart' as excel;
import 'page_model.dart';

typedef JSON = Map<String, dynamic>;

enum Approval { accept, acceptWithActions, reject }

extension xx on Approval {
  static const name = [
    'Accept',
    'Accept w/mitigation',
    'Reject',
  ];

  String getName(int i) => name[i];
}

class Assessment {
  String id;
  Approval approval;
  String approvedBy;
  DateTime approvedOn;

  Assessment(this.id, this.approval, this.approvedBy, this.approvedOn);

  String getApprovalValues() {
    return approval.getName(0);
  }
}

class Risk {
  String id;
  String area;
  String title;
  String term;
  String assessment;

  Risk(this.id, this.area, this.title, this.term, this.assessment);
}

class RiskEntity {
  String id;
  String area;
  String title;
  String term;
  String assessment;

  RiskEntity(this.id, this.area, this.title, this.term, this.assessment);

  static RiskEntity? fromExcel(List<excel.Data?> cells) {
    if (!_valid(cells)) return null;
    return RiskEntity(
      cells[0]!.value as String,
      cells[1]!.value as String,
      cells[2]!.value as String,
      cells[3]!.value as String,
      cells[4]!.value as String,
    );
  }

  Risk toRisk() {
    return Risk(id, area, title, term, assessment);
  }

  factory RiskEntity.fromRisk(Risk risk) {
    return RiskEntity(risk.id, risk.area, risk.title, risk.term, risk.assessment);
  }

  JSON toJson() {
    return {
      'id': id,
      'area': area,
      'title': title,
      'risk': term,
      'recommendation': assessment,
    };
  }

  static bool _valid(List<excel.Data?> cells) {
    return cells.every((element) => element != null);
  }
}

/// The risk model that we interact with
///
class CTGModel extends ChangeNotifier {
  CloudProviders cloudProvider = CloudProviders.MSAzure;
  Roles role = Roles.Reseller;
  Jurisdictions jurisdiction = Jurisdictions.Norway;
  Industries industry = Industries.Public;

  List<String> pages = [];
  List<Risk> risks = [];
  List<Assessment> assessments = [];

  void setApproval(int i, Approval approval) {
    assessments[i].approval = approval;
    notifyListeners();
  }

  void setRisks(List<Risk> risks) {
    this.risks = risks;
    notifyListeners();
  }
}

/// Which page are we currently viewing
/// Trigger when a node in the tree is clicked.
///
class CTGPageView extends ChangeNotifier {
  String title;
  String fileName;

  CTGPageView(this.title, this.fileName);

  // Future<String?>? _markdownFuture;
  // ValueKey<String>? _markdownKey;

  // Future<String?>? get markdownFuture => _markdownFuture;
  // ValueKey<String>? get markdownKey => _markdownKey;

  void setTitle(String title, String fileName) {
    this.title = title;
    this.fileName = fileName;
    // this._markdownFuture = markdownFuture;
    // this._markdownKey = ValueKey<String>(title);

    notifyListeners();
  }
}

/// The client context model that we interact with
///
class ClientContextModel extends ChangeNotifier {
  CloudProviders _cloudProvider = CloudProviders.MSAzure;
  Roles _role = Roles.Reseller;
  Jurisdictions _jurisdiction = Jurisdictions.Norway;
  Industries _industry = Industries.Public;
  Programs _program = Programs.CSP;

  CloudProviders get cloudProvider => this._cloudProvider;

  set cloudProvider(CloudProviders v) {
    this._cloudProvider = v;
    notifyListeners();
  }

  Jurisdictions get jurisdiction => this._jurisdiction;

  set jurisdiction(Jurisdictions v) {
    this._jurisdiction = v;
    notifyListeners();
  }

  Roles get role => this._role;

  set role(Roles v) {
    this._role = v;
    notifyListeners();
  }

  Industries get industry => this._industry;

  set industry(Industries v) {
    this._industry = v;
    notifyListeners();
  }

  Programs get program => this._program;

  set program(Programs v) {
    this._program = v;
    notifyListeners();
  }
}

// TODO: UserModel
// TODO: RiskModel
// TODO: ActionModel
// TODO: ContentModel


