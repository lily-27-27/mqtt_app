import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class TopicSelectionPage extends StatelessWidget {
  final MqttService mqttService;

  TopicSelectionPage({required this.mqttService});

  @override
  Widget build(BuildContext context) {
    final topics = mqttService.messages.keys.toList(); // Get all topics

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Topic'),
      ),
      body: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return ListTile(
            title: Text(topic),
            onTap: () {
              Navigator.pop(context, topic); // Return selected topic
            },
          );
        },
      ),
    );
  }
}
