import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:typed_data/typed_data.dart' as typed;

class MqttService {
  mqtt.MqttClient? client;
  Function(String topic, String message)? onMessage; // Callback for messages
  Map<String, List<String>> messages = {}; // Store messages per topic

  MqttService({
    required String broker,
    required int port,
    required String clientId,
  }) {
    client = mqtt.MqttClient(broker, clientId);
    client!.port = port;
    client!.logging(on: true);
    _connect();
  }

  Future<void> _connect() async {
    try {
      client!.setProtocolV311();
      client!.keepAlivePeriod = 20;
      client!.onConnected = _onConnected;
      client!.onDisconnected = _onDisconnected;
      client!.onSubscribed = _onSubscribed;
      client!.onUnsubscribed = _onUnsubscribed;
      client!.onSubscribeFail = _onSubscribeFail;
      client!.pongCallback = _pong;

      await client!.connect();

      client!.updates!.listen(_onMessage);
      print('Connected to MQTT broker');
    } catch (e) {
      print('Error connecting: $e');
    }
  }

  void _onConnected() {
    print('Connected');
  }

  void _onDisconnected() {
    print('Disconnected');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
    messages[topic] = []; // Initialize the list for the topic
  }

  void _onUnsubscribed(String? topic) {
    print('Unsubscribed from $topic');
    messages.remove(topic); // Remove the topic from the list
  }

  void _onSubscribeFail(String topic) {
    print('Failed to subscribe to $topic');
  }

  void _pong() {
    print('Ping response client callback invoked');
  }

  void _onMessage(List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> event) {
    final mqtt.MqttPublishMessage recMess = event[0].payload as mqtt.MqttPublishMessage;
    final message = mqtt.MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message as typed.Uint8Buffer);
    final topic = event[0].topic;

    messages[topic]?.add(message); // Store the message under the topic
    onMessage?.call(topic, message); // Trigger callback with topic and message
  }

  List<String> getMessagesForTopic(String topic) {
    return messages[topic] ?? [];
  }

  void disconnect() {
    client?.disconnect();
  }

  void subscribeToTopics(List<String> topics) {
    if (client != null && client!.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
      for (String topic in topics) {
        client!.subscribe(topic, mqtt.MqttQos.atLeastOnce);
        print('Subscribed to $topic');
      }
    } else {
      print('Unable to subscribe, client is not connected.');
    }
  }
}
