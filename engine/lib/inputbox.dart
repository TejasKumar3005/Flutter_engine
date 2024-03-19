import 'package:flutter/material.dart';
import 'package:kafkabr/kafka.dart';

class KafkaMessageWidget extends StatefulWidget {
  const KafkaMessageWidget({Key? key}) : super(key: key);

  @override
  _KafkaMessageWidgetState createState() => _KafkaMessageWidgetState();
}

class _KafkaMessageWidgetState extends State<KafkaMessageWidget> {
  final TextEditingController _controller = TextEditingController();
  late final KafkaSession _session;

  @override
  void initState() {
    super.initState();
    _session = KafkaSession([ContactPoint('192.168.0.111', 9092)]);
  }
  

  Future<void> _sendMessageToKafka(String message) async {
    var producer = Producer(_session, 1, 1000);
    var result = await producer.produce([
      ProduceEnvelope('topicName', 0, [Message(message.codeUnits)])
    ]);

    print(result.hasErrors);
    print(result.offsets);

    var group = ConsumerGroup(_session, 'consumerGroupName');
    var topics = {
      'topicName': {0, 1} // list of partitions to consume from.
    };

    var consumer = Consumer(_session, group, topics, 100, 1);
    await for (MessageEnvelope envelope in consumer.consume(limit: 3)) {
      // Assuming that messages were produced by Producer from the previous example.
      var value = String.fromCharCodes(envelope.message.value);
      print('Got message: ${envelope.offset}, ${value}');
      envelope.commit('metadata'); // Important.
    }
    _session.close();

  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Type your message here',
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            String message = _controller.text;
            await _sendMessageToKafka(message);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Message sent to Kafka: $message')),
            );
          },
          child: const Text('Send Message'),
        ),
      ],
    );
  }
}
