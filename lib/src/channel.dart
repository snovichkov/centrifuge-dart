import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Connects the web socket channel
WebSocketChannel connect(
  Uri uri, {
  Iterable<String>? protocols,
  Map<String, dynamic>? headers,
}) =>
    IOWebSocketChannel.connect(
      uri,
      protocols: protocols,
      headers: headers,
    );
