import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/theme/customer_theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import '../../data/providers/providers.dart';
import 'customer_tickets_screen.dart'; // Import for navigation

/// Support Chat Screen
/// - Müşteri için: Bot ve Ticket Sistemi
/// - Firma için: Admin ile Direkt Mesajlaşma
class SupportChatScreen extends ConsumerStatefulWidget {
  final String? firmId; // Müşteri-Firma için hedef firma
  final String? firmName;
  final bool isCustomerToFirm; // true: Müşteri görünümlü, false: Firma görünümlü
  final String? ticketId; // [NEW] Ticket Mode if not null

  const SupportChatScreen({
    super.key,
    this.firmId,
    this.firmName,
    this.isCustomerToFirm = true,
    this.ticketId,
  });

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Bot/Ticket State
  final List<ChatMessageModel> _localMessages = [];
  bool _showTicketButton = false;
  bool _isLoading = false;
  String? _selectedCategory;
  String? _selectedOrderId;

  @override
  void initState() {
    super.initState();
    // Eğer müşteri ise ve Ticket Modunda DEĞİLSE Bot mesajı ile başlat
    if (widget.isCustomerToFirm && widget.ticketId == null) {
      _addBotMessage('Merhaba! 👋\n\nSize nasıl yardımcı olabilirim? Aşağıdaki konulardan birini seçebilir veya sorunuzu yazabilirsiniz.');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Eğer Stream varsa (Firma modu veya Ticket modu) reverse: true olduğu için 0'a git.
      // Eğer Bot ise (Bot modu) reverse: false olduğu için maxScrollExtent.
      final useStream = !widget.isCustomerToFirm || widget.ticketId != null;
      final position = useStream ? 0.0 : _scrollController.position.maxScrollExtent;
      
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ==================== FIRM MODE: DIRECT CHAT ====================
  // (Left unchanged for brevity logic, but practically Firm Mode is also Ticket Mode technically in new design? 
  //  Actually Firm mode was using 'support_channels'. We leave it as is for now unless requested.)
  Widget _buildFirmDirectChat() {
    final firm = ref.watch(currentFirmProvider).value;
    if (firm == null) return const Center(child: CircularProgressIndicator());

    final chatPath = 'support_channels/${firm.id}/messages';
    final chatStream = ref.watch(chatRepositoryProvider).getMessages(chatPath);

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessageModel>>(
            stream: chatStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final messages = snapshot.data!;
              if (messages.isEmpty) {
                return Center(
                  child: Text('Yönetici ile sohbet başlatın.', style: TextStyle(color: Colors.grey[400])),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  // Firma (biz) isek senderId firm.id olmalı
                  final isMe = msg.senderId == firm.id;
                  return _buildMessageBubble(msg.message, isMe, msg.createdAt);
                },
              );
            },
          ),
        ),
        _buildInputArea(isStreamChat: true),
      ],
    );
  }

  // ==================== CUSTOMER TICKET MODE ====================
  Widget _buildTicketChat(String ticketId) {
     final customer = ref.watch(currentCustomerProvider).value;
     if (customer == null) return const Center(child: CircularProgressIndicator());

     final messagesStream = ref.watch(supportRepositoryProvider).getTicketMessages(ticketId);

     return Column(
       children: [
         Expanded(
           child: StreamBuilder<List<TicketMessageModel>>(
             stream: messagesStream,
             builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final messages = snapshot.data ?? [];
                
                if (messages.isEmpty) {
                  return const Center(child: Text('Henüz mesaj yok.'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // New logic uses descending order
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == customer.id;
                    return _buildMessageBubble(msg.message, isMe, msg.createdAt);
                  },
                );
             },
           ),
         ),
         _buildInputArea(isStreamChat: true),
       ],
     );
  }

  Future<void> _sendTicketMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || widget.ticketId == null) return;
    
    final customer = ref.read(currentCustomerProvider).value;
    if (customer == null) return;

    _messageController.clear();
    
    final msg = TicketMessageModel(
      id: '',
      ticketId: widget.ticketId!,
      senderId: customer.id,
      senderName: customer.fullName,
      senderType: 'customer',
      message: text,
      createdAt: DateTime.now(),
      isRead: false,
    );
    
    try {
       await ref.read(supportRepositoryProvider).sendMessage(msg);
       _scrollToBottom();
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  // ==================== CUSTOMER BOT MODE ====================

  void _addBotMessage(String message) {
    setState(() {
      _localMessages.add(ChatMessageModel(
        id: 'bot',
        senderId: 'bot',
        senderName: 'Destek Asistanı',
        message: message,
        createdAt: DateTime.now(),
        isRead: true,
      ));
    });
    Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
  }

  void _addUserMessage(String message) {
    setState(() {
      _localMessages.add(ChatMessageModel(
        id: 'user',
        senderId: 'user', 
        senderName: 'Siz',
        message: message,
        createdAt: DateTime.now(),
        isRead: true,
      ));
    });
    Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
  }

  Future<void> _handleBotLogic() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _addUserMessage(text);
    setState(() => _isLoading = true);

    // FAQ Search
    final supportRepo = ref.read(supportRepositoryProvider);
    final matchedFaq = await supportRepo.findFaqByKeywords(text);
    
    await Future.delayed(const Duration(milliseconds: 800)); // Fake typing

    setState(() => _isLoading = false);

    if (matchedFaq != null) {
      _addBotMessage(matchedFaq.answer);
      _addBotMessage('Bu cevap yardımcı oldu mu?');
      setState(() => _showTicketButton = true);
    } else {
      _addBotMessage('Bunu anlayamadım. 🤔 İsterseniz bir destek talebi oluşturabilirsiniz.');
      setState(() => _showTicketButton = true);
    }
  }

  Future<void> _createTicket() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TicketCreationSheet(
        onConfirm: (category, orderId) async {
            _selectedCategory = category;
            _selectedOrderId = orderId;
            Navigator.pop(context);
            await _submitTicket();
        },
      ),
    );
  }

  Future<void> _submitTicket() async {
    final customer = ref.read(currentCustomerProvider).value;
    if (customer == null) return;

    final lastUserMsg = _localMessages.lastWhere((m) => m.senderId == 'user', orElse: () => _localMessages.first);

    final ticket = TicketModel(
      id: '',
      channel: TicketModel.channelCustomerFirm,
      senderId: customer.id,
      senderName: customer.fullName,
      senderType: 'customer',
      receiverId: widget.firmId ?? 'admin', 
      receiverName: widget.firmName ?? 'Yönetim',
      subject: _selectedCategory ?? 'Genel Destek',
      lastMessage: lastUserMsg.message,
      status: TicketModel.statusOpen,
      unreadCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: _selectedCategory,
      relatedOrderId: _selectedOrderId,
    );

    try {
      final repo = ref.read(supportRepositoryProvider);
      final ticketId = await repo.createTicket(ticket);
      
      // Save initial message history
      for (var m in _localMessages.where((x) => x.senderId == 'user')) {
          await repo.sendMessage(TicketMessageModel(
            id: '', 
            ticketId: ticketId, 
            senderId: customer.id, 
            senderName: customer.fullName, 
            senderType: 'customer', 
            message: m.message, 
            createdAt: m.createdAt
          ));
      }

      _addBotMessage('✅ Destek talebiniz oluşturuldu! (No: #${ticketId.substring(0,6).toUpperCase()})\nİlgili sipariş ve kategori bilgisi eklendi.');
      setState(() => _showTicketButton = false);
      
      // Opsiyonel: Direkt Ticket sohbetine yönlendir?
      // Şimdilik burada kalalım.
    } catch (e) {
      _addBotMessage('Hata oluştu: $e');
    }
  }

  Widget _buildBotChat() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _localMessages.length + (_isLoading ? 1 : 0) + (_showTicketButton ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _localMessages.length) {
                final msg = _localMessages[index];
                return _buildMessageBubble(msg.message, msg.senderId == 'user', msg.createdAt);
              } else if (_isLoading && index == _localMessages.length) {
                return _buildTypingIndicator();
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: _createTicket,
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Destek Talebi Oluştur'),
                  ),
                );
              }
            },
          ),
        ),
        if (_localMessages.length < 2)
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Wrap(
                 spacing: 8, 
                 children: ['Fiyatlar', 'Teslimat Süresi', 'Ödeme', 'Sipariş İptali']
                  .map((t) => ActionChip(label: Text(t), onPressed: () {
                    _messageController.text = t;
                    _handleBotLogic();
                  })).toList(),
               ),
             ),
        _buildInputArea(isStreamChat: false),
      ],
    );
  }

  Widget _buildInputArea({required bool isStreamChat}) {
    // If ticket mode (widget.ticketId != null) OR firm mode (!isCustomerToFirm), use Stream logic
    // Actually simpler: if Bot Mode, use bot logic. Else use stream/ticket logic.
    final isBotMode = widget.isCustomerToFirm && widget.ticketId == null;

    void handleSubmit() {
      if (isBotMode) {
        _handleBotLogic();
      } else if (widget.ticketId != null) {
        _sendTicketMessage();
      } else {
        _sendDirectMessage(); // Old Firm ID logic
      }
    }

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
                  hintText: 'Mesajınızı yazın...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onSubmitted: (_) => handleSubmit(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: CustomerTheme.primary),
              onPressed: handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
  
  // Previous Firm Direct logic helper for compatibility
  Future<void> _sendDirectMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final firm = ref.read(currentFirmProvider).value;
    if (firm == null) return;
    
    _messageController.clear();
    
    try {
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'haliyikamacimmbldatabase',
      );
      
      final channelId = firm.id; // Use firm.id as channel ID
      final channelRef = firestore.collection('support_channels').doc(channelId);
      final messagesRef = channelRef.collection('messages');
      
      // 1. Add message to subcollection
      // CRITICAL: Use 'timestamp' field (not createdAt) for Admin Panel compatibility
      await messagesRef.add({
        'message': text,
        'senderId': firm.id,
        'senderName': firm.name,
        'timestamp': FieldValue.serverTimestamp(), // Admin Panel uses 'timestamp'
        'isRead': false,
      });
      
      // 2. Update/Create parent channel document with metadata
      await channelRef.set({
        'firmId': firm.id,
        'firmName': firm.name,
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': firm.id,
        'unreadCountAdmin': FieldValue.increment(1), // Increment admin unread
        'hasUnreadForFirm': false, // Firm just sent, so they've read it
      }, SetOptions(merge: true));
      
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mesaj gönderilemedi: $e')),
        );
      }
    }
  }
  
  Widget _buildMessageBubble(String message, bool isMe, DateTime time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? CustomerTheme.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
            Text('${time.hour}:${time.minute.toString().padLeft(2,'0')}', style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypingIndicator() {
     return const Padding(padding: EdgeInsets.all(8), child: Text('Yazıyor...'));
  }

  @override
  Widget build(BuildContext context) {
    final isBotMode = widget.isCustomerToFirm && widget.ticketId == null;
    final isTicketMode = widget.isCustomerToFirm && widget.ticketId != null;

    return Scaffold(
      backgroundColor: CustomerTheme.background,
      appBar: AppBar(
        title: Text(isTicketMode 
            ? 'Destek Talebi #${widget.ticketId!.substring(0,4)}' 
            : (widget.isCustomerToFirm ? 'Destek Asistanı' : 'Yönetici Desteği')),
        backgroundColor: widget.isCustomerToFirm ? CustomerTheme.secondary : CustomerTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (isBotMode) // Only show history button in Bot Mode
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Geçmiş Taleplerim',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerTicketsScreen()),
                );
              },
            ),
        ],
      ),
      body: isBotMode 
          ? _buildBotChat() 
          : (isTicketMode ? _buildTicketChat(widget.ticketId!) : _buildFirmDirectChat()),
    );
  }
}

