import 'package:dam_getter/score_data_model.dart';
import 'package:dam_getter/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                              child: Text(score.score.toString().split(".")[0], style: const TextStyle(fontSize: 20, fontFeatures: [FontFeature.tabularFigures()])),
                            ),
                            Baseline(
                              baseline: 15.8,
                              baselineType: TextBaseline.alphabetic,
                              child: Text(".${score.score.toStringAsFixed(3).split(".")[1]}", style: const TextStyle(fontSize: 10, fontFeatures: [FontFeature.tabularFigures()])),
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
