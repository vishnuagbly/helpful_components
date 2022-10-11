import 'package:flutter/material.dart';
import 'package:helpful_components/helpful_components.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Center(
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CommonAlertDialog('Done'),
                  );
                },
                child: const Text('Show CommonAlertDialog'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
