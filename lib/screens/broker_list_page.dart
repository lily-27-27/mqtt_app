import 'package:flutter/material.dart';
import 'broker_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/mqtt_service.dart';
import 'topic_selection_page.dart';  // Import the TopicSelectionPage
import 'topic_messages_page.dart';  // Import the new page

class BrokerListPage extends StatefulWidget {
  @override
  _BrokerListPageState createState() => _BrokerListPageState();
}

class _BrokerListPageState extends State<BrokerListPage> {
  List<Map<String, dynamic>> _brokers = [];
  MqttService? _mqttService;

  @override
  void initState() {
    super.initState();
    _loadBrokers();
  }

  Future<void> _loadBrokers() async {
    final brokers = await _loadBrokersFromStorage();
    setState(() {
      _brokers = brokers;
    });
  }

  Future<List<Map<String, dynamic>>> _loadBrokersFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? brokers = prefs.getStringList('brokers');
    brokers = brokers ?? [];
    return brokers.map((broker) => json.decode(broker) as Map<String, dynamic>).toList();
  }

  Future<void> _addBroker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BrokerSettingsPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      await _saveBroker(result);
      _loadBrokers();
    }
  }

  Future<void> _saveBroker(Map<String, dynamic> brokerConfig) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? brokers = prefs.getStringList('brokers');
    brokers = brokers ?? [];
    brokers.add(json.encode(brokerConfig));
    await prefs.setStringList('brokers', brokers);
  }

  void _connectToBroker(Map<String, dynamic> brokerConfig) async {
    final mqttService = MqttService(
      broker: brokerConfig['broker'],
      port: brokerConfig['port'],
      clientId: brokerConfig['clientId'],
    );

    setState(() {
      _mqttService = mqttService;
    });

    final selectedTopic = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicSelectionPage(mqttService: mqttService), // Implement TopicSelectionPage
      ),
    );

    if (selectedTopic != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TopicMessagesPage(
            mqttService: mqttService,
            topic: selectedTopic,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Broker List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addBroker,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _brokers.length,
        itemBuilder: (context, index) {
          final broker = _brokers[index];
          return ListTile(
            title: Text(broker['broker']),
            subtitle: Text('Port: ${broker['port']}'),
            onTap: () {
              _connectToBroker(broker);
            },
          );
        },
      ),
    );
  }
}
