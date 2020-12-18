import 'dart:ui';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wechat_flutter/http/api.dart';
import 'package:wechat_flutter/tools/wechat_flutter.dart';
import 'package:wechat_flutter/provider/global_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wechat_flutter/pages/login/image_code.dart';

class ImageCodeWidget extends StatefulWidget {
  @override
  _ImageCodeWidgetState createState() => _ImageCodeWidgetState();
}


class _ImageCodeWidgetState extends State<ImageCodeWidget> {
  var _imageStr = ''; //验证码
  var _counter = 0;
  var _button_name = '';

  @override
  void initState() {
    super.initState();
    imageCodeDialog();
    // Additional initialization of the State
  }

  void imageCodeDialog() {
    Map testMap = {
      "userName": "xxxxxx",
      "data": {"codeType": "1"},
      "sign": ""
    };
    getImgCode(context, testMap, (v) {
      if (v == null) {
        showToast(context, '获取图片验证码失败');
        return;
      }
      _imageStr = v['imageStr'];
      _button_name = 'hello';
      print(_imageStr);
      setState(() {});
    });
  }

  Widget buildButton(String text,
      Function onPressed, {
        Color color = Colors.white,
      }) {
    return FlatButton(
      color: color,
      child: Text(text),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Material(
            child: GestureDetector(
              child:
              _imageStr =='' ? Text(""):
                 Image.memory(
                 base64.decode(_imageStr),
                //设置高度
                //设置宽度
                fit: BoxFit.cover,
                //填充
                gaplessPlayback: false, //重绘
              ),
              onTap: () {
                imageCodeDialog();
              },
            ),
            color: Colors.white,
          ),
        ]
        ,
      )
      ,
    );
  }
}