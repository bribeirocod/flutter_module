import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Login Flutter Module'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String dropdownValue = 'Add';
  int _result = 0;

  int _first = 0;
  int _second = 0;

  String resultStr = "";

  static const platform = const MethodChannel('sample.login.demo');

  _MyHomePageState() {
    platform.setMethodCallHandler(_receiveFromHost);
  }

  Future<void> _receiveFromHost(MethodCall call) async {
    int f = 0;
    int s = 0;

    try {
      print(call.method);

      if (call.method == "fromHostToClient") {
        final String data = call.arguments;
        print(call.arguments);
        final jData = jsonDecode(data);

        f = jData['first'];
        s = jData['second'];
      }
    } on PlatformException catch (e) {

    }

    setState(() {
      _first = f;
      _second = s;
    });
  }

  _addNumbers(int n1, int n2) {
    return n1 + n2;
  }

  _multiplyNumbers(int n1, int n2) {
    return n1 * n2;
  }

  // _setResults(int n1, int n2) {
  //   setState(() {
  //     if (dropdownValue == 'Add') {
  //       _result = _addNumbers(n1, n2);
  //     } else {
  //       _result = _multiplyNumbers(n1, n2);
  //     }
  //   });
  // }

  void _sendResultsToAndroidiOS() {
    if (dropdownValue == 'Add') {
      _result = _addNumbers(_first, _second);
    } else {
      _result = _multiplyNumbers(_first, _second);
    }

    Map<String, dynamic> resultMap = Map();
    resultMap['operation'] = dropdownValue;
    resultMap['result'] = _result;

    setState(() {
      resultStr = resultMap.toString();
    });

    platform.invokeMethod("FromClientToHost", resultMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('First Number: ',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                        Text(_first.toString(),
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ])),
              Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Second Number: ',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                        Text(_second.toString(),
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ])),
              Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton<String>(
                        value: dropdownValue,
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                        items: <String>['Add', 'Multiply']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue = newValue;
                          });
                        },
                      )
                    ],
                  )),
              RaisedButton(
                onPressed: () {
                  _sendResultsToAndroidiOS();
                },
                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                child: Container(
                    decoration: BoxDecoration(color: Colors.blue),
                    padding: const EdgeInsets.all(10.0),
                    child: const Text('Send Results to Android/iOS module',
                        style: TextStyle(fontSize: 16))),
              )
            ],
          ),
        ));
  }
}
