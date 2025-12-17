import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kheabia/animations/splash_tap.dart';
import 'package:kheabia/models/doctor.dart';
import 'package:kheabia/models/pointer.dart';
import 'package:kheabia/pages/auth/login_page.dart';
import 'package:kheabia/pages/doctors/doctor_absance_review.dart';
import 'package:kheabia/pages/doctors/edit_absence_page.dart';
import 'package:kheabia/pages/doctors/select_course_to_generate.dart';
import 'package:kheabia/providers/network_provider.dart';
import 'package:kheabia/utils/app_utils.dart';
import 'package:kheabia/utils/const.dart';
import 'package:kheabia/utils/firebase_methods.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorHomePage extends StatefulWidget {
  final String username;

  const DoctorHomePage({Key key, this.username}) : super(key: key);

  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  @override
  void initState() {
    super.initState();

    Pointer.currentDoctor = null;
  }

  void loadUserData() async {
    DocumentSnapshot snapshot = await FirebaseUtils.getCurrentUserData(
      username: widget.username,
      collection: 'Doctors',
    );

    Doctor currentUser = Doctor.fromMap(snapshot.data);
    Pointer.currentDoctor = currentUser;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      allowFontScaling: true,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );

    var networkProvider = Provider.of<NetworkProvider>(context);

    if (networkProvider.hasNetworkConnection != null &&
        networkProvider.hasNetworkConnection) {
      if (Pointer.currentDoctor == null || Pointer.currentDoctor.id == null) {
        loadUserData();
      }

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
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
              ),
              onPressed: () {
                AppUtils.showDialog(
                  context: context,
                  title: 'تسجيل الخروج',
                  negativeText: 'الغاء',
                  positiveText: 'تاكيد',
                  onPositiveButtonPressed: () {
                    Navigator.of(context).pop();
                  },
                  onNegativeButtonPressed: () {
                    SharedPreferences.getInstance().then(
                      (pref) {
                        pref.remove('username');
                        pref.remove('type');
                        Pointer.currentDoctor.id == null;
                        Pointer.currentDoctor.name == null;
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => LoginPage(),
                          ),
                        );
                      },
                    );
                  },
                  contentText: 'هل تريد تسجيل الخروج؟',
                );
              },
            ),
          ],
        ),
        body: networkProvider.hasNetworkConnection == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : networkProvider.hasNetworkConnection
                ? Center(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: ScreenUtil().setHeight(
                              20,
                            ),
                          ),
                          SlideInDown(
                            child: Text(
                              '${Pointer.currentDoctor.name ?? ''}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.bold,
                                color: Const.mainColor,
                                fontSize: 20,
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
                              imageAsset: 'assets/images/3.jpg',
                              text: 'توليد الكود',
                              onTap: () {
                                Navigator.of(context).push(
                                  PageTransition(
                                    child: SelectCourseToGenerate(),
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
                              onTap: () {
                                Navigator.of(context).push(
                                  PageTransition(
                                    child: DoctorAbsenceReview(),
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
                              imageAsset: 'assets/images/4.jpg',
                              text: 'تعديل الغياب',
                              onTap: () {
                                Navigator.of(context).push(
                                  PageTransition(
                                    child: EditAbsencePage(),
                                    type: PageTransitionType.downToUp,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
            Hero(
              tag: imageAsset,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                height: ScreenUtil().setHeight(
                  130,
                ),
                width: ScreenUtil.screenWidth,
              ),
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
