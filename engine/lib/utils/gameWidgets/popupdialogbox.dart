import 'package:flutter/material.dart';

class CompletionTextBox extends StatefulWidget {
  final Function() onComplete;
  final Future<String> Function() textFunction; // Function to fetch text

  const CompletionTextBox({
    Key? key,
    required this.onComplete,
    required this.textFunction,
  }) : super(key: key);

  @override
  _CompletionTextBoxState createState() => _CompletionTextBoxState();
}

class _CompletionTextBoxState extends State<CompletionTextBox> {
  bool _isVisible = false;
  String _displayText = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _isVisible,
      child: AlertDialog(
        title: Text('Completion Dialog'),
        content: Text(_displayText),
        actions: [
          TextButton(
            onPressed: () {
              widget.onComplete();
              setState(() {
                _isVisible = false;
              });
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
