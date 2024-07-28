import 'package:dam_getter/screen/score_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DamGetter extends StatefulWidget {
  @override
  State<DamGetter> createState() => _DamGetterState();
}

class _DamGetterState extends State<DamGetter> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScoreListScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
    );
  }
}
