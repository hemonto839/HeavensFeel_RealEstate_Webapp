import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:realestate/accessories/components.dart/chat_bubble.dart';
import 'package:realestate/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  final String receiverName;
  final String? receiverProfilePicture;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
    required this.receiverName,
    this.receiverProfilePicture,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final user = FirebaseAuth.instance.currentUser;

  final ScrollController _scrollController = ScrollController();
  final FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () => scrollDown());
      }
    });
    Future.delayed(const Duration(milliseconds: 300), () => scrollDown());
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverID,
        _messageController.text,
      );
      _messageController.clear();
      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      // ✅ Mobile AppBar
      appBar: isDesktop
          ? null
          : AppBar(
              leading: const BackButton(),
              title: Text(widget.receiverName,
                  style: textTheme.titleMedium?.copyWith(
                      color: scheme.onSurface, fontWeight: FontWeight.bold)),
              backgroundColor: scheme.surface,
              foregroundColor: scheme.onSurfaceVariant,
              elevation: 0,
            ),
      body: Column(
        children: [
          if (isDesktop) _buildDesktopHeader(context), // ✅ Desktop header
          Expanded(child: _buildMessageList()),
          _buildUserInput(context),
        ],
      ),
    );
  }

  /// ✅ Chat header for desktop (instead of mobile AppBar)
  Widget _buildDesktopHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outline.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: scheme.primary.withOpacity(0.2),
            backgroundImage: widget.receiverProfilePicture != null &&
                    widget.receiverProfilePicture!.isNotEmpty
                ? NetworkImage(widget.receiverProfilePicture!)
                : null,
            child: (widget.receiverProfilePicture == null ||
                    widget.receiverProfilePicture!.isEmpty)
                ? Text(
                    widget.receiverName.isNotEmpty
                        ? widget.receiverName[0].toUpperCase()
                        : "?",
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.receiverName,
                  style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface, fontWeight: FontWeight.bold)),
              Text(widget.receiverEmail,
                  style: textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = user!.uid;
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text("Error loading messages",
                  style: TextStyle(color: scheme.error)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: scheme.primary));
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollDown());

        return ListView.builder(
          controller: _scrollController,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return _buildMessageItem(doc);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == user!.uid;

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: ChatBubble(
        message: data["message"],
        isCurrentUser: isCurrentUser,
      ),
    );
  }

  Widget _buildUserInput(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: myFocusNode,
              onSubmitted: (_) => sendMessage(),
              style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
                filled: true,
                fillColor: scheme.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: scheme.primary, // ✅ Theme primary send button
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(Icons.send, color: scheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}