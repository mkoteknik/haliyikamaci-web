import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'print_options_model.dart';

class LabelCountDialog extends StatefulWidget {
  const LabelCountDialog({super.key});

  @override
  State<LabelCountDialog> createState() => _LabelCountDialogState();
}

class _LabelCountDialogState extends State<LabelCountDialog> {
  int _count = 1;
  
  // Default to 80mm (Standard Receipt)
  PdfPageFormat _selectedFormat = PdfPageFormat.roll80;
  String _selectedFormatName = "80mm Fiş (Standart)";

  final Map<String, PdfPageFormat> _formats = {
    "80mm Fiş (Standart)": PdfPageFormat.roll80,
    "58mm Fiş (Mobil)": PdfPageFormat.roll57,
    "Etiket (100x50mm)": const PdfPageFormat(100 * PdfPageFormat.mm, 50 * PdfPageFormat.mm),
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Etiket Yazdır'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Kaç parça ürün teslim alındı?'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () { if(_count > 1) setState(() => _count--); },
                icon: const Icon(Icons.remove_circle, size: 32, color: Colors.red),
              ),
              Text('$_count', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () { if(_count < 20) setState(() => _count++); },
                icon: const Icon(Icons.add_circle, size: 32, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _selectedFormatName,
            decoration: const InputDecoration(
              labelText: 'Kağıt / Yazıcı Tipi',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _formats.keys.map((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(key, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedFormatName = newValue;
                  _selectedFormat = _formats[newValue]!;
                });
              }
            },
          ),
          const SizedBox(height: 10),
          Text(
            '$_count adet Halı Etiketi\n+1 adet Müşteri Fişi basılacak.', 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context, 
              PrintOptions(count: _count, format: _selectedFormat, formatName: _selectedFormatName)
            );
          }, 
          child: const Text('Yazdır'),
        ),
      ],
    );
  }
}
