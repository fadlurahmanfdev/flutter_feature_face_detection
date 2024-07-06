import 'package:flutter/material.dart';

class CameraControlLayoutWidget extends StatelessWidget {
  final Icon flashIcon;
  final void Function() onFlashTap;
  final Icon captureIcon;
  final void Function() onCaptureTap;
  final Icon switchCameraIcon;
  final void Function() onSwitchCameraTap;

  const CameraControlLayoutWidget({
    required this.flashIcon,
    required this.onFlashTap,
    required this.captureIcon,
    required this.onCaptureTap,
    required this.switchCameraIcon,
    required this.onSwitchCameraTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onFlashTap,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: flashIcon,
            ),
          ),
          GestureDetector(
            onTap: onCaptureTap,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: captureIcon,
            ),
          ),
          GestureDetector(
            onTap: onSwitchCameraTap,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: switchCameraIcon,
            ),
          ),
        ],
      ),
    );
  }
}
