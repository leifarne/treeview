import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown/src/util.dart' as mdutil;
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'markdown_services.dart';

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
  final String name;

  SimpleMarkdownView({required this.name, Key? key}) : super(key: key);

  @override
  _SimpleMarkdownViewState createState() => _SimpleMarkdownViewState();
}

class _SimpleMarkdownViewState extends State<SimpleMarkdownView> {
  late String _imageDir;
  late Future<String?>? _markdownFuture;

  Widget _progressIndicator() => Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Colors.amber)));

  @override
  void initState() {
    MarkdownService service = context.read<MarkdownService>();
    _markdownFuture = service.load(widget.name);
    _imageDir = service.imageDir;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxWidth: 800,
      child: Card(
        elevation: 4,
        child: FutureBuilder<String?>(
          future: _markdownFuture,
          initialData: 'No data',
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              String _markdown = snapshot.data!;

              return Markdown(
                data: _markdown,
                selectable: true,
                imageDirectory: _imageDir,
                onTapLink: (text, href, title) {
                  print('Tapped: $text / $href / $title');
                  if (href != null) {
                    launch(href);
                  }
                },
                // inlineSyntaxes: [],
                extensionSet: md.ExtensionSet([], [TipSyntax()]),
                builders: {'tip': PreBuilder()},
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

class PreBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Tooltip(
      message: 'lkjhsdafklhasdlkfh',
      child: Text(
        element.textContent,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }
}

class TipSyntax extends md.InlineSyntax {
  // This pattern matches:
  //
  // * a string of backticks (not followed by any more), followed by
  // * a non-greedy string of anything, including newlines, ending with anything
  //   except a backtick, followed by
  // * a string of backticks the same length as the first, not followed by any
  //   more.
  //
  // This conforms to the delimiters of inline code, both in Markdown.pl, and
  // CommonMark.
  static final String _pattern = r'("+(?!"))((?:.|\n)*?[^"])\1(?!")';

  TipSyntax() : super(_pattern);

  final int $backquote = 0x60;

  @override
  bool tryMatch(md.InlineParser parser, [int? startMatchPos]) {
    if (parser.pos > 0 && parser.charAt(parser.pos - 1) == $backquote) {
      // Not really a match! We can't just sneak past one backtick to try the
      // next character. An example of this situation would be:
      //
      //     before ``` and `` after.
      //             ^--parser.pos
      return false;
    }

    var match = pattern.matchAsPrefix(parser.source!, parser.pos);
    if (match == null) {
      return false;
    }
    parser.writeText();
    if (onMatch(parser, match)) parser.consume(match.match.length);
    return true;
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var code = match[2]!.trim().replaceAll('\n', ' ');
    // if (parser._encodeHtml) code = escapeHtml(code);
    parser.addNode(md.Element.text('tip', code));

    return true;
  }
}
