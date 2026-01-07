import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';

/// Widget for displaying legal agreement checkboxes during registration
class LegalAgreementsWidget extends ConsumerStatefulWidget {
  final Function(bool allAccepted) onAgreementChanged;
  final bool showKvkk;
  final bool showPrivacyPolicy;
  final bool showUserAgreement;

  const LegalAgreementsWidget({
    super.key,
    required this.onAgreementChanged,
    this.showKvkk = true,
    this.showPrivacyPolicy = true,
    this.showUserAgreement = true,
  });

  @override
  ConsumerState<LegalAgreementsWidget> createState() => _LegalAgreementsWidgetState();
}

class _LegalAgreementsWidgetState extends ConsumerState<LegalAgreementsWidget> {
  bool _kvkkAccepted = false;
  bool _privacyAccepted = false;
  bool _userAgreementAccepted = false;

  void _checkAllAccepted() {
    bool allAccepted = true;
    
    if (widget.showKvkk && !_kvkkAccepted) allAccepted = false;
    if (widget.showPrivacyPolicy && !_privacyAccepted) allAccepted = false;
    if (widget.showUserAgreement && !_userAgreementAccepted) allAccepted = false;
    
    widget.onAgreementChanged(allAccepted);
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(legalDocumentsProvider);

    return docsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildOfflineAgreements(),
      data: (docs) => _buildAgreementsList(docs),
    );
  }

  Widget _buildAgreementsList(List<LegalDocumentModel> docs) {
    final kvkkDoc = docs.where((d) => d.type == LegalDocumentModel.typeKvkk).firstOrNull;
    final privacyDoc = docs.where((d) => d.type == LegalDocumentModel.typePrivacyPolicy).firstOrNull;
    final userAgreementDoc = docs.where((d) => d.type == LegalDocumentModel.typeUserAgreement).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Yasal Bilgilendirmeler',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        
        if (widget.showKvkk)
          _buildAgreementCheckbox(
            title: 'KVKK Aydınlatma Metni',
            subtitle: "KVKK Aydınlatma Metni'ni okudum ve anladım.",
            value: _kvkkAccepted,
            document: kvkkDoc,
            onChanged: (val) {
              setState(() => _kvkkAccepted = val ?? false);
              _checkAllAccepted();
            },
          ),
        
        if (widget.showPrivacyPolicy)
          _buildAgreementCheckbox(
            title: 'Gizlilik Politikası',
            subtitle: "Gizlilik Politikası'nı okudum ve kabul ediyorum.",
            value: _privacyAccepted,
            document: privacyDoc,
            onChanged: (val) {
              setState(() => _privacyAccepted = val ?? false);
              _checkAllAccepted();
            },
          ),
        
        if (widget.showUserAgreement)
          _buildAgreementCheckbox(
            title: 'Kullanıcı Sözleşmesi',
            subtitle: "Kullanıcı Sözleşmesi'ni okudum ve kabul ediyorum.",
            value: _userAgreementAccepted,
            document: userAgreementDoc,
            onChanged: (val) {
              setState(() => _userAgreementAccepted = val ?? false);
              _checkAllAccepted();
            },
          ),
      ],
    );
  }

  Widget _buildAgreementCheckbox({
    required String title,
    required String subtitle,
    required bool value,
    required LegalDocumentModel? document,
    required Function(bool?) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.accentGreen,
        title: Row(
          children: [
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        subtitle: InkWell(
          onTap: () {
            if (document != null) {
              _showDocumentContent(document);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Doküman yüklenemedi. Lütfen tekrar deneyin.')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '📄 $title metnini oku',
              style: TextStyle(
                color: document != null ? AppTheme.primaryBlue : Colors.grey,
                decoration: TextDecoration.underline,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
      ),
    );
  }

  Widget _buildOfflineAgreements() {
    // Fallback: Create default documents so links are still clickable
    final now = DateTime.now();
    final defaultKvkk = LegalDocumentModel(
      id: 'default_kvkk',
      type: LegalDocumentModel.typeKvkk,
      title: 'KVKK Aydınlatma Metni',
      content: _defaultKvkkContent,
      version: '1.0',
      updatedAt: now,
    );
    
    final defaultPrivacy = LegalDocumentModel(
      id: 'default_privacy',
      type: LegalDocumentModel.typePrivacyPolicy,
      title: 'Gizlilik Politikası',
      content: _defaultPrivacyContent,
      version: '1.0',
      updatedAt: now,
    );

    final defaultAgreement = LegalDocumentModel(
      id: 'default_agreement',
      type: LegalDocumentModel.typeUserAgreement,
      title: 'Kullanıcı Sözleşmesi',
      content: _defaultUserAgreementContent,
      version: '1.0',
      updatedAt: now,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Yasal Bilgilendirmeler (Çevrimdışı Mod)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange),
          ),
        ),
        
        if (widget.showKvkk)
          _buildAgreementCheckbox(
            title: 'KVKK Aydınlatma Metni',
            subtitle: "KVKK Aydınlatma Metni'ni okudum ve anladım.",
            value: _kvkkAccepted,
            document: defaultKvkk,
            onChanged: (val) {
              setState(() => _kvkkAccepted = val ?? false);
              _checkAllAccepted();
            },
          ),
        
        if (widget.showPrivacyPolicy)
          _buildAgreementCheckbox(
            title: 'Gizlilik Politikası',
            subtitle: "Gizlilik Politikası'nı okudum ve kabul ediyorum.",
            value: _privacyAccepted,
            document: defaultPrivacy,
            onChanged: (val) {
              setState(() => _privacyAccepted = val ?? false);
              _checkAllAccepted();
            },
          ),
        
        if (widget.showUserAgreement)
          _buildAgreementCheckbox(
            title: 'Kullanıcı Sözleşmesi',
            subtitle: "Kullanıcı Sözleşmesi'ni okudum ve kabul ediyorum.",
            value: _userAgreementAccepted,
            document: defaultAgreement,
            onChanged: (val) {
              setState(() => _userAgreementAccepted = val ?? false);
              _checkAllAccepted();
            },
          ),
      ],
    );
  }

  // Default Contents for Offline/Fallback Mode
  static const String _defaultPrivacyContent = '''
# Gizlilik Politikası

## 1. Veri Toplama
Halı Yıkamacı uygulaması, hizmet sunabilmek için ad, telefon ve adres bilgilerinizi toplar.

## 2. Veri Güvenliği
Verileriniz güvenli sunucularda saklanır ve izniniz olmadan paylaşılmaz.

## 3. İletişim
Sorularınız için bizimle iletişime geçebilirsiniz.
''';

  static const String _defaultKvkkContent = '''
# KVKK Aydınlatma Metni

6698 sayılı KVKK kapsamında verileriniz işlenmektedir.

## 1. Amaç
Hizmet sunumu ve yasal yükümlülükler için verileriniz işlenir.

## 2. Haklarınız
Verilerinizin silinmesini veya bilgi talep etme hakkınız saklıdır.
''';

  static const String _defaultUserAgreementContent = '''
# Kullanıcı Sözleşmesi

## 1. Hizmet Tanımı
Halı Yıkamacı, firmalarla müşterileri buluşturan bir platformdur.

## 2. Yükümlülükler
Kullanıcılar doğru bilgi vermekle yükümlüdür.
''';



  void _showDocumentContent(LegalDocumentModel doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      doc.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Versiyon: ${doc.version} | Son güncelleme: ${doc.updatedAt.day}/${doc.updatedAt.month}/${doc.updatedAt.year}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    doc.content,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Anladım'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
