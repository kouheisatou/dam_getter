import 'package:dam_getter/history_screen.dart';
import 'package:dam_getter/values_public.dart';
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
      home: HistoryScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
    );
  }
}
