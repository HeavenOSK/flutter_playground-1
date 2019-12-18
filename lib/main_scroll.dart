import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(
        dividerColor: Colors.red,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bidirectional Scroll Page'),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({Key key}) : super(key: key);

  @override
  __BodyState createState() => __BodyState();
}

class __BodyState extends State<_Body> {
  final _verticalScrollReceiver = ScrollController();
  final _verticalScrollSender = ScrollController();

  final _horizontalScrollReceiver = ScrollController();
  final _horizontalScrollSender = ScrollController();

  @override
  void initState() {
    super.initState();

    _verticalScrollReceiver.addListener(_updateAxisVerticalOffset);
    _horizontalScrollReceiver.addListener(_updateAxisHorizontalOffset);
  }

  @override
  void dispose() {
    _verticalScrollReceiver.removeListener(_updateAxisVerticalOffset);
    _horizontalScrollReceiver.removeListener(_updateAxisHorizontalOffset);
    super.dispose();
  }

  void _updateAxisVerticalOffset() {
    _verticalScrollSender.jumpTo(_verticalScrollReceiver.offset);
  }

  void _updateAxisHorizontalOffset() {
    _horizontalScrollSender.jumpTo(_horizontalScrollReceiver.offset);
  }

  @override
  Widget build(BuildContext context) {
    const cellWidth = 80.0;
    const cellHeight = 60.0;
    const axisWidth = 40.0;
    const colCount = 20;
    const rowCount = 40;
    return Column(
      children: <Widget>[
        SizedBox(
          height: axisWidth,
          child: Row(
            children: <Widget>[
              Container(
                width: axisWidth,
                color: Colors.grey,
              ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalScrollSender,
                  children: List.generate(
                    colCount,
                    (i) => const Placeholder(
                      fallbackWidth: cellWidth,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: axisWidth,
                child: ListView(
                  scrollDirection: Axis.vertical,
                  controller: _verticalScrollSender,
                  children: List.generate(
                    rowCount,
                    (i) => const Placeholder(
                      fallbackHeight: cellHeight,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox.expand(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _verticalScrollReceiver,
                    child: SizedBox(
                      height: cellHeight * rowCount,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        controller: _horizontalScrollReceiver,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: List.generate(
                          colCount,
                          (i) => SizedBox(
                            width: cellWidth,
                            child: Column(
                              children: List.generate(
                                rowCount,
                                (i) => const Placeholder(
                                  fallbackHeight: cellHeight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}