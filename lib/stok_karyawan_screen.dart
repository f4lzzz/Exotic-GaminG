import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ==================== WARNA ====================
const kBlue = Color(0xFF1A5EBF);
const kBlueDark = Color(0xFF0F3B8C);
const kBlueBg = Color(0xFF4A90D9);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kTextDark = Color(0xFF1A237E);
const kGreen = Color(0xFF4CAF50);
const kRed = Color(0xFFE53935);
const kOrange = Color(0xFFFF9800);
const kBgLight = Color(0xFFF0F4FF);
const kBlueSoft = Color(0xFFDBEAFE);
const kBluePale = Color(0xFFEFF6FF);
const kGreenLight = Color(0xFFD1FAE5);
const kRedLight = Color(0xFFFEE2E2);
const kOrangeLight = Color(0xFFFEF3C7);

// ==================== AVATAR COLORS ====================
const List<Map<String, Color>> kAvatarColors = [
  {'bg': Color(0xFFDBEAFE), 'text': Color(0xFF1E40AF)},
  {'bg': Color(0xFFD1FAE5), 'text': Color(0xFF065F46)},
  {'bg': Color(0xFFFCE7F3), 'text': Color(0xFF9D174D)},
  {'bg': Color(0xFFFEF3C7), 'text': Color(0xFF92400E)},
  {'bg': Color(0xFFEDE9FE), 'text': Color(0xFF5B21B6)},
  {'bg': Color(0xFFCFFAFE), 'text': Color(0xFF164E63)},
  {'bg': Color(0xFFFCE7E7), 'text': Color(0xFF991B1B)},
  {'bg': Color(0xFFF0FDF4), 'text': Color(0xFF14532D)},
];

Map<String, Color> avatarColorFor(String name) {
  int sum = 0;
  for (final c in name.runes) sum += c;
  return kAvatarColors[sum % kAvatarColors.length];
}

String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.length >= 2) {
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
  return name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
}

// ==================== MODELS ====================
enum StokStatus { aman, hampirHabis, habis }

enum LogType { tambah, kurang, hapus, baru, edit }

