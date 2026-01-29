import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppText {
  AppText._();

  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.teksgelap,
  );

  static const body = TextStyle(
    fontSize: 14,
    color: AppColors.teksputih,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.teksabu,
  );

  static const smallBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.teksgelap,
  );
}
