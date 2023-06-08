import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

const LinearGradient background = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xff9DB2BF),
    Color(0xaa9DB2BF),
    Colors.white,
  ],
);
const Color primaryElement = Colors.white;
const Color primaryBackground = Color(0xff4F709C);
const Color secondaryElement = Color(0xff4E4F50);
const Color secondaryBackground = Color(0xffF5EFE7);
const Color yesButton = Colors.green;
const Color noButton = Colors.red;
const Color inactivated = Color(0xddcccccc);
const Color selectedIconBar = Color(0xff4F709C);

const double fontSizeCards = 16;

const TextStyle appBarTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w500,
  color: primaryElement,
);

final NumberFormat formatterMoney = NumberFormat("##,##0.00", 'pt_BR');
final NumberFormat formatterWeight = NumberFormat("##,##0.###", 'pt_BR');

final Widget loadingAnimationSearch = Center(
  child:
  LoadingAnimationWidget.horizontalRotatingDots(
    color: primaryBackground,
    size: 25,
  ),
);

final Widget loadingAnimationButton = Center(
  child:
  LoadingAnimationWidget.horizontalRotatingDots(
    color: primaryElement,
    size: 25,
  ),
);

final Widget loadingAnimationPage = Center(
  child:
  LoadingAnimationWidget.horizontalRotatingDots(
    color: primaryBackground,
    size: 50,
  ),
);