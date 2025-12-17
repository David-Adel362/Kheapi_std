import 'package:flutter/material.dart';
import 'package:kheabia/pages/studients/process_scaned_data.dart';
import 'package:kheabia/providers/network_provider.dart';
import 'package:kheabia/utils/const.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:twitter_qr_scanner/QrScannerOverlayShape.dart';
import 'package:twitter_qr_scanner/twitter_qr_scanner.dart';

class ScanCodePage extends StatefulWidget {
  @override
  _ScanCodePageState createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  GlobalKey qrKey = GlobalKey();
  QRViewController controller;

  void _onQRViewCreate(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen(
      (scanData) {
        setState(
          () {
            Navigator.of(context).pushReplacement(
              PageTransition(
                child: ProcessScannedData(
                  data: scanData,
                ),
                type: PageTransitionType.scale,
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var networkProvider = Provider.of<NetworkProvider>(context);

    return Scaffold(
      body: networkProvider.hasNetworkConnection == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : networkProvider.hasNetworkConnection
              ? QRView(
                  key: qrKey,
                  initialMode: QRMode.SCANNER,
                  switchButtonColor: Const.mainColor,
                  overlay: QrScannerOverlayShape(
                    borderRadius: 10,
                    borderColor: Const.mainColor,
                    borderLength: 120,
                    borderWidth: 3,
                    cutOutSize: 295,
                  ),
                  onQRViewCreated: _onQRViewCreate,
                  data: "INVALID DATA",
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
