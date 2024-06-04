import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final double width, height;
  final String label;
  final bool? pressableDissition;
  final Function onPressed;

  const ButtonWidget(
      {super.key,
      required this.width,
      required this.height,
      required this.label,
      required this.onPressed,
      this.pressableDissition});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: (pressableDissition ?? true) ? onPressed() : null,
          child: Text(label),
        ));
  }
}
