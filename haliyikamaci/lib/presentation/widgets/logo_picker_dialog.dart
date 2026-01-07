import 'package:flutter/material.dart';

/// Logo Picker Dialog - Allows selection from predefined icons
class LogoPickerDialog extends StatelessWidget {
  /// Type of icons: 'firma' or 'musteri'
  final String iconType;
  
  /// Number of icons available (1.jpg to N.jpg)
  final int iconCount;

  const LogoPickerDialog({
    super.key,
    required this.iconType,
    this.iconCount = 18,
  });

  /// Show dialog and return selected logo path
  static Future<String?> show(BuildContext context, {required String iconType}) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => LogoPickerDialog(iconType: iconType),
    );
  }

  @override
  Widget build(BuildContext context) {
    final folderName = iconType == 'firma' ? 'firma_icon' : 'musteri_icon';
    final title = iconType == 'firma' ? 'Firma Logosu Seç' : 'Profil Resmi Seç';

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          
          // Title
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Aşağıdaki ikonlardan birini seçin',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Grid of icons
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: iconCount,
              itemBuilder: (context, index) {
                final iconPath = 'assets/$folderName/${index + 1}.jpg';
                return _buildIconItem(context, iconPath);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconItem(BuildContext context, String iconPath) {
    return InkWell(
      onTap: () => Navigator.pop(context, iconPath),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          iconPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(Icons.broken_image, color: Colors.grey[400]),
            );
          },
        ),
      ),
    );
  }
}
