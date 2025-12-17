import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kheabia/animations/fade_animation.dart';
import 'package:kheabia/clips/login_clipper.dart';
import 'package:kheabia/models/doctor.dart';
import 'package:kheabia/models/student.dart';
import 'package:kheabia/pages/auth/forgot_password.dart';
import 'package:kheabia/pages/doctors/doctor_home_page.dart';
import 'package:kheabia/pages/studients/student_home_page.dart';
import 'package:kheabia/utils/app_utils.dart';
import 'package:kheabia/utils/const.dart';
import 'package:kheabia/utils/firebase_methods.dart';
import 'package:page_transition/page_transition.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 0 >> Doctor    ||    1 >> Student
  int selectedRadio;

  bool hidePassword = true;
  String username, userPassword;

  Rect rect;
  double width = double.infinity;

  var globalKey = RectGetter.createGlobalKey();
  final formKey = GlobalKey<FormState>();
  GlobalKey buttonKey = GlobalKey();
  // The ripple animation time (1 second)
  Duration animationDuration = Duration(milliseconds: 500);
  Duration delayTime = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    selectedRadio = 0;
  }

  setSelectedRadio(int val) {
    setState(
      () {
        selectedRadio = val;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      allowFontScaling: true,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: SizedBox.shrink(),
            backgroundColor: Const.mainColor,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ClipPath(
                  clipper: MyClipper(),
                  child: Container(
                    height: ScreenUtil().setHeight(148),
                    color: Const.mainColor,
                    child: Center(
                      child: MyFadeAnimation(
                        delayinseconds: 1,
                        child: Text(
                          'تسجيل دخول',
                          style: TextStyle(
                            fontFamily: 'Changa',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setSelectedRadio(0);
                      },
                      child: Row(
                        children: <Widget>[
                          Text(
                            'دكتور',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          Radio(
                            value: 0,
                            groupValue: selectedRadio,
                            onChanged: (int val) {
                              setSelectedRadio(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setSelectedRadio(1);
                      },
                      child: Row(
                        children: <Widget>[
                          Text(
                            'طالب',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          Radio(
                            value: 1,
                            groupValue: selectedRadio,
                            onChanged: (int val) {
                              setSelectedRadio(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Form(
                  key: formKey,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: ScreenUtil().setHeight(10.0),
                      right: ScreenUtil().setHeight(10.0),
                      top: ScreenUtil().setHeight(18.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(16)),
                      child: Column(
                        children: <Widget>[
                          MyFadeAnimation(
                            delayinseconds: 2,
                            child: _buildInputField(
                              hintText: 'اسم المستخدم',
                              isPassword: false,
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(18),
                          ),
                          MyFadeAnimation(
                            delayinseconds: 2.5,
                            child: _buildInputField(
                              hintText: 'كلمة المرور',
                              isPassword: true,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setHeight(10.0),
                              right: ScreenUtil().setHeight(10.0),
                              bottom: ScreenUtil().setHeight(10.0),
                              top: ScreenUtil().setHeight(10.0),
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SlideInRight(
                                delay: Duration(seconds: 3),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      PageTransition(
                                        child: ForgotPassword(),
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          MyFadeAnimation(
                            delayinseconds: 3.5,
                            child: Container(
                              key: buttonKey,
                              margin: EdgeInsets.only(
                                left: ScreenUtil().setWidth(20),
                                right: ScreenUtil().setWidth(20),
                                bottom: ScreenUtil().setWidth(30),
                                top: ScreenUtil().setHeight(30.0),
                              ),
                              height: ScreenUtil().setHeight(48),
                              width: width,
                              child: RectGetter(
                                key: globalKey,
                                child: ProgressButton(
                                  color: Const.mainColor,
                                  child: Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                  onPressed: (AnimationController controller) {
                                    animatedButton(controller);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _ripple(),
      ],
    );
  }

  Widget _ripple() {
    if (rect == null) {
      return Container();
    }

    return AnimatedPositioned(
      duration: animationDuration,
      left: rect.left,
      right: MediaQuery.of(context).size.width - rect.right,
      top: rect.top,
      bottom: MediaQuery.of(context).size.height - rect.bottom,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Const.mainColor,
        ),
      ),
    );
  }

  Widget _buildInputField({
    @required hintText,
    bool isPassword,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setHeight(8.0),
        right: ScreenUtil().setHeight(8.0),
      ),
      child: TextFormField(
        cursorColor: Colors.black,
        obscureText: isPassword ? hidePassword : false,
        enableSuggestions: true,
        enableInteractiveSelection: true,
        style: TextStyle(
          color: Colors.white,
        ),
        autocorrect: true,
        validator: (input) {
          if (input.isEmpty)
            return 'ادخل جميع الحقول';
          else {
            return null;
          }
        },
        onSaved: (input) {
          isPassword ? userPassword = input : username = input;
        },
        onChanged: (input) {
          isPassword ? userPassword = input : username = input;
        },
        textAlign: TextAlign.right,
        keyboardType: hintText == 'اسم المستخدم'
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          fillColor: Const.mainColor,
          prefixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        hidePassword = !hidePassword;
                      },
                    );
                  },
                )
              : null,
          filled: true,
          alignLabelWithHint: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              width: 1,
              color: Const.mainColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              width: 1,
              color: Colors.red,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              width: 1,
              color: Const.mainColor,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              width: 1,
              color: Colors.red,
            ),
          ),
          hintText: hintText,
          contentPadding: EdgeInsets.all(
            ScreenUtil().setHeight(12),
          ),
          labelStyle: TextStyle(
            fontFamily: 'Changa',
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void animatedButton(AnimationController controller) async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();

      controller.forward();

      if (!await AppUtils.getConnectionState()) {
        AppUtils.showDialog(
          context: context,
          title: 'تنبيه',
          negativeText: 'حسنا',
          positiveText: '',
          onPositiveButtonPressed: null,
          contentText: 'لا يوجد اتصال بالانترنت',
        );

        controller.reverse();
        return;
      }

      bool isExist;
      if (selectedRadio == 1) {
        isExist = await FirebaseUtils.doesUsernameExist(
          username: username,
          collection: 'Students',
        );
      } else {
        isExist = await FirebaseUtils.doesUsernameExist(
          username: username,
          collection: 'Doctors',
        );
      }

      if (isExist) {
        DocumentSnapshot snapshot = await FirebaseUtils.getCurrentUserData(
          username: username,
          collection: selectedRadio == 1 ? 'Students' : 'Doctors',
        );

        print(snapshot.data);
        var user;
        if (selectedRadio == 1) {
          user = Student.fromMap(snapshot.data);
        } else {
          user = Doctor.fromMap(snapshot.data);
        }
        // get a snapshot of user data

        // check for input password
        // case true login user
        if (user.password == userPassword) {
          setState(
            () {
              controller.reverse();
              _onTap();
            },
          );
        } else {
          // wrong password
          setState(
            () {
              controller.reverse();
              AppUtils.showToast(
                msg: 'كلمة المرور خاطئة',
                timeInSeconds: 2,
              );
            },
          );
        }
      } else {
        setState(
          () {
            controller.reverse();
            AppUtils.showToast(
              msg: 'هذا الحساب ليس موجودا',
              timeInSeconds: 2,
            );
          },
        );
      }
    }
  }

  void _onTap() {
    setState(
      () => rect = RectGetter.getRectFromKey(globalKey),
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        setState(
          () => rect =
              rect.inflate(1.3 * MediaQuery.of(context).size.longestSide),
        );

        Future.delayed(animationDuration + delayTime, goToNextPage);
      },
    );
  }

  void goToNextPage() async {
    await SharedPreferences.getInstance().then(
      (pref) {
        pref.setString(
          'username',
          username,
        );
        pref.setString('type', selectedRadio == 1 ? '1' : '0');
      },
    );
    Navigator.of(context)
        .pushReplacement(
          PageTransition(
            child: selectedRadio == 1
                ? StudentHomePage(
                    username: username,
                  )
                : DoctorHomePage(
                    username: username,
                  ),
            type: PageTransitionType.fade,
          ),
        )
        .then(
          (_) => setState(
            () => rect = null,
          ),
        );
  }
}
