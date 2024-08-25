import 'package:flutter/material.dart';
import 'services/mqtt_service.dart';
import 'screens/broker_settings.dart';
import 'screens/subscription_page.dart';  // Add this import for the SubscriptionPage
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MqttService? _mqttService;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final broker = prefs.getString('broker') ?? '';
    final port = prefs.getInt('port') ?? 1883;
    final clientId = prefs.getString('clientId') ?? '';
    final topics = prefs.getStringList('topics') ?? [];

    setState(() {
      _mqttService = MqttService(
        broker: broker,
        port: port,
        clientId: clientId,
      );
      _mqttService?.subscribeToTopics(topics); // Automatically subscribe to saved topics
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT App'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BrokerSettingsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.subscriptions),
            onPressed: _mqttService != null
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionPage(
                    mqttService: _mqttService!,
                  ),
                ),
              );
            }
                : null, // Disable if MQTT service isn't ready
          ),
        ],
      ),
      body: Center(
        child: _mqttService == null
            ? CircularProgressIndicator()
            : Text('Connected to MQTT broker'),
      ),
    );
  }
}
