import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientWrapper {
  static final MQTTClientWrapper _instance = MQTTClientWrapper._internal();

  factory MQTTClientWrapper({
    void Function(String topic, String message)? onMessageReceived,
  }) {
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
  final List<void Function(String topic, String message)> _listeners = [];
  final Set<String> _subscribedTopics = {};

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

    client.updates?.listen(_onMessageReceived);

    _initialized = true;
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage>> event) {
    final recMess = event[0].payload as MqttPublishMessage;
    final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final topic = event[0].topic;

    debugPrint("[MQTT] Message from $topic: $message");

    for (var listener in _listeners) {
      try {
        listener(topic, message);
      } catch (e) {
        debugPrint("[MQTT] Listener error: $e");
      }
    }
  }

  void subscribeToTopic(String topic) {
    if (_isConnected && !_subscribedTopics.contains(topic)) {
      debugPrint("[MQTT] Subscribing to $topic");
      client.subscribe(topic, MqttQos.atMostOnce);
      _subscribedTopics.add(topic);
    } else if (_subscribedTopics.contains(topic)) {
      debugPrint("[MQTT] Already subscribed to $topic");
    } else {
      debugPrint("[MQTT] Can't subscribe, not connected.");
    }
  }

  void unsubscribeFromTopic(String topic) {
    if (_isConnected) {
      debugPrint("[MQTT] Unsubscribing from $topic");
      client.unsubscribe(topic);
      _subscribedTopics.remove(topic);
    }
  }

  bool isSubscribed(String topic) => _subscribedTopics.contains(topic);

  Future<bool> checkTopicExists(String token) async {
    if (!_isConnected) return false;

    final fullTopic = "hasil/$token";
    final Completer<bool> completer = Completer<bool>();
    bool responded = false;

    void tempListener(String topic, String message) {
      if (topic == fullTopic && !responded) {
        responded = true;
        completer.complete(true);
        removeListener(tempListener);
      }
    }

    addListener(tempListener);
    subscribeToTopic(fullTopic);

    Future.delayed(const Duration(seconds: 5)).then((_) {
      if (!responded && !completer.isCompleted) {
        debugPrint("[MQTT] checkTopicExists timeout: $fullTopic");
        removeListener(tempListener);
        completer.complete(false);
      }
    });

    return completer.future;
  }

  void addListener(void Function(String topic, String message) listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(void Function(String topic, String message) listener) {
    _listeners.remove(listener);
  }

  void _onConnected() => debugPrint("[MQTT] Connected");
  void _onDisconnected() => debugPrint("[MQTT] Disconnected");
  void _onSubscribed(String topic) => debugPrint("[MQTT] Subscribed to $topic");

  Future<void> ensureConnected() async {
    if (!_initialized || !_isConnected) {
      debugPrint("[MQTT] ensureConnected: reconnecting...");
      await _prepareMqttClient();
    }
  }
}
