import 'theming.dart';
import 'front_page_model.dart' as fpm;
import 'package:flutter/material.dart';

class FrontPage extends StatefulWidget {
  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  List<fpm.FrontPageContent>? _content;

  @override
  void initState() {
    super.initState();
    fpm.getInstance().then((value) => setState(() => _content = value));
  }

  @override
  Widget build(BuildContext context) {
    if (_content == null) {
      return Text('');
    }

    return TextButtonTheme(
      data: buildFrontPageTextButtonThemeData(),
      child: ElevatedButtonTheme(
        data: buildFrontPageElevatedButtonThemeData(),
        child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Cloud Terms Guide'),
                  SizedBox(width: 40),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Products'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Pricing'),
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(80, 30)),
                      // backgroundColor: MaterialStateProperty.resolveWith(getColor),
                      // foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 24),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => login(context),
                    child: Text('Login'),
                    style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size(80, 30))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Register'),
                    style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size(80, 30))),
                  ),
                )
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('img/cloud-trends.jpeg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.white70, BlendMode.lighten),
                ),
              ),
              child: Scrollbar(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  maxWidth: 1000,
                  child: Container(
                    alignment: Alignment.topCenter,
                    constraints: BoxConstraints(
                      // minWidth: 400,
                      maxWidth: 1000,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      // gradient: RadialGradient(center: Alignment(0.7, 0.7), radius: 0.5, colors: [kFrontPageDarkGradient, kFrontPageLightGradient], stops: [0, 1]),
                      // backgroundBlendMode: BlendMode.srcOver,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 200),
                            child: ProductTile(
                              img: _content![0].url,
                              title: _content![0].title,
                              subtitle: _content![0].subtitle!,
                              textFirst: false,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 600),
                            child: ProductTile(
                              img: _content![1].url,
                              title: _content![1].title,
                              subtitle: _content![1].subtitle!,
                              textFirst: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    Navigator.pushReplacementNamed(context, '/home');
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile({Key? key, required this.title, required this.subtitle, required this.img, this.action, this.textFirst = false}) : super(key: key);

  final String title;
  final String subtitle;
  final String img;
  final Widget? action;
  final bool textFirst;

  @override
  Widget build(BuildContext context) {
    var image = _buildImage();
    var text = _buildMessage();

    List<Widget> list;
    if (textFirst) {
      list = [text, image];
    } else {
      list = [image, text];
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: list,
    );
  }

  Widget _buildMessage() {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ProductMessage(title: title, subtitle: subtitle),
      ),
    );
  }

  Widget _buildImage() {
    return Expanded(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            // width: 100,
            // height: 200,
            decoration: BoxDecoration(
              // color: const Color(0xff7c94b6),
              image: DecorationImage(
                image: NetworkImage(img),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            // child: Image.network(
            //   img,
            //   fit: BoxFit.fill,
            // ),
          ),
        ));
  }
}

class ProductMessage extends StatelessWidget {
  const ProductMessage({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold, color: Colors.black);
    TextStyle subTitleStyle = Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Text(title, style: titleStyle),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(subtitle, style: subTitleStyle),
        ),
      ],
    );
  }
}
