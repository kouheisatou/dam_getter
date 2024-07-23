import 'package:floor/floor.dart';

enum ScoreType{
  ai, dxg
}

@Entity(tableName: "score")
class ScoreDataModel{

  ScoreDataModel(this.scoreType, this.id, this.contentsName, this.artistName, this.score);

  @primaryKey
  String id;

  @primaryKey
  ScoreType scoreType;

  String contentsName;

  String artistName;

  String score;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ScoreDataModel && runtimeType == other.runtimeType && scoreType == other.scoreType && id == other.id;

  @override
  int get hashCode => scoreType.hashCode ^ id.hashCode;
}