import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/customer_theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import '../../data/providers/providers.dart';

class OrderChatScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String firmId;
  final String firmName;

  const OrderChatScreen({
    super.key,
    required this.orderId,
    required this.firmId,
    required this.firmName,
  });

  @override
  ConsumerState<OrderChatScreen> createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends ConsumerState<OrderChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // Reversed listview
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Check if sender is a firm or customer
    final firm = ref.read(currentFirmProvider).value;
    final customer = ref.read(currentCustomerProvider).value;
    
    String senderId;
    String senderName;
    bool isFirmSender = false;
    
    if (firm != null) {
      // Sender is a firm
      senderId = firm.id;
      senderName = firm.name;
      isFirmSender = true;
    } else if (customer != null) {
      // Sender is a customer
      senderId = customer.id;
      senderName = customer.fullName;
    } else {
      // No user logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oturum bulunamadı')),
      );
      return;
    }

    _messageController.clear();

    final message = ChatMessageModel(
      id: '', // Firestore auto-id
      senderId: senderId,
      senderName: senderName,
      message: messageText,
      createdAt: DateTime.now(),
      type: 'text',
    );

    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.sendMessage('orders/${widget.orderId}/messages', message);
      _scrollToBottom();
      
      // Send notification to recipient
      final notificationRepo = NotificationRepository();
      final orderRepo = ref.read(orderRepositoryProvider);
      final order = await orderRepo.getOrderById(widget.orderId);
      
      if (order != null) {
        if (isFirmSender) {
          // Firm sent message -> notify customer
          await notificationRepo.notifyNewOrderMessage(
            targetUserId: order.customerId,
            targetUserType: 'customer',
            orderId: widget.orderId,
            senderName: senderName,
          );
        } else {
          // Customer sent message -> notify firm
          await notificationRepo.notifyNewOrderMessage(
            targetUserId: order.firmId,
            targetUserType: 'firm',
            orderId: widget.orderId,
            senderName: senderName,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mesaj gönderilemedi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatStream = ref.watch(chatRepositoryProvider).getMessages('orders/${widget.orderId}/messages');

    return Scaffold(
      backgroundColor: CustomerTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.firmName, style: const TextStyle(fontSize: 16)),
            Text(
              'Sipariş #${widget.orderId.substring(0, 6).toUpperCase()}', 
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
               // Order detail redirect could go here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: chatStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                
                // Get current user ID (firm or customer)
                final firm = ref.watch(currentFirmProvider).value;
                final customer = ref.watch(currentCustomerProvider).value;
                final currentUserId = firm?.id ?? customer?.id;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          firm != null 
                            ? 'Henüz mesaj yok.\nMüşteriye mesaj gönderin.'
                            : 'Henüz mesaj yok.\nFirmaya soru sorabilirsiniz.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Messages start from bottom
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? CustomerTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Mesaj yazın...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              mini: true,
              onPressed: _sendMessage,
              backgroundColor: CustomerTheme.primary,
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
