import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker_test/color_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

//https://nobushiueshi.com/flutter色を選択させる便利なpickerプラグイン/
//https://www.fluttercampus.com/guide/261/show-color-picker-flutter/
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //appBarの色を変更する変数
  Color selectedColor = Colors.blue;
  //カラーピッカーで選択した色情報を格納する変数
  Color pickerColor = Colors.blue;
  //カラーコードを格納するString型の変数
  String colorCode = '';

  void _changeColor(Color color) {
    pickerColor = color;
  }

  //カラーピッカー操作時のメソッド
  Future _showAlertDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
              // child: ColorPicker(
              //   pickerColor: pickerColor,
              //   onColorChanged: _changeColor,
              //   // showLabel: true,
              //   pickerAreaHeightPercent: 0.8,
              // ),
              //↓カラーピッカーの型を変える場合はこの箇所を変更する
              child: BlockPicker(
            pickerColor: pickerColor, //default color
            onColorChanged: _changeColor,
          )),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () async {
                //String型のデータを保存するには、以下のようにsetStringを使用する。colorというのが適当なキー名。
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                //カラーコード格納用の変数に、pickerColorをString型へ変換した値を代入する
                colorCode = pickerColor.value.toRadixString(16);
                //カラーコード格納用の変数の値を更新する
                prefs.setString('color', colorCode);
                //選択したカラーコードをデバッグに表示
                print('選択したカラーコードは$colorCode');

                //変数selectedColorの値を最新のものへ更新する
                setState(() =>
                    selectedColor = Color(int.parse('$colorCode', radix: 16)));

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 画面起動時に読み込むメソッド
  void init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //現在保存されているカラーコードを読み込む（未保存状態の場合、カラーコード'ff03a9f4'をセットする）
      colorCode = prefs.getString('color') ?? 'ff03a9f4';
      //変数selectedColorの値を最新のものへ更新する
      selectedColor = Color(int.parse('$colorCode', radix: 16));
      //アプリ起動時のcolorCodeの値をデバックへ表示する
      print('アプリ起動時のcolorCodeの値は$colorCode');
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Color Picker"),
        backgroundColor: selectedColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '現在のカラーコードは　$colorCode',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAlertDialog(context);
        },
        child: Icon(Icons.color_lens),
      ),
    );
  }
}
