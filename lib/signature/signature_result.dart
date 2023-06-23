import 'dart:typed_data';

import 'package:flutter/material.dart';

class SignatureResult extends StatelessWidget {
  Uint8List bytes;
  SignatureResult({super.key,
    required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.memory(bytes),
      ),
    );
  }
}
