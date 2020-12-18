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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //焦点
  FocusNode _focusNodeUserName = FocusNode();
  FocusNode _focusNodePassWord = FocusNode();

  //用户名输入框控制器，此控制器可以监听用户名输入框操作
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _imageCodeController = TextEditingController();

  //表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _password = ''; //用户名
  var _username = ''; //密码
  var _imagecode = ''; //验证码
  var _imageStr = ''; //验证码
  var _isShowPwd = false; //是否显示密码
  var _isShowClear = false; //是否显示输入框尾部的清除按钮

  @override
  void initState() {
    super.initState();
    initEdit();
  }

  initEdit() async {
    final user = await SharedUtil.instance.getString(Keys.account);
    _userNameController.text = user ?? '';
    //设置焦点监听
    _focusNodeUserName.addListener(_focusNodeListener);
    _focusNodePassWord.addListener(_focusNodeListener);
    //监听用户名框的输入改变
    _userNameController.addListener(() {
      print(_userNameController.text);

      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      if (_userNameController.text.length > 0) {
        _isShowClear = true;
      } else {
        _isShowClear = false;
      }
      setState(() {});
    });
  }

  // 监听焦点
  Future<Null> _focusNodeListener() async {
    if (_focusNodeUserName.hasFocus) {
      print("用户名框获取焦点");
      // 取消密码框的焦点状态
      _focusNodePassWord.unfocus();
    }
    if (_focusNodePassWord.hasFocus) {
      print("密码框获取焦点");
      // 取消用户名框焦点状态
      _focusNodeUserName.unfocus();
    }
  }

  Widget bottomItem(item) {
    return Row(
      children: <Widget>[
        InkWell(
          child: Text(item, style: TextStyle(color: tipColor)),
          onTap: () {
            showToast(context, S
                .of(context)
                .notOpen + item);
          },
        ),
        item == S
            .of(context)
            .weChatSecurityCenter
            ? Container()
            : Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: VerticalLine(height: 15.0),
        )
      ],
    );
  }

  void freshImageCode() {
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
    });
  }

  void imageCodeDialog() {
    showDialog(context: context, builder: (ctx) => ImageCodeWidget());

  }

  void imageCodeDialog1() {
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
      showAlertDialog();
    });
  }


  void showAlertDialog() {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('请输入图片验证码'),
            //可滑动
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  RaisedButton(
                    child: Image.memory(
                      base64.decode(_imageStr),
                      height: 40,
                      //设置高度
                      width: 60,
                      //设置宽度
                      fit: BoxFit.none,
                      //填充
                      gaplessPlayback: false, //重绘
                    ),
                    onPressed: () {
                      freshImageCode();
                    },
                  ),
                  TextFormField(
                    controller: _imageCodeController,
                    //设置键盘类型
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "验证码",
                      hintText: "请输入验证码",
                      //尾部添加清除按钮
                    ),
                    //验证用户名
                    validator: validateUserName,
                    //保存数据
                    onSaved: (String value) {
                      _imagecode = value;
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                color: Colors.blue[300],
                child: Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget body(GlobalModel model) {
    // logo 图片区域
    Widget logoImageArea = Container(
      alignment: Alignment.topCenter,
      // 设置图片为圆形
      child: ClipOval(
        child: Image.asset(
          "assets/images/logo.png",
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      ),
    );

    //输入文本框区域
    Widget inputTextArea = Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.white),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _userNameController,
              focusNode: _focusNodeUserName,
              //设置键盘类型
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "用户名",
                hintText: "请输入手机号",
                prefixIcon: Icon(Icons.person),
                //尾部添加清除按钮
                suffixIcon: (_isShowClear)
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    // 清空输入框内容
                    _userNameController.clear();
                  },
                )
                    : null,
              ),
              //验证用户名
              validator: validateUserName,
              //保存数据
              onSaved: (String value) {
                _username = value;
              },
            ),
            TextFormField(
              focusNode: _focusNodePassWord,
              decoration: InputDecoration(
                  labelText: "密码",
                  hintText: "请输入密码",
                  prefixIcon: Icon(Icons.lock),
                  // 是否显示密码
                  suffixIcon: IconButton(
                    icon: Icon(
                        (_isShowPwd) ? Icons.visibility : Icons
                            .visibility_off),
                    // 点击改变显示或隐藏密码
                    onPressed: () {
                      setState(() {
                        _isShowPwd = !_isShowPwd;
                      });
                    },
                  )),
              obscureText: !_isShowPwd,
              //密码验证
              validator: validatePassWord,
              //保存数据
              onSaved: (String value) {
                _password = value;
              },
            )
          ],
        ),
      ),
    );

    // 登录按钮区域
    Widget loginButtonArea = Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      height: 45.0,
      child: RaisedButton(
        color: Colors.blue[300],
        child: Text(
          S
              .of(context)
              .login,
          style: Theme
              .of(context)
              .primaryTextTheme
              .headline,
        ),
        // 设置按钮圆角
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: () {
          //点击登录按钮，解除焦点，回收键盘
          _focusNodePassWord.unfocus();
          _focusNodeUserName.unfocus();

          if (_formKey.currentState.validate()) {
            //只有输入通过验证，才会执行这里
            _formKey.currentState.save();
            imageCodeDialog();
            // login(_username, _password, context);
            print("$_username + $_password");
          }
        },
      ),
    );

    //第三方登录区域
    Widget thirdLoginArea = Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: 80,
                height: 1.0,
                color: Colors.grey,
              ),
              Text('第三方登录'),
              Container(
                width: 80,
                height: 1.0,
                color: Colors.grey,
              ),
            ],
          ),
          SizedBox(
            height: 18,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                color: Colors.green[200],
                // 第三方库icon图标
                icon: Icon(FontAwesomeIcons.weixin),
                iconSize: 40.0,
                onPressed: () {},
              ),
              IconButton(
                color: Colors.green[200],
                icon: Icon(FontAwesomeIcons.facebook),
                iconSize: 40.0,
                onPressed: () {},
              ),
              IconButton(
                color: Colors.green[200],
                icon: Icon(FontAwesomeIcons.qq),
                iconSize: 40.0,
                onPressed: () {},
              )
            ],
          )
        ],
      ),
    );

    List btItem = [
      S
          .of(context)
          .retrievePW,
      S
          .of(context)
          .register,
    ];

    //忘记密码  立即注册
    Widget bottomArea = Container(
      margin: EdgeInsets.only(right: 20, left: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: btItem.map(bottomItem).toList(),
      ),
    );

    return ListView(
      children: <Widget>[
        SizedBox(
          height: ScreenUtil().setHeight(80),
        ),
        logoImageArea,
        SizedBox(
          height: ScreenUtil().setHeight(70),
        ),
        inputTextArea,
        SizedBox(
          height: ScreenUtil().setHeight(80),
        ),
        loginButtonArea,
        SizedBox(
          height: ScreenUtil().setHeight(60),
        ),
        thirdLoginArea,
        SizedBox(
          height: ScreenUtil().setHeight(60),
        ),
        bottomArea,
      ],
    );
  }

  String validateUserName(value) {
    // 正则匹配手机号
    RegExp exp = RegExp(
        r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    if (value.isEmpty) {
      return '用户名不能为空!';
    } else if (!exp.hasMatch(value)) {
      return '请输入正确手机号';
    }
    return null;
  }

  String validatePassWord(value) {
    if (value.isEmpty) {
      return '密码不能为空';
    } else if (value
        .trim()
        .length < 6 || value
        .trim()
        .length > 18) {
      return '密码长度不正确';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GlobalModel>(context);

    // List btItem = [
    //   S.of(context).retrievePW,
    //   S.of(context).register,
    //   // S.of(context).weChatSecurityCenter,
    // ];

    return Scaffold(
      backgroundColor: Colors.white,
      // 外层添加一个手势，用于点击空白部分，回收键盘
      body: GestureDetector(
        onTap: () {
          // 点击空白区域，回收键盘
          print("点击了空白区域");
          _focusNodePassWord.unfocus();
          _focusNodeUserName.unfocus();
        },
        child: body(model),
      ),
    );
  }
}
