import 'package:flutter/material.dart';
import 'package:helpful_components/helpful_components.dart';

class HeroScreen extends StatefulWidget {
  static const path = '/sample';

  const HeroScreen({Key? key}) : super(key: key);

  @override
  State<HeroScreen> createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen> {
  bool flag = false;
  late final GlobalKey<SHeroScopeState> key;

  @override
  void initState() {
    key = GlobalKey<SHeroScopeState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Screen'),
      ),
      body: SHeroScope(
        key: key,
        child: Center(
          child: Stack(
            children: [
              Container(
                key: UniqueKey(),
                width: 100,
                height: 100,
                color: Colors.red,
                child: Align(
                  alignment: flag ? Alignment.bottomCenter : Alignment.topLeft,
                  child: SHero(useOverlay: false, tag: 'test_tag'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => flag = !flag),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
