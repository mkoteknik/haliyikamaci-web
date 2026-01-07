import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/customer_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import 'support_chat_screen.dart';

class CustomerTicketsScreen extends ConsumerWidget {
  const CustomerTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(currentCustomerProvider).value;
    
    if (customer == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ticketsStream = ref.watch(supportRepositoryProvider).getUserTickets(customer.id);

    return Scaffold(
      backgroundColor: CustomerTheme.background,
      appBar: AppBar(
        title: const Text('Geçmiş Taleplerim'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: ticketsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.history, size: 64, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   const Text('Henüz geçmiş talebiniz bulunmuyor', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _buildTicketCard(context, ticket);
            },
          );
        },
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, TicketModel ticket) {
    final dateFormatter = DateFormat('dd MMM HH:mm', 'tr_TR');
    
    // Status Config
    Color statusColor;
    String statusText;
    
    switch (ticket.status) {
      case TicketModel.statusOpen:
        statusColor = Colors.orange;
        statusText = 'Açık';
        break;
      case TicketModel.statusAnswered:
        statusColor = Colors.green;
        statusText = 'Yanıtlandı';
        break;
      case TicketModel.statusClosed:
        statusColor = Colors.grey;
        statusText = 'Kapalı';
        break;
      default:
        statusColor = Colors.grey;
        statusText = ticket.status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupportChatScreen(
                isCustomerToFirm: true,
                ticketId: ticket.id, // Ticket Mode
                firmName: ticket.receiverName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withAlpha(100)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'No: #${ticket.id.substring(0, 6).toUpperCase()}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    dateFormatter.format(ticket.updatedAt),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              if (ticket.lastMessage.isNotEmpty) ...[
                const Divider(height: 16),
                Text(
                  ticket.lastMessage,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
