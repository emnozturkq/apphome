import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttManager {
  late MqttServerClient client;
  final String broker = 'broker.emqx.io';
  final int port = 1883;
  final String clientIdentifier = 'flutter_client';
  final String topic = 'emn';
  String status = 'Disconnected';

  void initializeMQTTClient() {
    client = MqttServerClient(broker, clientIdentifier);
    client.port = port;
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;
  }

  Future<void> connect() async {
    initializeMQTTClient();

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      status = 'Connected';
      client.subscribe(topic, MqttQos.atMostOnce);
    } else {
      print(
          'ERROR: MQTT client connection failed - disconnecting, status is ${client.connectionStatus}');
      disconnect();
    }
  }

  void onConnected() {
    print('Connected');
    status = 'Connected';
  }

  void onDisconnected() {
    print('Disconnected');
    status = 'Disconnected';
  }

  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

  void disconnect() {
    client.disconnect();
  }

  void publishMessage(String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  String getStatus() {
    return status;
  }
}
