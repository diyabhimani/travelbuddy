import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travelbuddy2/model/chatboat_msg_model.dart';
import 'package:travelbuddy2/services/claude_service.dart';
import 'package:travelbuddy2/utils/app_colors.dart';


class ChatBoat extends StatefulWidget {
  const ChatBoat({super.key});

  @override
  State<ChatBoat> createState() => _ChatBoatState();
}

class _ChatBoatState extends State<ChatBoat> {
  // ── Colors ──────────────────────────────────────────

  static const bgPage = Color(0xFFF4F6FB);


  // ── State ────────────────────────────────────────────
  final _controller   = TextEditingController();
  final _scrollCtrl   = ScrollController();
  final _claudeService = ClaudeService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  static const List<Map<String, String>> _chips = [
    {'label': '🗺 Plan a trip',    'text': 'Help me plan a trip!'},
    {'label': '🧳 Packing tips',   'text': 'Give me packing tips for a vacation.'},
    {'label': '🛂 Visa info',      'text': 'How do I check visa requirements?'},
    {'label': '💰 Budget travel',  'text': 'What are your best budget travel tips?'},
    {'label': '🌍 Hidden gems',    'text': 'Suggest some underrated travel destinations.'},
  ];

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Hey there, traveller! ✈️ I'm TravelBuddy, your personal AI travel companion. "
          "Whether you're planning a weekend escape or a world tour, I've got you covered. "
          "Where are you dreaming of going? 🌍",
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────
  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true));
      _messages.add(ChatMessage(text: '', isUser: false, isTyping: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Pass history minus the typing indicator
      final history = _messages.where((m) => !m.isTyping).toList();
      final reply = await _claudeService.sendMessage(history);
      setState(() {
        _messages.removeWhere((m) => m.isTyping);
        _messages.add(ChatMessage(text: reply, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.isTyping);
        _messages.add(ChatMessage(
          text: 'Oops! Something went wrong. Please try again. ✈️\n\nError: $e',
          isUser: false,
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMessages()),
            _buildChips(),
            _buildInputRow(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: kDarkBrown,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: kWhite, shape: BoxShape.circle),
            child: const Center(child: Text('✈', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TravelBuddy',
                    style: TextStyle(color: kWhite, fontSize: 16,
                        fontWeight: FontWeight.bold, letterSpacing: .4)),
                Text('AI Travel Assistant',
                    style: TextStyle(color: kWhite, fontSize: 11)),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                    color: kWhite, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              const Text('Online',
                  style: TextStyle(color: kWhite, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Messages list ─────────────────────────────────────
  Widget _buildMessages() {
    return Container(
      color: kWhite,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) => _buildMessageItem(_messages[index]),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: msg.isUser
            ? [_buildBubble(msg), const SizedBox(width: 8), _buildAvatar(isUser: true)]
            : [_buildAvatar(isUser: false), const SizedBox(width: 8), _buildBubble(msg)],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: isUser ? kWhite : kDarkBrown,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          isUser ? 'YOU' : '✈',
          style: TextStyle(
            color: isUser ? kDarkBrown : kWhite,
            fontSize: isUser ? 8 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    return Flexible(
      child: Column(
        crossAxisAlignment:
        msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.68,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: msg.isUser ? kDarkBrown : kWhite,
              border: msg.isUser
                  ? null
                  : Border.all(color: kGrey, width: .5),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                bottomRight: Radius.circular(msg.isUser ? 4 : 16),
              ),
            ),
            child: msg.isTyping
                ? _buildTypingDots()
                : Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? kWhite : kBlack,
                fontSize: 13.5,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            DateFormat('h:mm a').format(msg.timestamp),
            style: const TextStyle(fontSize: 10, color: kWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => _AnimatedDot(delay: i * 200)),
    );
  }

  // ── Quick chips ───────────────────────────────────────
  Widget _buildChips() {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _chips.map((chip) {
            return Padding(
              padding: const EdgeInsets.only(right: 7),
              child: InkWell(
                onTap: _isLoading ? null : () => _sendMessage(chip['text']!),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kWhite,
                    border: Border.all(color: kGrey, width: .5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(chip['label']!,
                      style: const TextStyle(fontSize: 12, color: kBlack)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Input row ─────────────────────────────────────────
  Widget _buildInputRow() {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_isLoading,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Where do you want to go?',
                hintStyle: const TextStyle(color: kBlack),
                filled: true,
                fillColor: kWhite,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: kGrey, width: .5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: kGrey, width: .5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: kDarkBrown, width: 1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading ? null : () => _sendMessage(_controller.text),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _isLoading ? kWhite : kDarkBrown,
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? const Padding(
                padding: EdgeInsets.all(11),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: kWhite),
              )
                  : const Icon(Icons.send_rounded, color: kWhite, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.only(bottom: 6),
      child: const Center(
        child: Text('Powered by Firebase · TravelBuddy App',
            style: TextStyle(fontSize: 10, color: kGrey))),
      );
  }
}

// ── Animated typing dot ───────────────────────────────
class _AnimatedDot extends StatefulWidget {
  final int delay;
  const _AnimatedDot({required this.delay});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 7, height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
              color: kGrey, shape: BoxShape.circle),
        ),
      ),
    );
  }
}