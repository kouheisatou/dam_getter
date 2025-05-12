import 'package:dam_getter/common/database/score_data_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';

class ScoreDetailScreen extends StatelessWidget {
  ScoreDetailScreen(this.scoreData);

  ScoreDataModel scoreData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scoreData.contentsName),
      ),
      body: Scrollbar(
        child: ListView(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text("基本データ", style: TextStyle(fontSize: 20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Table(
                children: [
                  _buildTableRow(context, 'ID', scoreData.id),
                  _buildTableRow(context, 'Score Type', scoreData.scoreType.toString().split('.').last),
                  _buildTableRow(context, 'Contents Name', scoreData.contentsName),
                  _buildTableRow(context, 'Artist Name', scoreData.artistName),
                  _buildTableRow(context, 'Score', scoreData.score.toString()),
                  _buildTableRow(context, 'Score Average', scoreData.scoreAverage.toString()),
                  _buildTableRow(context, 'Scoring Time', scoreData.scoringTime.toString()),
                ],
              ),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text("詳細データ", style: TextStyle(fontSize: 20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Table(
                children: convertAttributesToMap(scoreData.xml).entries.map((entry) => _buildTableRow(context, entry.key, entry.value)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> convertAttributesToMap(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final firstElement = document.rootElement;
    final attributesMap = <String, String>{};
    for (final attribute in firstElement.attributes) {
      attributesMap[attribute.name.toString()] = attribute.value;
    }
    return attributesMap;
  }

  TableRow _buildTableRow(BuildContext context, String field, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(field),
                ),
              );
            },
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                field,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value),
                ),
              );
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
