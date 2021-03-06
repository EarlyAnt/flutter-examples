import 'package:flutter/material.dart';
import 'router/application.dart';
import 'router/routers.dart';
import 'package:fluro/fluro.dart';
import 'dart:async';
import 'ui/transition_page.dart';
import 'res/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common/events.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {


  MyApp()  {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }
  // This widget is the root of your application.
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}




class _MyAppState extends State<MyApp>{

  Color _primaryColor;
  StreamSubscription _colorSubscription;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //取消订阅
    _colorSubscription.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setThemeColor();
    //showAlertDialog(context);
    //订阅eventbus
    _colorSubscription = eventBus.on<ThemeColorEvent>().listen((event) {
      //缓存主题色
      _cacheColor(event.colorStr);
      Color color = AppColors.getColor(event.colorStr);
      setState(() {
        _primaryColor = color;
        Fluttertoast.showToast(msg: "eventBus");
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: _primaryColor,
      ),
      home: TransitionPage(),
      onGenerateRoute: Application.router.generator,
    );
  }


  _cacheColor(String colorStr) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("themeColorStr", colorStr);
  }

  Future<String> _getCacheColor(String colorKey) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String colorStr = sp.getString(colorKey);
    return colorStr;
  }

  void _setThemeColor() async {
    String cacheColorStr = await _getCacheColor("themeColorStr");
    setState(() {
      _primaryColor = AppColors.getColor(cacheColorStr);
    });
  }

}


void showAlertDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) =>
      new AlertDialog(
          title: new Text("Dialog Title"),
          content: new Text("This is my content"),
          actions: <Widget>[
            new FlatButton(child: new Text("CANCEL"), onPressed: () {
              Navigator.of(context).pop();
            },),
            new FlatButton(child: new Text("OK"), onPressed: () {
              Navigator.of(context).pop();
            },)
          ]

      ));
}
