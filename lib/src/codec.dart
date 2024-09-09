import 'dart:convert';

import 'package:centrifuge/src/proto/client.pb.dart';
import 'package:protobuf/protobuf.dart';

abstract class CommandEncoder<T> extends Converter<Command, T> {}

abstract class ReplyDecoder<T> extends Converter<T, List<Reply>> {}

class ProtobufCommandEncoder extends CommandEncoder<List<int>> {
  @override
  List<int> convert(Command input) {
    final commandData = input.writeToBuffer();
    final length = commandData.lengthInBytes;

    final writer = CodedBufferWriter();
    writer.writeInt32NoTag(length);

    return writer.toBuffer() + commandData;
  }
}

class ProtobufReplyDecoder extends ReplyDecoder<List<int>> {
  @override
  List<Reply> convert(List<int> input) {
    final replies = <Reply>[];

    final reader = CodedBufferReader(input);
    while (!reader.isAtEnd()) {
      final reply = Reply();
      reader.readMessage(reply, ExtensionRegistry.EMPTY);
      replies.add(reply);
    }

    return replies;
  }
}

class JsonCommandEncoder extends CommandEncoder<String> {
  @override
  String convert(Command input) {
    return jsonEncode(
      input.toProto3Json(),
    );
  }
}

class JsonReplyDecoder extends ReplyDecoder<String> {
  Reply _json2Reply(Map<String, dynamic> json) {
    final reply = Reply();
    reply.mergeFromProto3Json(json);

    return reply;
  }

  @override
  List<Reply> convert(String input) {
    final replies = <Reply>[];
    final data = jsonDecode(input);

    if (data is List) {
      for (Map<String, dynamic> map in data) {
        replies.add(
          _json2Reply(map),
        );
      }
    } if (data is Map<String, dynamic>) {
      replies.add(
        _json2Reply(data),
      );
    } else {
      throw FormatException('Unexpected data type: ${data.runtimeType}');
    }

    return replies;
  }
}
