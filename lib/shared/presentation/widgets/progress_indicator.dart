import 'package:flutter/material.dart';

import 'package:gsecsurvey/app/config/institution_config.dart';

class ProgressIndicaror {
  static showProgressIndicator(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: InstitutionConfig.primaryColor,
          ),
        );
      },
    );
  }
}
