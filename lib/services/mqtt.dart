import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientWrapper {
  static final MQTTClientWrapper _instance = MQTTClientWrapper._internal();
  factory MQTTClientWrapper({void Function(String)? onMessageReceived}) {
    if (onMessageReceived != null &&
        !_instance._listeners.contains(onMessageReceived)) {
      _instance._listeners.add(onMessageReceived);
    }
    if (!_instance._initialized) {
      _instance._prepareMqttClient();
    }
    return _instance;
  }

  MQTTClientWrapper._internal();

  late MqttServerClient client;
  final List<void Function(String)> _listeners = [];
  bool _initialized = false;
  bool _isConnected = false;

  Future<void> _prepareMqttClient() async {
    debugPrint("[MQTT] Preparing client...");
    client = MqttServerClient.withPort(
      '35.238.54.189',
      'FlutterClient',
      1883,
    );

    client.secure = false;
    client.keepAlivePeriod = 60;
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;

    try {
      await client.connect('admin', 'hivemq');
      _isConnected = true;
      debugPrint("[MQTT] Connected!");
    } catch (e) {
      debugPrint("[MQTT] Connection failed: $e");
      _isConnected = false;
      return;
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final topic = c[0].topic;
      debugPrint("[MQTT] Message from $topic: $message");
      for (var listener in _listeners) {
        listener(message);
      }
    });

    _initialized = true;
  }

  void subscribeToTopic(String topic) {
    if (_isConnected) {
      debugPrint("[MQTT] Subscribing to $topic");
      client.subscribe(topic, MqttQos.atMostOnce);
    }
  }

  Future<bool> checkTopicExists(String topic) async {
    if (!_isConnected) return false;

    final Completer<bool> completer = Completer<bool>();

    final tempSub =
        client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final topicReceived = c[0].topic;
      if (topicReceived == topic && !completer.isCompleted) {
        completer.complete(true);
      }
    });

    subscribeToTopic(topic);

    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (!completer.isCompleted) completer.complete(false);
    });

    final result = await completer.future;
    await tempSub?.cancel();
    return result;
  }

  void _onConnected() => debugPrint("[MQTT] onConnected");
  void _onDisconnected() => debugPrint("[MQTT] onDisconnected");
  void _onSubscribed(String topic) => debugPrint("[MQTT] Subscribed to $topic");
}
