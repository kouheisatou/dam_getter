import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import 'utils.dart';

enum ScoreType { ai, dxg }

@Entity(tableName: "score")
class ScoreDataModel {
  ScoreDataModel(this.id, this.scoreType, this.contentsName, this.artistName, this.score, this.xml, this.scoringTime);

  ScoreDataModel.fromXml(XmlElement scoringXml, ScoreType type) {
    id = type == ScoreType.ai ? scoringXml.getAttribute("scoringAiId")! : scoringXml.getAttribute("scoringDxgId")!;
    scoreType = type;
    contentsName = scoringXml.getAttribute("contentsName")!;
    artistName = scoringXml.getAttribute("artistName")!;
    score = double.parse(scoringXml.innerText) / 1000;
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

  late String xml;

  late int scoringTime;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ScoreDataModel && runtimeType == other.runtimeType && scoreType == other.scoreType && id == other.id;

  @override
  int get hashCode => scoreType.hashCode ^ id.hashCode;
}

class ScoreDataListItem extends StatelessWidget {
  ScoreDataListItem(this.score, {super.key});

  ScoreDataModel score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            DateFormat("HH:mm").format(parseDatetime(score.scoringTime.toString())),
            style: const TextStyle(fontSize: 10, fontFeatures: [FontFeature.tabularFigures()]),
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            score.contentsName,
                            style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            score.artistName,
                            style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Baseline(
                              baseline: 20.0,
                              baselineType: TextBaseline.alphabetic,
                              child: Text(score.score.toString().split(".")[0], style: TextStyle(fontSize: 20, fontFeatures: [FontFeature.tabularFigures()])),
                            ),
                            Baseline(
                              baseline: 15.8,
                              baselineType: TextBaseline.alphabetic,
                              child: Text(".${score.score.toStringAsFixed(3).split(".")[1]}", style: TextStyle(fontSize: 10, fontFeatures: [FontFeature.tabularFigures()])),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
