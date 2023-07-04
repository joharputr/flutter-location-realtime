import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:background_proccess/signature/signature_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SignatureApp(),
    );
  }
}

class SignatureApp extends StatefulWidget {
  const SignatureApp({super.key});

  @override
  State<SignatureApp> createState() => _SignatureAppState();
}

class _SignatureAppState extends State<SignatureApp> {
  final SignatureController signatureController = SignatureController(
    exportBackgroundColor: Colors.white,
    exportPenColor: Colors.black,
  );

  @override
  void dispose() {
    signatureController.dispose();
    super.dispose();
  }

  void postImage(String filePath) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath),
      "parm": '{"type":"survey","contents":{"companyCode":"EDV","date":"14","month":"6","year":"2023","contractNo":"EXP100101042306091134"}}'
    });

    final dio = Dio();
    dio.options.headers["Authorization"] = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJjcmQiOjE2ODc0ODc5NzA3NzQsInR5cGUiOiJUS04iLCJleHAiOjE2ODc0OTg3NzA3NzQsImp0aSI6ImlnbG9kZXYifQ.WPjOM47y_r4b92WgeIo9LQz4Fd3mlKmYSvlWUWlGC5k';

    try {
      final response = await dio.post("https://103.145.82.230:8243/q/sftp/upload", data: formData);
      print(response.toString());
    } catch (error) {
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              height: 300,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey)
              ),
              child: Signature(
                controller: signatureController,
                width: MediaQuery.of(context).size.width,
                height: 300,
                backgroundColor: Colors.white,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  signatureController.clear();
                },
                child: const Text("Clear Signature")),
            ElevatedButton(
                onPressed: () async {
                  final data = await signatureController.toImage(width: MediaQuery.of(context).size.width.toInt(), height: 300);
                  final bytes = await data?.toByteData(format: ui.ImageByteFormat.png);
                  String tempPath = (await getTemporaryDirectory()).path;
                  File file = File('$tempPath/pic_larger.png');
                  final fileImage = await file.writeAsBytes(
                      bytes!.buffer.asUint8List(
                          bytes.offsetInBytes, bytes.lengthInBytes
                      )
                  );

                  if (context.mounted) {
                    if (signatureController.isEmpty) {
                      Fluttertoast.showToast(msg: "Signature is empty");
                    } else {
                      postImage(fileImage.path);
                      final base64String = base64Encode(bytes.buffer.asUint8List());
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignatureResult(bytes: bytes.buffer.asUint8List())));
                    }
                  }
                },
                child: const Text("Send Signature"))
          ],
        ),
      ),
    );
  }
}
