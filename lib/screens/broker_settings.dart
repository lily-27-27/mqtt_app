// lib/screens/broker_settings_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class BrokerSettingsPage extends StatefulWidget {
  @override
  _BrokerSettingsPageState createState() => _BrokerSettingsPageState();
}

class _BrokerSettingsPageState extends State<BrokerSettingsPage> {
  final _brokerController = TextEditingController();
  final _portController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Broker Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _brokerController,
                decoration: InputDecoration(labelText: 'Broker Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the broker address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _portController,
                decoration: InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the port';
                  }
                  final port = int.tryParse(value);
                  if (port == null || port <= 0 || port > 65535) {
                    return 'Please enter a valid port number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _clientIdController,
                decoration: InputDecoration(labelText: 'Client ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the client ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveSettings();
                  }
                },
                child: Text('Save Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() async {
    final brokerConfig = {
      'broker': _brokerController.text,
      'port': int.tryParse(_portController.text) ?? 1883,
      'clientId': _clientIdController.text,
    };
    Navigator.pop(context, brokerConfig); // Return the broker configuration
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _brokerController.text = prefs.getString('broker') ?? '';
      _portController.text = (prefs.getInt('port') ?? 1883).toString();
      _clientIdController.text = prefs.getString('clientId') ?? '';
    });
  }
}
