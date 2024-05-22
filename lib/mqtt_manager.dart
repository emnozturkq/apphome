import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttManager {
  late MqttServerClient client;
  final Function(String) onMessageReceived;

  MqttManager({required this.onMessageReceived}) {
    client = MqttServerClient('broker.emqx.io', '');
    client.port = 1883;
    client.logging(on: true);
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
  }

  void connect() async {
    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      subscribeToTopic('emn');
      subscribeToTopic('temperature');
      try {
        client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
          final String pt =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          print('Received message: $pt from topic: ${c[0].topic}');
          onMessageReceived(pt);
        });
      } catch (e) {
        print('Error in updates listen: $e');
      }
    } else {
      print(
          'ERROR: MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }
  }

  void subscribeToTopic(String topic) {
    print('Subscribing to the $topic topic');
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void publishMessage(String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    print('Publishing message: $message to topic: emn');
    client.publishMessage('emn', MqttQos.atLeastOnce, builder.payload!);
  }

  String getStatus() {
    return client.connectionStatus!.state.toString();
  }

  void onDisconnected() {
    print('Disconnected');
  }

  void onConnected() {
    print('Connected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}
