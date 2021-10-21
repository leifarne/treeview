import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
  final Future<String?>? markdownFuture;
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
        child: FutureBuilder<String?>(
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
