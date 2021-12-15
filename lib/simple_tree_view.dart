import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:treeview/risk_model.dart';
import 'package:provider/provider.dart';

import 'markdown_services.dart';
import 'page_model.dart';

class MDTreeView extends StatefulWidget {
  const MDTreeView({Key? key}) : super(key: key);

  @override
  _MDTreeViewState createState() => _MDTreeViewState();
}

class _MDTreeViewState extends State<MDTreeView> {
  Future<List<MDPageNode>>? treeFuture;

  @override
  void initState() {
    treeFuture = context.read<TreeReader>().load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<MDPageNode>>(
        future: treeFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            final nodes = snapshot.data!;
            return _buildMDTreeView(nodes);
          }

          return Text('Nothing here...');
        },
      ),
    );
  }

  Widget _buildMDTreeView(List<MDPageNode> pageTree) {
    return SingleChildScrollView(
      child: TreeView(
        indent: 10,
        nodes: [
          TreeNode(content: Text('Microsoft'), children: [
            for (var n in pageTree)
              if (n.children != null)
                TreeNode(content: Text(n.title, overflow: TextOverflow.ellipsis), children: [
                  for (var m in n.children!) _buildTreeNode(m),
                ])
              else
                _buildTreeNode(n),
          ]),
        ],
      ),
    );
  }

  TreeNode _buildTreeNode(MDPageNode n) {
    /*
    gjør denne til en notifier
    det er samhandling mellom treeview og markdown panel    PageViewModel
    
    */
    return TreeNode(
      content: TextButton(
        child: Text(n.title, overflow: TextOverflow.ellipsis),
        onPressed: () {
          context.read<CTGPageView>().setTitle(n.title, n.markDownFile!);
        },
      ),
    );
  }
}
