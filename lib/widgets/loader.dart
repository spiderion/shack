import 'package:flutter/material.dart';
import 'package:template_package/utils/build_mode_detector.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isInDebugMode
        ? Text('loading')
        :
        Material(child: Center(child: CircularProgressIndicator()));
  }
}
