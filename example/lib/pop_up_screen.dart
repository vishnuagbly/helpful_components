import 'package:flutter/material.dart';
import 'package:helpful_components/helpful_components.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pop up Test'),
      ),
      body: Center(
        child: PopupScope(
          builder: (context) => Stack(
            children: [
              Container(
                height: 100,
                width: 100,
                color: Colors.white10,
              ),
              Positioned(
                top: 10,
                left: 10,
                child: InkWell(
                  onTap: () async {
                    PopupController.of(context).show(
                      builder: (context) => Popup(
                        parentKey: key,
                        child: InkWell(
                          onTap: () => PopupController.of(context).remove(),
                          child: Container(
                            height: 50,
                            width: 100,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    key: key,
                    height: 50,
                    width: 50,
                    color: Colors.green,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
