import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realestate/pages/chat_page.dart';
import 'package:realestate/services/chat_service.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final ChatService _chatService = ChatService();
  final user = FirebaseAuth.instance.currentUser;

  String? selectedUserID;
  String? selectedEmail;
  String? selectedName;
  String? selectedProfilePicture;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Messenger",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
              ),
        ),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurfaceVariant,
        elevation: 0,
      ),
      body: isDesktop
          ? Row(
              children: [
                Flexible(flex: 3, child: _buildUserList(isDesktop: true)),

                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor,
                ),

                Flexible(
                  flex: 7,
                  child: selectedUserID == null
                      ? Center(
                          child: Text(
                            "Select a conversation",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        )
                      : ChatPage(
                          receiverID: selectedUserID!,
                          receiverEmail: selectedEmail!,
                          receiverName: selectedName!,
                          receiverProfilePicture: selectedProfilePicture!,
                        ),
                ),
              ],
            )
          : _buildUserList(isDesktop: false),
    );
  }

  Widget _buildUserList({required bool isDesktop}) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUsersStream(orderBy: 'email'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading users",
              style: textTheme.bodyLarge?.copyWith(color: scheme.error),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: scheme.primary,
            ),
          );
        }

        final users = snapshot.data!;
        final otherUsers = users.where((u) => u['email'] != user!.email).toList();

        if (otherUsers.isEmpty) {
          return Center(
            child: Text(
              "No other users found",
              style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          );
        }

        return ListView.builder(
          itemCount: otherUsers.length,
          itemBuilder: (context, index) {
            final userData = otherUsers[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: userData["profilePicture"] != null &&
                        userData["profilePicture"].toString().isNotEmpty
                    ? NetworkImage(userData["profilePicture"])
                    : null,
                backgroundColor: scheme.surfaceVariant,
                child: (userData["profilePicture"] == null ||
                        userData["profilePicture"].toString().isEmpty)
                    ? Text(
                        userData["name"].isNotEmpty
                            ? userData["name"][0].toUpperCase()
                            : "?",
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(
                userData["name"] ?? userData["email"],
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
              ),
              selected: selectedUserID == userData['uid'],
              selectedTileColor: scheme.surfaceVariant.withOpacity(0.4), // 
              onTap: () {
                if (isDesktop) {
                  setState(() {
                    selectedUserID = userData["uid"];
                    selectedEmail = userData["email"];
                    selectedName = userData["name"] ?? userData["email"];
                    selectedProfilePicture = userData["profilePicture"] ?? "";
                  });
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        receiverEmail: userData["email"],
                        receiverID: userData["uid"],
                        receiverName: userData["name"] ?? userData["email"],
                        receiverProfilePicture: userData["profilePicture"] ?? "",
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}