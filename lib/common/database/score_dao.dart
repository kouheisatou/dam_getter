import 'package:dam_getter/common/database/score_data_model.dart';
import 'package:floor/floor.dart';

@dao
abstract class ScoreDao {
  @Query("SELECT * FROM score")
  Future<List<ScoreDataModel>> getAllScores();

  @insert
  Future<void> insertScore(ScoreDataModel score);
}
