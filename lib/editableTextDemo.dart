import 'package:flutter/material.dart';

class EditableTextDemo extends StatefulWidget {
  const EditableTextDemo({super.key});

  @override
  _EditableTextDemoState createState() => _EditableTextDemoState();
}

class _EditableTextDemoState extends State<EditableTextDemo> {
  bool isEditing = false;
  String text = "Click to edit";
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Text to EditText Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isEditing
                ? TextField(
                    controller: _controller,
                    autofocus: true,
                  )
                : Text(
                    text,
                    style: const TextStyle(fontSize: 24),
                  ),
            const SizedBox(height: 20),
            isEditing
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        text = _controller.text;
                        isEditing = false;
                      });
                    },
                    child: const Text("Confirm"),
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    child: const Text("Edit"),
                  ),
          ],
        ),
      ),
    );
  }
}
