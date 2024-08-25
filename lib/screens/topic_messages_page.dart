import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class TopicMessagesPage extends StatelessWidget {
  final MqttService mqttService;
  final String topic;

  TopicMessagesPage({required this.mqttService, required this.topic});

  @override
  Widget build(BuildContext context) {
    final messages = mqttService.getMessagesForTopic(topic);

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages for $topic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(messages[index]),
            );
          },
        ),
      ),
    );
  }
}
