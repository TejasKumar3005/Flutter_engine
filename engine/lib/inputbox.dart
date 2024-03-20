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
    _session = KafkaSession([ContactPoint('10.184.28.97', 9092)]);
  }

  Future<void> _sendMessageToKafka(String message) async {

    print("hello");
    var producer = Producer(_session, 1, 1000);
    print("hello2");
    var result = await producer.produce([
      ProduceEnvelope('quickstart-events', 0, [Message(message.codeUnits)])
    ]);
    print("hello3");
    print(result.hasErrors);
    print(result.offsets);

    var group = ConsumerGroup(_session, 'consumerGroupName');
    var topics = {
      'quickstart-events': {0, 1} // list of partitions to consume from.
    };

    var consumer = Consumer(_session, group, topics, 100, 1);
    await for (MessageEnvelope envelope in consumer.consume(limit: 3)) {
      var value = String.fromCharCodes(envelope.message.value);
      print('Got message: ${envelope.offset}, ${value}');
      envelope.commit('metadata'); // Important.
    }
    _session.close();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kafka Messaging'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your message here',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String message = _controller.text.trim(); // Trim whitespace
                if (message.isNotEmpty) { 
                  // Check if the message is not empty
                  await _sendMessageToKafka(message);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Message sent to Kafka: $message')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a message.')), // Display error message
                  );
                }
              },
              child: const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}