import 'package:flutter/material.dart';

class AboveKeyboardPage extends StatefulWidget {
  @override
  _AboveKeyboardPageState createState() => _AboveKeyboardPageState();
}

class _AboveKeyboardPageState extends State<AboveKeyboardPage> {
  bool isTyping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Above Keyboard Page'),
      ),
      body: Stack(
        children: [
          // Your main content
          Positioned(
            top: 0,
            bottom: isTyping
                ? MediaQuery.of(context).viewInsets.bottom
                : kBottomNavigationBarHeight,
            left: 0,
            right: 0,
            child: YourMainContent(),
          ),
          // Your CustomFooter with ChatButton
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              height: 70,
              child: CustomFooter(
                onTypingStarted: () {
                  setState(() {
                    isTyping = true;
                  });
                },
                onTypingEnded: () {
                  setState(() {
                    isTyping = false;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFooter extends StatefulWidget {
  final Function onTypingStarted;
  final Function onTypingEnded;

  CustomFooter({
    required this.onTypingStarted,
    required this.onTypingEnded,
  });

  @override
  _CustomFooterState createState() => _CustomFooterState();
}

class _CustomFooterState extends State<CustomFooter> {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onChanged: (text) {
                if (text.isNotEmpty && !widget.onTypingStarted()) {
                  widget.onTypingStarted();
                } else if (text.isEmpty && widget.onTypingEnded()) {
                  widget.onTypingEnded();
                }
              },
              decoration: InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
          // IconButton removed, you can customize this area according to your needs.
        ],
      ),
    );
  }
}

class YourMainContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Your main content goes here
    );
  }
}
