import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../utils.dart';

enum ScoreType { ai, dxg }

/// DAM Score Data Model Class
@Entity(tableName: "score")
class ScoreDataModel {
  ScoreDataModel(this.id, this.scoreType, this.contentsName, this.artistName, this.score, this.scoreAverage, this.xml, this.scoringTime);

  /// convert from xml api response
  ScoreDataModel.fromXml(XmlElement scoringXml, ScoreType type) {
    id = type == ScoreType.ai ? scoringXml.getAttribute("scoringAiId")! : scoringXml.getAttribute("scoringDxgId")!;
    scoreType = type;
    contentsName = scoringXml.getAttribute("contentsName")!;
    artistName = scoringXml.getAttribute("artistName")!;
    score = double.parse(scoringXml.innerText) / 1000;
    scoreAverage = double.parse(scoringXml.getAttribute("nationalAverageTotalPoints")!) / 1000;
    xml = scoringXml.toString();
    scoringTime = int.parse(scoringXml.getAttribute("scoringDateTime")!);
  }

  @primaryKey
  late String id;

  @primaryKey
  late ScoreType scoreType;

  late String contentsName;

  late String artistName;

  late double score;

  late double scoreAverage;

  late String xml;

  late int scoringTime;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ScoreDataModel && runtimeType == other.runtimeType && scoreType == other.scoreType && id == other.id;

  @override
  int get hashCode => scoreType.hashCode ^ id.hashCode;
}
