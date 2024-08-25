import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SubscriptionSettingsPage extends StatefulWidget {
  @override
  _SubscriptionSettingsPageState createState() => _SubscriptionSettingsPageState();
}

class _SubscriptionSettingsPageState extends State<SubscriptionSettingsPage> {
  final _topicController = TextEditingController();
  List<String> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(labelText: 'Topic'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addSubscription,
              child: Text('Add Subscription'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _subscriptions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_subscriptions[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeSubscription(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSubscription() async {
    final topic = _topicController.text;
    if (topic.isNotEmpty) {
      setState(() {
        _subscriptions.add(topic);
        _topicController.clear();
      });
      await _saveSubscriptions();
    }
  }

  void _removeSubscription(int index) async {
    setState(() {
      _subscriptions.removeAt(index);
    });
    await _saveSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptions = prefs.getStringList('subscriptions') ?? [];
    setState(() {
      _subscriptions = subscriptions;
    });
  }

  Future<void> _saveSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('subscriptions', _subscriptions);
  }
}
