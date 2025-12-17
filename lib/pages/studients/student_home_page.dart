import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kheabia/animations/splash_tap.dart';
import 'package:kheabia/models/pointer.dart';
import 'package:kheabia/models/student.dart';
import 'package:kheabia/pages/studients/scan_code_page.dart';
import 'package:kheabia/providers/network_provider.dart';
import 'package:kheabia/utils/const.dart';
import 'package:kheabia/utils/firebase_methods.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'student_absence_review.dart';

class StudentHomePage extends StatefulWidget {
  final String username;

  const StudentHomePage({Key key, this.username}) : super(key: key);

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  void initState() {
    super.initState();

    Pointer.currentStudent = null;
  }

  void loadUserData() async {
    DocumentSnapshot snapshot = await FirebaseUtils.getCurrentUserData(
        username: widget.username, collection: 'Students');

    Student currentUser = Student.fromMap(snapshot.data);
    Pointer.currentStudent = currentUser;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var networkProvider = Provider.of<NetworkProvider>(context);

    if (networkProvider.hasNetworkConnection != null &&
        networkProvider.hasNetworkConnection) {
      if (Pointer.currentStudent == null ||
          Pointer.currentStudent.name == null ||
          Pointer.currentStudent.id == null) {
        loadUserData();
      }
    }

    ScreenUtil.init(
      context,
      allowFontScaling: true,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Const.mainColor,
        title: Text(
          'غيابي',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: networkProvider.hasNetworkConnection == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : networkProvider.hasNetworkConnection
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: ScreenUtil().setHeight(
                          15,
                        ),
                      ),
                      SlideInDown(
                        child: Pointer.currentStudent.name == null
                            ? Text(
                                '... برجاء الانتظار قليلا حتي يتم جلب بيانات الطالب ',
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                '${Pointer.currentStudent.name ?? ''}',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.bold,
                                  color: Const.mainColor,
                                  fontSize: 22,
                                ),
                              ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(
                          15,
                        ),
                      ),
                      FadeInLeft(
                        child: _buildCards(
                          imageAsset: 'assets/images/1.jpg',
                          text: 'فحـص الكود',
                          onTap: Pointer.currentStudent.name == null
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    PageTransition(
                                      child: ScanCodePage(),
                                      type: PageTransitionType.downToUp,
                                    ),
                                  );
                                },
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(
                          15,
                        ),
                      ),
                      FadeInRight(
                        child: _buildCards(
                          imageAsset: 'assets/images/2.jpg',
                          text: 'مراجعة الغياب',
                          onTap: Pointer.currentStudent.name == null
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    PageTransition(
                                      child: StudentAbsenceReview(),
                                      type: PageTransitionType.downToUp,
                                    ),
                                  );
                                },
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  color: Color(0xffF2F2F2),
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/no_internet_connection.jpg',
                      ),
                      Text(
                        'لا يوجد اتصال بالانترنت',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCards({
    String imageAsset,
    String text,
    Function onTap,
  }) {
    return Splash(
      onTap: onTap,
      maxRadius: 180,
      splashColor: Const.mainColor,
      child: Container(
        height: ScreenUtil().setHeight(
          190,
        ),
        margin: EdgeInsets.all(
          ScreenUtil().setHeight(10),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              offset: Offset(0, 3),
              blurRadius: 3,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              height: ScreenUtil().setHeight(
                130,
              ),
              width: ScreenUtil.screenWidth,
            ),
            SizedBox(
              height: ScreenUtil().setHeight(4),
            ),
            Center(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold,
                  color: Const.mainColor,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
