import 'package:floor/floor.dart';

enum ScoreType { ai, dxg }

@Entity(tableName: "score")
class ScoreDataModel {
  ScoreDataModel(this.id, this.scoreType, this.contentsName, this.artistName, this.score, this.xml, this.scoringTime);

  // ScoreDataModel.fromXml(String xml, this.scoreType){
  //
  // }

  @primaryKey
  String id;

  @primaryKey
  ScoreType scoreType;

  String contentsName;

  String artistName;

  double score;

  String xml;

  int scoringTime;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ScoreDataModel && runtimeType == other.runtimeType && scoreType == other.scoreType && id == other.id;

  @override
  int get hashCode => scoreType.hashCode ^ id.hashCode;
}
