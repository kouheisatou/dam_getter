import 'dart:async';

import 'package:dam_getter/score_dao.dart';
import 'package:dam_getter/score_data_model.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 1, entities: [ScoreDataModel])
abstract class AppDatabase extends FloorDatabase {
  static AppDatabase? _appDatabase;

  ScoreDao get scoreDao;

  static Future<AppDatabase> getDatabase() async {
    return _appDatabase ??= await $FloorAppDatabase.databaseBuilder('dam_getter.db').build();
  }
}
