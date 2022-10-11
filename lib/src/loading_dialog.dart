import 'package:flutter/material.dart';

///A common constant loading dialog, on which we can show a [loadingText] with a
///[CircularProgressIndicator].
class LoadingDialog extends StatelessWidget {
  const LoadingDialog(
    this.loadingText, {
    Key? key,
  }) : super(key: key);

  final String loadingText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(loadingText),
          const SizedBox(width: 20),
          const SizedBox(
            width: 20,
            height: 20,
            child: FittedBox(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
