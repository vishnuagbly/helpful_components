import 'package:flutter/material.dart';

///A Commonly used dialog with a simple yes and no button, this dialog returns a
///boolean value for the pressed button respectively.
class BooleanDialog extends StatelessWidget {
  const BooleanDialog(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      title: SizedBox(
        width: screenWidth * 0.5,
        child: Text(
          text,
          maxLines: null,
        ),
      ),
      actions: [
        TextButton(
          child: const Text("YES"),
          onPressed: () => Navigator.pop(
            context,
            true,
          ),
        ),
        TextButton(
          child: const Text("NO"),
          onPressed: () => Navigator.pop(
            context,
            false,
          ),
        )
      ],
    );
  }
}
