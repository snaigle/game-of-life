import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'life-app',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'life'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;

  @override
  _MyHomePageState createState() {
    return new _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    data = generate(width, height, false);
  }

  var width = 12;
  var height = 24;
  var randomCount = 50;
  var running = false;
  Timer timer;
  var data = List<List<bool>>();

  List<List<bool>> generate(int width, int height, bool defaultValue) {
    return List.generate(height, (_) {
      return List.generate(width, (_) => defaultValue);
    });
  }

  List<List<bool>> generateRandom(int max) {
    var r = Random();
    var count = 0;
    return List.generate(height, (_) {
      return List.generate(width, (_) {
        if (count > max) return false;
        var nextBool = r.nextInt(12) < 1;
        if (nextBool) {
          count++;
        }
        return nextBool;
      });
    });
  }

  List<Widget> generateView() {
    var child = List<Widget>();
    for (var i = 0; i < data.length; i++) {
      var rowChild = List<Widget>();
      List<bool> subList = data[i];
      for (var j = 0; j < subList.length; j++) {
        rowChild.add(
            Icon(Icons.star, color: subList[j] ? Colors.red : Colors.white));
      }
      var row = Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: rowChild,
        ),
      );
      child.add(row);
    }
    return child;
  }

  start() {
    if (running) {
      pause();
    } else {
      setState(() {
        data = generateRandom(randomCount);
      });
      running = true;
      timer = Timer.periodic(new Duration(seconds: 1), handleNewData);
    }
  }

  pause() {
    if (running) {
      timer.cancel();
      setState(() {
        running = false;
      });
    }
  }

  reset() {
    if (running) {
      timer.cancel();
      running = false;
    }
    setState(() {
      data = generate(width, height, false);
    });
  }

  void handleNewData(Timer timer) {
    var newData = List.generate(height, (i) {
      return List.generate(width, (j) {
        var n = findNeighbors(i, j);
        if (isLive(i, j)) {
          if (n < 2) {
            return false;
          } else if (n < 4) {
            return true;
          } else {
            return false;
          }
        } else {
          return n == 3;
        }
      });
    });
    var isSame = checkSame(newData, data);
    if (isSame) {
      pause();
    } else {
      setState(() {
        data = newData;
      });
    }
  }

  checkSame(List<List<bool>> a, b) {
    for (var i = 0; i < a.length; i++) {
      var row = a[i];
      for (var j = 0; j < row.length; j++) {
        var result = row[j];
        if (result != b[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  int findNeighbors(int i, int j) {
    var count = 0;
    count += isLive(i + 1, j - 1) ? 1 : 0;
    count += isLive(i + 1, j) ? 1 : 0;
    count += isLive(i + 1, j + 1) ? 1 : 0;
    count += isLive(i, j - 1) ? 1 : 0;
    count += isLive(i, j + 1) ? 1 : 0;
    count += isLive(i - 1, j - 1) ? 1 : 0;
    count += isLive(i - 1, j) ? 1 : 0;
    count += isLive(i - 1, j + 1) ? 1 : 0;
    return count;
  }

  bool isLive(int i, int j) {
    if (i == -1) {
      i = height - 1;
    }
    if (i == height) {
      i = 0;
    }
    if (j == -1) {
      j = width - 1;
    }
    if (j == width) {
      j = 0;
    }
    return data[i][j];
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Container(
          padding: const EdgeInsets.all(20.0),
          child: new Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      MaterialButton(
                        padding: EdgeInsets.all(0.0),
                        onPressed: start,
                        child: Text(running ? "暂停" : "开始"),
                      ),
                      new MaterialButton(
                        child: Text("重置"),
                        onPressed: reset,
                      ),
                      Text(
                        running ? "运行中" : "停止",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    color: Colors.grey[300],
                  ),
                  child: new Column(
                    children: generateView(),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
