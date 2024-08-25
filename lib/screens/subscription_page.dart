import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/mqtt_service.dart';

class SubscriptionPage extends StatefulWidget {
  final MqttService mqttService;

  SubscriptionPage({required this.mqttService});

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  List<String> _topics = [];
  String? _selectedTopic;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadTopics();
    widget.mqttService.onMessage = _onMessageReceived; // Listen to messages
  }

  Future<void> _loadTopics() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _topics = prefs.getStringList('topics') ?? [];
    });
  }

  void _onMessageReceived(String topic, String payload) {
    if (topic == _selectedTopic) {
      setState(() {
        _message = payload;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscribed Topics'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            hint: Text('Select a topic'),
            value: _selectedTopic,
            onChanged: (newValue) {
              setState(() {
                _selectedTopic = newValue;
                _message = ''; // Clear the message when a new topic is selected
              });
            },
            items: _topics.map((topic) {
              return DropdownMenuItem(
                child: Text(topic),
                value: topic,
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Text(
            'Received Message:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(_message),
        ],
      ),
    );
  }
}
