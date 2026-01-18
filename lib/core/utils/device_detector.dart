import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';

enum DeviceType { web, tablet, mobile }

class DeviceDetector {
  static DeviceType getDeviceType(BuildContext context) {
    final double shortestSide = MediaQuery.of(context).size.width;

    /// Define thresholds for device types based on shortestSide (in logical pixels)
    if (shortestSide > DimensionConstant.dd1400) {
      return DeviceType.web; /// Larger screens, typical for web browsers
    } else if (shortestSide <= DimensionConstant.dd1400 && shortestSide > DimensionConstant.dd700) {
      return DeviceType.tablet; /// Medium screens, typical for tablets
    } else {
      return DeviceType.mobile; /// Smaller screens, typical for phones
    }
  }
}
