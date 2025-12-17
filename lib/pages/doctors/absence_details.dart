import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kheabia/models/doctor_absence_model.dart';
import 'package:kheabia/providers/network_provider.dart';
import 'package:kheabia/utils/const.dart';
import 'package:provider/provider.dart';

class DoctorAbsenceDetails extends StatefulWidget {
  final DoctorAbsenceModel std;

  const DoctorAbsenceDetails({Key key, this.std}) : super(key: key);

  @override
  _DoctorAbsenceDetailsState createState() => _DoctorAbsenceDetailsState();
}

class _DoctorAbsenceDetailsState extends State<DoctorAbsenceDetails> {
  bool networkIsActive;

  List<DataRow> rows = List();

  @override
  void initState() {
    super.initState();

    buildRows();
  }

  @override
  Widget build(BuildContext context) {
    var networkProvider = Provider.of<NetworkProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Const.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'مراجعة الغياب',
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
                    children: <Widget>[
                      Hero(
                        tag: 'assets/images/2.jpg',
                        child: Image.asset(
                          'assets/images/2.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: ScreenUtil().setHeight(
                            180,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(
                          18,
                        ),
                      ),
                      Text(
                        widget.std.std_name,
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'اجمالي عدد المحاضرات  ${widget.std.currentCount}',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'عدد مرات الحضور  ${widget.std.numberOfTimes}',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'عدد مرات الغياب  ${int.parse(widget.std.currentCount) - int.parse(widget.std.numberOfTimes)}',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'تاريخ اخر حضور  ${widget.std.lastAttendance}',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(
                          8,
                        ),
                      ),
                      DataTable(
                        columnSpacing: MediaQuery.of(context).size.width / 2.5,
                        columns: [
                          DataColumn(
                            label: Text(
                              'الحضور',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'المحاضرة',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                        rows: rows,
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

  void buildRows() {
    print(widget.std.attendenc);
    for (int i = 0; i < int.parse(widget.std.currentCount); i++) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              widget.std.attendenc.contains('${i + 1}')
                  ? Icon(
                      Icons.check,
                      color: Colors.green,
                    )
                  : Text(
                      'X',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                    ),
            ),
            DataCell(
              Text(' المحاضرة ${i + 1}'),
            ),
          ],
        ),
      );
    }
  }
}