// Helper Sheet for Ticket Creation
class _TicketCreationSheet extends ConsumerStatefulWidget {
  final Function(String category, String? orderId) onConfirm;
  const _TicketCreationSheet({required this.onConfirm});

  @override
  ConsumerState<_TicketCreationSheet> createState() => _TicketCreationSheetState();
}

class _TicketCreationSheetState extends ConsumerState<_TicketCreationSheet> {
  String _selectedCategory = 'Genel Sorun';
  String? _selectedOrderId;

  final List<String> _categories = ['Genel Sorun', 'Sipariş Durumu', 'Ödeme Sorunu', 'Şikayet', 'Öneri'];

  @override
  Widget build(BuildContext context) {
    // Fetch last orders
    final ordersAsync = ref.watch(orderRepositoryProvider).getOrdersByCustomer(
      ref.read(currentCustomerProvider).value!.id,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Destek Talebi Detayları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Kategori'),
          DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
          const SizedBox(height: 16),
          const Text('İlgili Sipariş (Opsiyonel)'),
          Expanded(
            child: FutureBuilder<List<OrderModel>>(
              future: ordersAsync.first, // Just get once for now
              builder: (context, snapshot) {
                 if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                 final orders = snapshot.data!;
                 return ListView.builder(
                   itemCount: orders.length + 1,
                   itemBuilder: (context, index) {
                     if (index == 0) {
                       return RadioListTile<String?>(
                         title: const Text('Siparişle İlgili Değil / Diğer'),
                         value: null,
                         groupValue: _selectedOrderId,
                         onChanged: (v) => setState(() => _selectedOrderId = v),
                       );
                     }
                     final order = orders[index - 1];
                     return RadioListTile<String?>(
                       title: Text('Sipariş #${order.id.substring(0,6).toUpperCase()} - ${order.status}'),
                       subtitle: Text(order.firmName),
                       value: order.id,
                       groupValue: _selectedOrderId,
                       onChanged: (v) => setState(() => _selectedOrderId = v),
                     );
                   },
                 );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onConfirm(_selectedCategory, _selectedOrderId),
              child: const Text('Talebi Oluştur'),
            ),
          ),
        ],
      ),
    );
  }
}
