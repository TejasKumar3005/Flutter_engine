import 'package:flutter/material.dart';
import 'package:kafkabr/kafka.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';



class KafkaMessageWidget extends StatefulWidget {
  const KafkaMessageWidget({Key? key}) : super(key: key);

  @override
  _KafkaMessageWidgetState createState() => _KafkaMessageWidgetState();
}

class _KafkaMessageWidgetState extends State<KafkaMessageWidget> {
  final TextEditingController _controller = TextEditingController();
  // late final KafkaSession _session;

  @override
  void initState() {
    super.initState();
    // _session = KafkaSession([ContactPoint('35.165.158.80', 9092)]); //65.0.76.10
    // print(_session);
  }

  // Future<void> _sendMessageToKafka(String message) async {

  //   print("hello");
  //   var producer = Producer(_session, 1, 1000);
  //   print("hello2");
  //   print(message.codeUnits);
  //   var msg = Message( message.codeUnits, key: [0,1]);
  //   print("hello3");
  //   var prod = ProduceEnvelope('prompt', 0, [msg]);
  //   print("hello4");
  //   var result = await producer.produce([
  //     prod
  //   ]);
  //   print("hello5");
  //   print(result.hasErrors);
  //   print(result.offsets);

  //   var group = ConsumerGroup(_session, 'udc');
  //   var topics = {
  //     'game': {0} // list of partitions to consume from.
  //   };

  //   var consumer = Consumer(_session, group, topics, 50000, 1);
  //   print("reached here");
  //   await for (MessageEnvelope envelope in consumer.consume()) {
  //     print("reached here2");
  //     var value = String.fromCharCodes(envelope.message.value);
  //     print('Got message: ${envelope.offset}, ${value}');
  //     envelope.commit('metadata'); // Important.
  //   }
  //   print("hello6");
  //   _session.close();
  // }


  Future<Map<String, dynamic>> _getJSONData(String message) async {
    var uri = Uri.parse("http://35.165.158.80:9092/send_data");
    var request = http.MultipartRequest('POST', uri)
      ..fields['msg'] = message;

    var response = await request.send();

    if (response.statusCode == 200) {
      String body = await response.stream.bytesToString();
      // print(body);
      Map<String, dynamic> data = json.decode(body);
      // Assuming the double value is directly returned
      return data["message"]; // replace 'value' with the appropriate key if needed
    } else {
      throw Exception("Failed to send .wav file. Status code: ${response.statusCode}");
    }

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
                  Map<String, dynamic> data = await _getJSONData(message);
                  print(data);
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