import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/accounting_entry_model.dart';
import '../../data/repositories/accounting_repository.dart';
import '../../data/providers/providers.dart';

/// Muhasebe ekranı için provider'lar
final accountingRepositoryProvider = Provider((ref) => AccountingRepository());

final accountingEntriesProvider =
    StreamProvider.family<List<AccountingEntryModel>, String>((ref, firmId) {
  final repo = ref.watch(accountingRepositoryProvider);
  return repo.getEntriesByFirm(firmId);
});

final accountingStatsProvider =
    FutureProvider.family<Map<String, double>, String>((ref, firmId) {
  final repo = ref.watch(accountingRepositoryProvider);
  return repo.getStats(firmId);
});

/// Firma Ön Muhasebe Ekranı
class FirmAccountingScreen extends ConsumerStatefulWidget {
  const FirmAccountingScreen({super.key});

  @override
  ConsumerState<FirmAccountingScreen> createState() =>
      _FirmAccountingScreenState();
}

class _FirmAccountingScreenState extends ConsumerState<FirmAccountingScreen> {
  final _currencyFormat =
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final firmAsync = ref.watch(currentFirmProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ön Muhasebe'),
        centerTitle: true,
        elevation: 0,
      ),
      body: firmAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (firm) {
          if (firm == null) {
            return const Center(child: Text('Firma bulunamadı'));
          }
          return _buildContent(firm.id);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Giriş'),
      ),
    );
  }

  Widget _buildContent(String firmId) {
    final statsAsync = ref.watch(accountingStatsProvider(firmId));
    final entriesAsync = ref.watch(accountingEntriesProvider(firmId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(accountingStatsProvider(firmId));
        ref.invalidate(accountingEntriesProvider(firmId));
      },
      child: CustomScrollView(
        slivers: [
          // Özet Kartları
          SliverToBoxAdapter(
            child: statsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('İstatistik hatası: $e'),
              ),
              data: (stats) => _buildStatsCards(stats),
            ),
          ),

          // Başlık
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'İşlem Geçmişi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // İşlem Listesi
          entriesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Hata: $e')),
            ),
            data: (entries) {
              if (entries.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Henüz işlem kaydı yok',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Yeni giriş eklemek için + butonuna tıklayın',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildEntryTile(entries[index]),
                  childCount: entries.length,
                ),
              );
            },
          ),

          // Alt boşluk (FAB için)
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Map<String, double> stats) {
    final income = stats['totalIncome'] ?? 0;
    final expense = stats['totalExpense'] ?? 0;
    final net = stats['netBalance'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Gelir',
              income,
              Colors.green,
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Gider',
              expense,
              Colors.red,
              Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Net',
              net,
              net >= 0 ? Colors.blue : Colors.orange,
              Icons.account_balance_wallet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _currencyFormat.format(value),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryTile(AccountingEntryModel entry) {
    final isIncome = entry.isIncome;
    final color = isIncome ? Colors.green : Colors.red;
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Dismissible(
      key: Key(entry.id),
      direction: entry.isAutomatic
          ? DismissDirection.none
          : DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (entry.isAutomatic) return false;
        return await _confirmDelete(entry);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
          ),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.description?.isNotEmpty == true)
              Text(
                entry.description!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Row(
              children: [
                Text(
                  dateFormat.format(entry.date),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: entry.isAutomatic
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.isAutomatic ? 'Otomatik' : 'Manuel',
                    style: TextStyle(
                      fontSize: 10,
                      color: entry.isAutomatic ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${_currencyFormat.format(entry.amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        onTap: entry.isAutomatic ? null : () => _showEditEntryDialog(entry),
        onLongPress: entry.isAutomatic ? null : () => _showEntryOptions(entry),
      ),
    );
  }

  Future<bool> _confirmDelete(AccountingEntryModel entry) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
        content: Text('"${entry.title}" kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final repo = ref.read(accountingRepositoryProvider);
        await repo.deleteEntry(entry.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt silindi')),
          );
        }
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
    return false;
  }

  void _showEntryOptions(AccountingEntryModel entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(context);
                _showEditEntryDialog(entry);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Sil', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(entry);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _EntryFormSheet(
        onSave: (type, title, amount, description) async {
          final firm = ref.read(currentFirmProvider).valueOrNull;
          if (firm == null) return;

          final repo = ref.read(accountingRepositoryProvider);
          if (type == 'income') {
            await repo.createManualIncomeEntry(
              firmId: firm.id,
              title: title,
              amount: amount,
              description: description,
            );
          } else {
            await repo.createManualExpenseEntry(
              firmId: firm.id,
              title: title,
              amount: amount,
              description: description,
            );
          }

          // Stats'ı yenile
          ref.invalidate(accountingStatsProvider(firm.id));
        },
      ),
    );
  }

  void _showEditEntryDialog(AccountingEntryModel entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _EntryFormSheet(
        entry: entry,
        onSave: (type, title, amount, description) async {
          final repo = ref.read(accountingRepositoryProvider);
          await repo.updateEntry(entry.id, {
            'type': type,
            'title': title,
            'amount': amount,
            'description': description,
          });

          final firm = ref.read(currentFirmProvider).valueOrNull;
          if (firm != null) {
            ref.invalidate(accountingStatsProvider(firm.id));
          }
        },
      ),
    );
  }
}

/// Giriş Formu Sheet
class _EntryFormSheet extends StatefulWidget {
  final AccountingEntryModel? entry;
  final Future<void> Function(
    String type,
    String title,
    double amount,
    String? description,
  ) onSave;

  const _EntryFormSheet({
    this.entry,
    required this.onSave,
  });

  @override
  State<_EntryFormSheet> createState() => _EntryFormSheetState();
}

class _EntryFormSheetState extends State<_EntryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _type = widget.entry?.type ?? 'income';
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _amountController = TextEditingController(
      text: widget.entry?.amount.toStringAsFixed(2) ?? '',
    );
    _descriptionController =
        TextEditingController(text: widget.entry?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Kaydı Düzenle' : 'Yeni Kayıt Ekle',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tür Seçimi
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Gelir',
                      icon: Icons.arrow_upward,
                      color: Colors.green,
                      isSelected: _type == 'income',
                      onTap: () => setState(() => _type = 'income'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeButton(
                      label: 'Gider',
                      icon: Icons.arrow_downward,
                      color: Colors.red,
                      isSelected: _type == 'expense',
                      onTap: () => setState(() => _type = 'expense'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Başlık
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Örn: Nakit Tahsilat',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v?.isEmpty == true ? 'Başlık gerekli' : null,
              ),
              const SizedBox(height: 12),

              // Tutar
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tutar (₺)',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_lira),
                ),
                validator: (v) {
                  if (v?.isEmpty == true) return 'Tutar gerekli';
                  final amount = double.tryParse(v!.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) {
                    return 'Geçerli bir tutar girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Açıklama
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  hintText: 'Not ekleyin...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 20),

              // Kaydet Butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _type == 'income' ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? 'Güncelle' : 'Kaydet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(
        _amountController.text.replaceAll(',', '.'),
      );

      await widget.onSave(
        _type,
        _titleController.text.trim(),
        amount,
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.entry != null ? 'Kayıt güncellendi' : 'Kayıt eklendi',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Tür Seçim Butonu
class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
