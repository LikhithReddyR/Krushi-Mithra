import 'package:flutter/material.dart';
import 'package:smart_farm/services/chat_service.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text, 
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chat_history')
          .orderBy('timestamp', descending: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _messages.addAll(snapshot.docs.map((doc) {
              final data = doc.data();
              return ChatMessage(
                text: data['text'] as String,
                isUser: data['isUser'] as bool,
                timestamp: (data['timestamp'] as Timestamp).toDate(),
              );
            }));
          });
          _scrollToBottom();
        }
      } else {
        // Only load initial greeting if there's no history
        await _loadInitialMessage();
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInitialMessage() async {
    String username = '';
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final name = doc.data()!['name'] as String?;
          if (name != null && name.trim().isNotEmpty) {
            username = name.trim();
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading username: $e');
    }

    if (mounted) {
      setState(() {
        String greeting = TranslationService.translate('hi_farmer') ?? 'Hello! I am your Agri assistant. How can I help you today?';
        
        if (username.isNotEmpty) {
          if (greeting.toLowerCase().contains('farmer')) {
            greeting = greeting.replaceAll(RegExp('farmer', caseSensitive: false), username);
          } else {
            greeting = 'Hi $username! I am your Agri assistant. How can I help you today?';
          }
        }

        _messages.add(ChatMessage(
          text: greeting,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final timestamp = DateTime.now();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: timestamp));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Save user message to Firestore
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chat_history')
          .add({
        'text': text,
        'isUser': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    final response = await _chatService.sendMessage(text);
    final cleanedResponse = _cleanText(response);
    final aiTimestamp = DateTime.now();
    
    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: cleanedResponse, isUser: false, timestamp: aiTimestamp));
        _isLoading = false;
      });
      _scrollToBottom();
    }

    // Save AI response to Firestore
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chat_history')
          .add({
        'text': cleanedResponse,
        'isUser': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  String _cleanText(String text) {
    // Remove common markdown symbols
    return text
        .replaceAll(RegExp(r'\*\*'), '') // Remove bold
        .replaceAll(RegExp(r'###'), '') // Remove headers
        .replaceAll(RegExp(r'##'), '')  // Remove headers
        .replaceAll(RegExp(r'#'), '')   // Remove headers
        .replaceAll(RegExp(r'_'), '')   // Remove italics/underscore
        .replaceAll(RegExp(r'~'), '')   // Remove strikethrough
        .replaceAll(RegExp(r'\*'), '')  // Remove single asterisk
        .trim();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raitha Bandhu'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, isDark);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/raitha_bandhu_icon.png',
                    fit: BoxFit.cover, // Cover looks better for a full-background icon
                  ),
                ),
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.70,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Theme.of(context).primaryColor
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: message.isUser ? const Radius.circular(16) : const Radius.circular(4), // Subtle round instead of zero
                  bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16), // Subtle round
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser 
                      ? Colors.white 
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          if (message.isUser)
            const SizedBox(width: 8), // Reduced from 40 to bring closer to edge
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: TranslationService.translate('ask_question') ?? 'Ask farm-related questions...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
