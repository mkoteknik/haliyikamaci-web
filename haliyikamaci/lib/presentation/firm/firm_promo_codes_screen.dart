import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';

/// Firm Promo Codes Screen - Firma kampanya kodları yönetimi
class FirmPromoCodesScreen extends ConsumerWidget {
  const FirmPromoCodesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firmAsync = ref.watch(currentFirmProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kampanya Kodlarım'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkGray,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCodeDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Kod'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white, // Text ve Icon rengi düzeltildi
      ),
      body: firmAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (firm) {
          if (firm == null) return const Center(child: Text('Firma bulunamadı'));
          return _PromoCodesList(firmId: firm.id);
        },
      ),
    );
  }

  void _showAddCodeDialog(BuildContext context, WidgetRef ref) {
    final firmAsync = ref.read(currentFirmProvider);
    final firm = firmAsync.value;
    if (firm == null) return;

    final codeController = TextEditingController();
    final valueController = TextEditingController();
    final dateController = TextEditingController(); // Tarih gösterimi için
    
    // Varsayılan değerler
    String selectedType = PromoCodeModel.typePercent;
    int? usageLimit;
    DateTime? expiresAt;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header with Gradient
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withAlpha(200)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.stars, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Yeni Kampanya',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 2. Code Input
                      TextField(
                        controller: codeController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                        decoration: InputDecoration(
                          labelText: 'Kampanya Kodu',
                          hintText: 'Örn: YAZ10',
                          prefixIcon: const Icon(Icons.confirmation_number_outlined),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Discount Type (Visual Selection)
                      const Text('İndirim Türü', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeOption(
                              context: context,
                              title: 'Yüzde (%)',
                              value: PromoCodeModel.typePercent,
                              groupValue: selectedType,
                              icon: Icons.percent,
                              onChanged: (v) => setDialogState(() {
                                selectedType = v;
                                valueController.clear();
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeOption(
                              context: context,
                              title: 'Sabit (₺)',
                              value: PromoCodeModel.typeFixed,
                              groupValue: selectedType,
                              icon: Icons.attach_money,
                              onChanged: (v) => setDialogState(() {
                                selectedType = v;
                                valueController.clear();
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 4. Value Input
                      TextField(
                        controller: valueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: selectedType == PromoCodeModel.typePercent ? 'İndirim Oranı' : 'İndirim Tutarı',
                          suffixText: selectedType == PromoCodeModel.typePercent ? '%' : '₺',
                          prefixIcon: Icon(selectedType == PromoCodeModel.typePercent ? Icons.pie_chart_outline : Icons.currency_lira),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. Limits & Date Row
                      Row(
                        children: [
                          // Limit
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Limit',
                                hintText: '∞',
                                prefixIcon: const Icon(Icons.loop),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                              ),
                              onChanged: (v) => usageLimit = int.tryParse(v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Date
                          Expanded(
                            child: TextField(
                              controller: dateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Bitiş Tarihi',
                                hintText: 'Süresiz',
                                prefixIcon: const Icon(Icons.event),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                              ),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().add(const Duration(days: 30)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) {
                                  setDialogState(() {
                                    expiresAt = date;
                                    dateController.text = DateFormat('dd/MM/yyyy').format(date);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),

                      // 6. Action Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            final code = codeController.text.trim().toUpperCase();
                            final value = double.tryParse(valueController.text.replaceAll(',', '.')) ?? 0;

                            if (code.isEmpty || code.length < 3) {
                              _showError(context, 'Kampanya kodu en az 3 karakter olmalıdır.');
                              return;
                            }
                            if (value <= 0) {
                              _showError(context, 'Lütfen geçerli bir indirim değeri girin.');
                              return;
                            }
                            if ( selectedType == PromoCodeModel.typePercent && value > 100) {
                               _showError(context, 'Yüzde değeri 100\'den büyük olamaz.');
                               return;
                            }

                            // Check if code exists
                            final exists = await ref.read(promoCodeRepositoryProvider).codeExists(code);
                            if (exists) {
                              if (context.mounted) _showError(context, 'Bu kod zaten kullanımda, lütfen başka bir kod belirleyin.');
                              return;
                            }

                            Navigator.pop(ctx);

                            try {
                              final promo = PromoCodeModel(
                              id: '',
                              code: code,
                              type: selectedType,
                              value: value,
                              firmId: firm.id,
                              firmName: firm.name,
                              usageLimit: usageLimit,
                              expiresAt: expiresAt,
                              createdAt: DateTime.now(),
                            );
                            await ref.read(promoCodeRepositoryProvider).createPromoCode(promo);
                            if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('Kampanya kodu başarıyla oluşturuldu!')]), 
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                ),
                                );
                            }
                            } catch (e) {
                              if (context.mounted) _showError(context, 'Beklenmeyen bir hata oluştu: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Kampanyayı Oluştur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Vazgeç', style: TextStyle(color: Colors.grey[600])),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message), 
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  Widget _buildTypeOption({
    required BuildContext context,
    required String title,
    required String value,
    required String groupValue,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withAlpha(20) : Colors.grey[50], // alpha 20 ~ 0.08 opacity
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey[200]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryBlue : Colors.grey[500]),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryBlue : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCodesList extends ConsumerWidget {
  final String firmId;
  const _PromoCodesList({required this.firmId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codesStream = ref.watch(promoCodeRepositoryProvider).getFirmPromoCodes(firmId);

    return StreamBuilder<List<PromoCodeModel>>(
      stream: codesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final codes = snapshot.data ?? [];

        if (codes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('Henüz kampanya kodu yok', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  'Müşterilerinize indirim sunmak için\nkampanya kodu oluşturun',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: codes.length,
          itemBuilder: (context, index) => _PromoCodeCard(code: codes[index]),
        );
      },
    );
  }
}

class _PromoCodeCard extends ConsumerWidget {
  final PromoCodeModel code;
  const _PromoCodeCard({required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpired = code.expiresAt != null && DateTime.now().isAfter(code.expiresAt!);
    final isLimitReached = code.usageLimit != null && code.usageCount >= code.usageLimit!;
    final isInvalid = !code.isActive || isExpired || isLimitReached;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Code
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isInvalid ? Colors.grey[200] : AppTheme.primaryBlue.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    code.code,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isInvalid ? Colors.grey : AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Discount Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: code.type == PromoCodeModel.typePercent 
                        ? Colors.amber.withAlpha(40) 
                        : Colors.green.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    code.discountLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: code.type == PromoCodeModel.typePercent 
                          ? Colors.amber[800] 
                          : Colors.green[800],
                    ),
                  ),
                ),
                const Spacer(),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteCode(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stats
            Row(
              children: [
                _buildStat(Icons.confirmation_number, 'Kullanım', 
                    code.usageLimit != null 
                        ? '${code.usageCount}/${code.usageLimit}' 
                        : '${code.usageCount} (Sınırsız)'),
                const SizedBox(width: 24),
                _buildStat(Icons.calendar_today, 'Bitiş', 
                    code.expiresAt != null 
                        ? DateFormat('dd/MM/yyyy').format(code.expiresAt!) 
                        : 'Süresiz'),
              ],
            ),
            // Status
            if (isInvalid) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isExpired ? 'Süresi Doldu' : (isLimitReached ? 'Limit Doldu' : 'Pasif'),
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  void _deleteCode(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kodu Sil'),
        content: Text('"${code.code}" kodunu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(promoCodeRepositoryProvider).deletePromoCode(code.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kod silindi'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
