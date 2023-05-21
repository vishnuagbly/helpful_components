import 'package:example/pop_up_screen.dart';
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
        child: Center(
          child: Column(
            children: [
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CommonAlertDialog('Done'),
                  );
                },
                child: const Text('Show CommonAlertDialog'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () async {
                  final option = await showDialog(
                    context: context,
                    builder: (_) => const BooleanDialog('Select from options'),
                  );
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => CommonAlertDialog('Selected $option'),
                  );
                },
                child: const Text('Show BooleanDialog'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TestScreen()),
                  );
                },
                child: const Text('Test Pop up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