class StokItem {
  final String id;
  String name;
  int qty;
  String unit;
  String category;
  StokItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.unit,
    required this.category,
  });
  StokStatus get status {
    if (qty <= 0) return StokStatus.habis;
    if (qty <= 5) return StokStatus.hampirHabis;
    return StokStatus.aman;
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'qty': qty,
        'unit': unit,
        'category': category,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class LogEntry {
  final String message;
  final LogType type;
  final DateTime time;
  LogEntry({required this.message, required this.type, required this.time});
  String get timeHour => DateFormat('HH:mm').format(time);
}

class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double fontSize;
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.fontSize = 14,
  });
  @override
  Widget build(BuildContext context) {
    final colors = avatarColorFor(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initialsOf(name),
        style: TextStyle(
          color: colors['text'],
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label, value;
  final Color numColor;
  final IconData icon;
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.numColor,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kBlueSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: numColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: numColor,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.lato(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StokCard extends StatefulWidget {
  final StokItem item;
  final Function(StokItem, int, int) onUbah;
  final VoidCallback onEdit, onDelete;
  const _StokCard({
    required this.item,
    required this.onUbah,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  State<_StokCard> createState() => _StokCardState();
}

class _StokCardState extends State<_StokCard> {
  final _inputCtrl = TextEditingController(text: '1');
  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final st = item.status;
    Color statusColor, statusBg;
    String statusText;
    if (st == StokStatus.aman) {
      statusColor = kGreen;
      statusBg = kGreenLight;
      statusText = 'Aman';
    } else if (st == StokStatus.hampirHabis) {
      statusColor = kOrange;
      statusBg = kOrangeLight;
      statusText = 'Menipis';
    } else {
      statusColor = kRed;
      statusBg = kRedLight;
      statusText = 'Habis';
    }
    Color borderColor = st == StokStatus.aman
        ? kBlueSoft
        : st == StokStatus.hampirHabis
            ? const Color(0xFFFCD34D)
            : const Color(0xFFFCA5A5);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: st == StokStatus.aman ? 0.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(name: item.name, size: 44, fontSize: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.category,
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.qty}',
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      height: 1,
                    ),
                  ),
                  Text(
                    item.unit,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 0.5, color: const Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          Row(
            children: [
              _ctrlBtn(
                icon: Icons.remove_rounded,
                color: kRed,
                bg: kRedLight,
                onTap: () => widget.onUbah(
                  item,
                  -1,
                  int.tryParse(_inputCtrl.text) ?? 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kBluePale,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBlueSoft, width: 0.5),
                  ),
                  child: TextField(
                    controller: _inputCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: '1',
                      hintStyle: TextStyle(color: Colors.black26),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ctrlBtn(
                icon: Icons.add_rounded,
                color: kGreen,
                bg: kGreenLight,
                onTap: () => widget.onUbah(
                  item,
                  1,
                  int.tryParse(_inputCtrl.text) ?? 1,
                ),
              ),
              const SizedBox(width: 8),
              _ctrlBtn(
                icon: Icons.edit_outlined,
                color: kBlue,
                bg: kBlueSoft,
                onTap: widget.onEdit,
              ),
              const SizedBox(width: 8),
              _ctrlBtn(
                icon: Icons.delete_outline_rounded,
                color: kRed,
                bg: kRedLight,
                onTap: widget.onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ctrlBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final LogEntry log;
  const _LogRow({required this.log});
  @override
  Widget build(BuildContext context) {
    late Color logColor, logBg, logIconBg;
    late IconData logIcon;
    switch (log.type) {
      case LogType.tambah:
        logColor = kGreen;
        logBg = const Color(0xFFF0FDF4);
        logIconBg = kGreenLight;
        logIcon = Icons.add_rounded;
        break;
      case LogType.kurang:
        logColor = kOrange;
        logBg = const Color(0xFFFFFBEB);
        logIconBg = kOrangeLight;
        logIcon = Icons.remove_rounded;
        break;
      case LogType.hapus:
        logColor = kRed;
        logBg = kRedLight;
        logIconBg = kRedLight;
        logIcon = Icons.delete_outline;
        break;
      case LogType.baru:
        logColor = kBlue;
        logBg = kBluePale;
        logIconBg = kBlueSoft;
        logIcon = Icons.add_box_outlined;
        break;
      case LogType.edit:
        logColor = kOrange;
        logBg = kOrangeLight;
        logIconBg = kOrangeLight;
        logIcon = Icons.edit_outlined;
        break;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: logBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: logIconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(logIcon, color: logColor, size: 13),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              log.message,
              style: GoogleFonts.lato(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: kTextDark,
              ),
            ),
          ),
          Text(
            log.timeHour,
            style: GoogleFonts.lato(fontSize: 10, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: kBlueSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kBlue, size: 15),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: kBlueDark,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

// ==================== DIALOGS ====================
class _ItemFormDialog extends StatefulWidget {
  final StokItem? existingItem;
  const _ItemFormDialog({this.existingItem});
  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  late final TextEditingController _nameCtrl, _qtyCtrl, _catCtrl;
  late String _selectedUnit;
  final _units = [
    'kg',
    'liter',
    'botol',
    'pcs',
    'sachet',
    'box',
    'pak',
    'lusin'
  ];
  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _qtyCtrl = TextEditingController(text: item != null ? '${item.qty}' : '');
    _selectedUnit = item?.unit ?? 'kg';
    _catCtrl = TextEditingController(text: item?.category ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  bool get isEdit => widget.existingItem != null;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: kBlueSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isEdit ? Icons.edit_outlined : Icons.add_rounded,
                    color: kBlue,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isEdit ? 'Edit Item' : 'Tambah Item Baru',
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: Colors.black45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _label('Nama Barang'),
            const SizedBox(height: 6),
            _input(
              ctrl: _nameCtrl,
              hint: 'cth. Beras Premium',
              icon: Icons.label_outline_rounded,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Jumlah'),
                      const SizedBox(height: 6),
                      _input(
                        ctrl: _qtyCtrl,
                        hint: '0',
                        icon: Icons.pin_outlined,
                        isNumber: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Satuan'),
                    const SizedBox(height: 6),
                    _unitPicker(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            _label('Kategori'),
            const SizedBox(height: 6),
            _input(
              ctrl: _catCtrl,
              hint: 'cth. Bahan Pokok',
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: kWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isEdit ? 'Simpan' : 'Tambahkan',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    final name = _nameCtrl.text.trim();
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    final cat = _catCtrl.text.trim().isEmpty ? 'Umum' : _catCtrl.text.trim();
    if (name.isEmpty) {
      _showToast('Nama barang wajib diisi', kRed);
      return;
    }
    if (qty <= 0 && !isEdit) {
      _showToast('Jumlah harus lebih dari 0', kRed);
      return;
    }
    Navigator.pop(context, {
      'name': name,
      'qty': qty,
      'unit': _selectedUnit,
      'category': cat,
    });
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      );
  Widget _input({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: kBluePale,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 0.5),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
            isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        style: GoogleFonts.lato(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: kTextDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(fontSize: 12, color: Colors.black26),
          prefixIcon: Icon(icon, color: Colors.black45, size: 17),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }

  Widget _unitPicker() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: kBluePale,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 0.5),
      ),
      child: DropdownButton<String>(
        value: _selectedUnit,
        dropdownColor: kWhite,
        icon: const Icon(Icons.expand_more, color: Colors.black45, size: 18),
        style: GoogleFonts.lato(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: kTextDark,
        ),
        underline: const SizedBox(),
        items: _units
            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
            .toList(),
        onChanged: (v) => setState(() => _selectedUnit = v!),
      ),
    );
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatelessWidget {
  final StokItem item;
  const _DeleteConfirmDialog({required this.item});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: kRedLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: kRed,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Hapus Item?',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Item '),
                  TextSpan(
                    text: item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' akan dihapus permanen.\nTindakan ini tidak bisa dibatalkan.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRed,
                      foregroundColor: kWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MAIN SCREEN ====================
class StokKaryawanScreen extends StatefulWidget {
  const StokKaryawanScreen({super.key});
  @override
  State<StokKaryawanScreen> createState() => _StokKaryawanScreenState();
}

class _StokKaryawanScreenState extends State<StokKaryawanScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0;
  static const double _headerExpanded = 120.0;
  static const double _headerCollapsed = 60.0;
  static const double _collapseAt = 70.0;
  double get _collapseProgress => (_scrollOffset / _collapseAt).clamp(0.0, 1.0);
  double get _headerHeight =>
      _headerExpanded -
      (_headerExpanded - _headerCollapsed) * _collapseProgress;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  Stream<List<LogEntry>> get _logsStream {
    return _firestore
        .collection('stok_logs')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return LogEntry(
                message: data['message'] ?? '',
                type: _stringToLogType(data['type'] ?? 'tambah'),
                time: (data['timestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              );
            }).toList());
  }

  LogType _stringToLogType(String str) {
    switch (str) {
      case 'tambah':
        return LogType.tambah;
      case 'kurang':
        return LogType.kurang;
      case 'hapus':
        return LogType.hapus;
      case 'baru':
        return LogType.baru;
      case 'edit':
        return LogType.edit;
      default:
        return LogType.tambah;
    }
  }

  String _logTypeToString(LogType type) {
    switch (type) {
      case LogType.tambah:
        return 'tambah';
      case LogType.kurang:
        return 'kurang';
      case LogType.hapus:
        return 'hapus';
      case LogType.baru:
        return 'baru';
      case LogType.edit:
        return 'edit';
    }
  }

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _searchCtrl.addListener(() =>
        setState(() => _searchQuery = _searchCtrl.text.toLowerCase().trim()));
    _scrollCtrl
        .addListener(() => setState(() => _scrollOffset = _scrollCtrl.offset));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _ubahQty(StokItem item, int delta, int jumlah) async {
    final newQty = (item.qty + delta * jumlah).clamp(0, 99999);
    if (newQty == item.qty) return;
    try {
      await _firestore.collection('stok').doc(item.id).update({'qty': newQty});
      final diff = (newQty - item.qty).abs();
      final type = delta > 0 ? LogType.tambah : LogType.kurang;
      await _addLog(
        message:
            '${item.name}: ${delta > 0 ? '+' : '-'}$diff ${item.unit} (sisa $newQty)',
        type: type,
        itemId: item.id,
      );
      _showToast(
          'Stok ${item.name} ${delta > 0 ? 'bertambah' : 'berkurang'} $diff',
          delta > 0 ? kGreen : kOrange);
    } catch (e) {
      _showToast('Gagal mengubah stok: $e', kRed);
    }
  }

  Future<void> _tambahItem() async {
    final result = await showDialog<Map<String, dynamic>>(
        context: context, builder: (_) => const _ItemFormDialog());
    if (result == null) return;
    try {
      final docRef = await _firestore.collection('stok').add({
        'name': result['name'],
        'qty': result['qty'],
        'unit': result['unit'],
        'category': result['category'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _addLog(
        message:
            'Item baru: ${result['name']} (${result['qty']} ${result['unit']})',
        type: LogType.baru,
        itemId: docRef.id,
      );
      _showToast('${result['name']} berhasil ditambahkan', kGreen);
    } catch (e) {
      _showToast('Gagal menambah item: $e', kRed);
    }
  }

  Future<void> _editItem(StokItem item) async {
    final result = await showDialog<Map<String, dynamic>>(
        context: context, builder: (_) => _ItemFormDialog(existingItem: item));
    if (result == null) return;
    try {
      await _firestore.collection('stok').doc(item.id).update({
        'name': result['name'],
        'qty': result['qty'],
        'unit': result['unit'],
        'category': result['category'],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _addLog(
        message: '${result['name']} diperbarui',
        type: LogType.edit,
        itemId: item.id,
      );
      _showToast('${result['name']} berhasil diperbarui', kOrange);
    } catch (e) {
      _showToast('Gagal mengedit item: $e', kRed);
    }
  }

  Future<void> _deleteItem(StokItem item) async {
    final confirm = await showDialog<bool>(
        context: context, builder: (_) => _DeleteConfirmDialog(item: item));
    if (confirm != true) return;
    try {
      await _firestore.collection('stok').doc(item.id).delete();
      await _addLog(
        message: '${item.name} dihapus dari inventaris',
        type: LogType.hapus,
        itemId: item.id,
      );
      _showToast('${item.name} dihapus', kRed);
    } catch (e) {
      _showToast('Gagal menghapus item: $e', kRed);
    }
  }

  Future<void> _addLog({
    required String message,
    required LogType type,
    String? itemId,
  }) async {
    await _firestore.collection('stok_logs').add({
      'message': message,
      'type': _logTypeToString(type),
      'timestamp': FieldValue.serverTimestamp(),
      'itemId': itemId,
      'userId': _currentUser?.uid,
      'userName': _currentUser?.displayName ?? _currentUser?.email,
    });
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('stok').snapshots(),
                    builder: (context, snapshot) {
                      int totalItem = 0;
                      int stokAman = 0;
                      int hampirHabis = 0;
                      int stokHabis = 0;
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          final qty = (doc.data()
                                  as Map<String, dynamic>)['qty'] as int? ??
                              0;
                          totalItem++;
                          if (qty <= 0)
                            stokHabis++;
                          else if (qty <= 5)
                            hampirHabis++;
                          else
                            stokAman++;
                        }
                      }
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.2,
                        children: [
                          StatCard(
                            label: 'Total Item',
                            value: '$totalItem',
                            numColor: kBlue,
                            icon: Icons.inventory_2_rounded,
                          ),
                          StatCard(
                            label: 'Stok Aman',
                            value: '$stokAman',
                            numColor: kGreen,
                            icon: Icons.check_circle_rounded,
                          ),
                          StatCard(
                            label: 'Menipis',
                            value: '$hampirHabis',
                            numColor: kOrange,
                            icon: Icons.warning_rounded,
                          ),
                          StatCard(
                            label: 'Stok Habis',
                            value: '$stokHabis',
                            numColor: kRed,
                            icon: Icons.cancel_rounded,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _SectionHeader(
                      icon: Icons.search_rounded, title: 'Cari Barang'),
                  const SizedBox(height: 10),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBlueSoft, width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
                      decoration: InputDecoration(
                        hintText: 'Cari nama, kategori, satuan...',
                        hintStyle: GoogleFonts.lato(
                            fontSize: 13, color: Colors.black45),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Colors.black45, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () => _searchCtrl.clear(),
                                child: const Icon(Icons.close_rounded,
                                    color: Colors.black45, size: 18))
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('stok').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: kRed)));
                      }
                      final docs = snapshot.data!.docs;
                      List<StokItem> items = docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return StokItem(
                          id: doc.id,
                          name: data['name'] ?? '',
                          qty: data['qty'] as int? ?? 0,
                          unit: data['unit'] ?? 'pcs',
                          category: data['category'] ?? 'Umum',
                        );
                      }).toList();

                      if (_searchQuery.isNotEmpty) {
                        items = items
                            .where((item) =>
                                item.name
                                    .toLowerCase()
                                    .contains(_searchQuery) ||
                                item.category
                                    .toLowerCase()
                                    .contains(_searchQuery) ||
                                item.unit.toLowerCase().contains(_searchQuery))
                            .toList();
                      }

                      if (items.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kBlueSoft, width: 0.5),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  _searchQuery.isNotEmpty
                                      ? Icons.search_off_rounded
                                      : Icons.inventory_2_outlined,
                                  size: 52,
                                  color: Colors.black38,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ditemukan: "$_searchQuery"'
                                      : 'Belum ada data',
                                  style: GoogleFonts.lato(
                                      fontSize: 13, color: Colors.black54),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Coba kata kunci lain'
                                      : 'Tap tombol + untuk menambah item',
                                  style: GoogleFonts.lato(
                                      fontSize: 11, color: Colors.black38),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${items.length} item${_searchQuery.isNotEmpty ? ' ditemukan' : ''}',
                              style: GoogleFonts.lato(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: kBlue),
                            ),
                          ),
                          ...items.map((item) => _StokCard(
                                item: item,
                                onUbah: _ubahQty,
                                onEdit: () => _editItem(item),
                                onDelete: () => _deleteItem(item),
                              )),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                      icon: Icons.history_rounded, title: 'Aktivitas Terkini'),
                  const SizedBox(height: 10),
                  StreamBuilder<List<LogEntry>>(
                    stream: _logsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      final logs = snapshot.data ?? [];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBlueSoft, width: 0.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: logs.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('Belum ada aktivitas',
                                      style: TextStyle(
                                          color: Colors.black38, fontSize: 12)),
                                ),
                              )
                            : Column(
                                children: logs
                                    .take(5)
                                    .map((l) => _LogRow(log: l))
                                    .toList(),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahItem,
        backgroundColor: kBlue,
        foregroundColor: kWhite,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: Text('Tambah Item',
            style: GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildHeader() {
    final p = _collapseProgress;
    final double eSize = 24 - (24 - 14) * p;
    final double xSize = 40 - (40 - 22) * p;
    final double oticSize = 24 - (24 - 14) * p;
    final double subSize = 11 - (11 - 9) * p;
    final double padTop = 36 - (36 - 16) * p;
    final double padBot = 16 - (16 - 10) * p;
    final double subOpacity = (1 - p * 2).clamp(0.0, 1.0);

    final logoWidget = RichText(
      text: TextSpan(
        style: GoogleFonts.playfairDisplay(color: kWhite, height: 1.0),
        children: [
          TextSpan(
              text: 'E',
              style: TextStyle(fontSize: eSize, fontWeight: FontWeight.w400)),
          TextSpan(
              text: 'X',
              style: TextStyle(fontSize: xSize, fontWeight: FontWeight.w700)),
          TextSpan(
              text: 'OTIC',
              style:
                  TextStyle(fontSize: oticSize, fontWeight: FontWeight.w400)),
        ],
      ),
    );

    final subWidget = Text('GAMING & CAFE',
        style: GoogleFonts.playfairDisplay(
            fontSize: subSize,
            color: kWhiteDim,
            letterSpacing: 3,
            fontWeight: FontWeight.w400));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF4A90D9), kBlue]),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      padding: EdgeInsets.fromLTRB(20, padTop, 20, padBot),
      child: p < 0.5
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(
                children: [
                  logoWidget,
                  const SizedBox(width: 6),
                  Opacity(opacity: subOpacity, child: subWidget),
                  const Spacer(),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: kWhite.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('STOK',
                          style: GoogleFonts.lato(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: kWhite))),
                ],
              ),
            ])
          : Row(
              children: [
                logoWidget,
                const SizedBox(width: 8),
                subWidget,
                const Spacer(),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: kWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('STOK',
                        style: GoogleFonts.lato(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: kWhite))),
              ],
            ),
    );
  }
}
