import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ==================== WARNA ====================

const kBgColor = Color(0xFFEFF6FF);
const kCardColor = Color(0xFFFFFFFF);
const kBlueDark = Color(0xFF1E3A8A);
const kBlueMid = Color(0xFF1E40AF);
const kBlueMain = Color(0xFF1D4ED8);
const kBlueSoft = Color(0xFFDBEAFE);
const kBluePale = Color(0xFFEFF6FF);

const kTextMain = Color(0xFF1E293B);
const kTextSub = Color(0xFF64748B);
const kTextLight = Color(0xFF94A3B8);

const kGreen = Color(0xFF059669);
const kGreenLight = Color(0xFFD1FAE5);
const kRed = Color(0xFFDC2626);
const kRedLight = Color(0xFFFEE2E2);
const kOrange = Color(0xFFD97706);
const kOrangeLight = Color(0xFFFEF3C7);

final List<BoxShadow> kSoftShadow = [
  BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4)),
  BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 24,
      offset: const Offset(0, 12)),
];

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
  final int id;
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

  StokItem copyWith({String? name, int? qty, String? unit, String? category}) {
    return StokItem(
      id: id,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      category: category ?? this.category,
    );
  }
}

class LogEntry {
  final String message;
  final LogType type;
  final DateTime time;
  LogEntry({required this.message, required this.type, required this.time});
  String get timeHour => DateFormat('HH:mm').format(time);
}

// ==================== DEFAULT DATA ====================

List<StokItem> buildDefaultItems() => [
      StokItem(
          id: 1, name: 'Beras', qty: 50, unit: 'kg', category: 'Bahan Pokok'),
      StokItem(
          id: 2,
          name: 'Minyak Goreng',
          qty: 20,
          unit: 'liter',
          category: 'Bahan Pokok'),
      StokItem(
          id: 3,
          name: 'Gula Pasir',
          qty: 15,
          unit: 'kg',
          category: 'Bahan Pokok'),
      StokItem(id: 4, name: 'Telur', qty: 3, unit: 'kg', category: 'Protein'),
      StokItem(
          id: 5, name: 'Daging Ayam', qty: 8, unit: 'kg', category: 'Protein'),
      StokItem(
          id: 6,
          name: 'Sabun Cuci Piring',
          qty: 2,
          unit: 'botol',
          category: 'Kebersihan'),
      StokItem(
          id: 7, name: 'Sampo', qty: 1, unit: 'botol', category: 'Perawatan'),
    ];

// ==================== AVATAR WIDGET ====================

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

// ==================== STAT CARD ====================

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color numColor;
  final Color iconColor;
  final Color iconBg;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.numColor,
    required this.iconColor,
    required this.iconBg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBlueSoft, width: 0.5),
        boxShadow: kSoftShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: numColor,
                      height: 1)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: kTextSub)),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== STOK CARD ====================

class _StokCard extends StatefulWidget {
  final StokItem item;
  final Function(StokItem, int, int) onUbah;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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

    Color statusColor;
    Color statusBg;
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
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: borderColor, width: st == StokStatus.aman ? 0.5 : 1.0),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP ROW ──────────────────────────────────────────────────────
          Row(
            children: [
              InitialsAvatar(name: item.name, size: 44, fontSize: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            color: kTextMain,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(statusText,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor)),
                        ),
                        const SizedBox(width: 6),
                        Text(item.category,
                            style:
                                const TextStyle(fontSize: 11, color: kTextSub)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item.qty}',
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1)),
                  Text(item.unit,
                      style: const TextStyle(color: kTextLight, fontSize: 11)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(height: 0.5, color: const Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          // ── CONTROL ROW ───────────────────────────────────────────────────
          Row(
            children: [
              _ctrlBtn(
                  icon: Icons.remove_rounded,
                  color: kRed,
                  bg: kRedLight,
                  onTap: () => widget.onUbah(
                      item, -1, int.tryParse(_inputCtrl.text) ?? 1)),
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
                    style: const TextStyle(
                        color: kTextMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: '1',
                      hintStyle: TextStyle(color: kTextLight),
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
                      item, 1, int.tryParse(_inputCtrl.text) ?? 1)),
              const SizedBox(width: 8),
              // ── EDIT BUTTON ──
              _ctrlBtn(
                  icon: Icons.edit_outlined,
                  color: kBlueMain,
                  bg: kBlueSoft,
                  onTap: widget.onEdit),
              const SizedBox(width: 8),
              // ── DELETE BUTTON ──
              _ctrlBtn(
                  icon: Icons.delete_outline_rounded,
                  color: kRed,
                  bg: kRedLight,
                  onTap: widget.onDelete),
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
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ==================== LOG ROW ====================

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
        logColor = kBlueMain;
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
      decoration:
          BoxDecoration(color: logBg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
                color: logIconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(logIcon, color: logColor, size: 13),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(log.message,
                style: const TextStyle(
                    color: kTextMain,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ),
          Text(log.timeHour,
              style: const TextStyle(color: kTextLight, fontSize: 10)),
        ],
      ),
    );
  }
}

// ==================== SECTION HEADER ====================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const _SectionHeader(
      {required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              color: kBlueSoft, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: kBlueMain, size: 15),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: kBlueDark)),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

// ==================== ITEM FORM DIALOG ====================
// Digunakan untuk tambah dan edit item

class _ItemFormDialog extends StatefulWidget {
  final StokItem? existingItem; // null = tambah baru
  const _ItemFormDialog({this.existingItem});

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  late String _selectedUnit;
  late final TextEditingController _catCtrl;

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
      backgroundColor: kCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: kBlueSoft,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(isEdit ? Icons.edit_outlined : Icons.add_rounded,
                      color: kBlueMain, size: 16),
                ),
                const SizedBox(width: 10),
                Text(isEdit ? 'Edit Item' : 'Tambah Item Baru',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kTextMain)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: kTextSub),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── NAMA ──
            _label('Nama Barang'),
            const SizedBox(height: 6),
            _input(
                ctrl: _nameCtrl,
                hint: 'cth. Beras Premium',
                icon: Icons.label_outline_rounded),

            const SizedBox(height: 14),

            // ── QTY & UNIT ──
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
                          isNumber: true),
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

            // ── KATEGORI ──
            _label('Kategori'),
            const SizedBox(height: 6),
            _input(
                ctrl: _catCtrl,
                hint: 'cth. Bahan Pokok',
                icon: Icons.category_outlined),

            const SizedBox(height: 20),

            // ── BUTTONS ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(
                            color: kTextSub, fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlueMain,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(isEdit ? 'Simpan' : 'Tambahkan',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(_snack('Nama barang wajib diisi', kRed));
      return;
    }
    if (qty <= 0 && !isEdit) {
      ScaffoldMessenger.of(context)
          .showSnackBar(_snack('Jumlah harus lebih dari 0', kRed));
      return;
    }

    Navigator.pop(context, {
      'name': name,
      'qty': qty,
      'unit': _selectedUnit,
      'category': cat,
    });
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500, color: kTextSub));

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
        style: const TextStyle(
            color: kTextMain, fontSize: 13, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kTextLight, fontSize: 12),
          prefixIcon: Icon(icon, color: kTextSub, size: 17),
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
        dropdownColor: kCardColor,
        icon: const Icon(Icons.expand_more, color: kTextSub, size: 18),
        style: const TextStyle(
            color: kTextMain, fontSize: 13, fontWeight: FontWeight.w500),
        underline: const SizedBox(),
        items: _units
            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
            .toList(),
        onChanged: (v) => setState(() => _selectedUnit = v!),
      ),
    );
  }
}

// ==================== DELETE CONFIRM DIALOG ====================

class _DeleteConfirmDialog extends StatelessWidget {
  final StokItem item;
  const _DeleteConfirmDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kCardColor,
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
                  color: kRedLight, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.delete_outline_rounded,
                  color: kRed, size: 28),
            ),
            const SizedBox(height: 14),
            const Text('Hapus Item?',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTextMain)),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style:
                    const TextStyle(fontSize: 13, color: kTextSub, height: 1.5),
                children: [
                  const TextSpan(text: 'Item '),
                  TextSpan(
                      text: item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: kTextMain)),
                  const TextSpan(
                      text:
                          ' akan dihapus permanen.\nTindakan ini tidak bisa dibatalkan.'),
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
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(
                            color: kTextSub, fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Hapus',
                        style: TextStyle(fontWeight: FontWeight.w600)),
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
  late List<StokItem> _items;
  final List<LogEntry> _logs = [];
  int _nextId = 8;

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _items = buildDefaultItems();
    _nextId = _items.length + 1;
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── FILTERED LIST ──────────────────────────────────────────────────────────

  List<StokItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    return _items
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery) ||
            item.category.toLowerCase().contains(_searchQuery) ||
            item.unit.toLowerCase().contains(_searchQuery))
        .toList();
  }

  // ── STATS ──────────────────────────────────────────────────────────────────

  int get _totalItem => _items.length;
  int get _stokAman => _items.where((i) => i.status == StokStatus.aman).length;
  int get _hampirHabis =>
      _items.where((i) => i.status == StokStatus.hampirHabis).length;
  int get _stokHabis =>
      _items.where((i) => i.status == StokStatus.habis).length;

  // ── QTY CHANGE ─────────────────────────────────────────────────────────────

  void _ubahQty(StokItem item, int delta, int jumlah) {
    setState(() {
      final old = item.qty;
      item.qty = (item.qty + delta * jumlah).clamp(0, 99999);
      final diff = (item.qty - old).abs();
      if (delta > 0) {
        _addLog('${item.name}: +$diff ${item.unit} (sisa ${item.qty})',
            LogType.tambah);
        _showToast('Stok ${item.name} bertambah +$diff', kGreen);
      } else {
        _addLog('${item.name}: -$diff ${item.unit} (sisa ${item.qty})',
            LogType.kurang);
        _showToast('Stok ${item.name} berkurang -$diff', kOrange);
      }
    });
  }

  // ── ADD ITEM ────────────────────────────────────────────────────────────────

  Future<void> _tambahItem() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _ItemFormDialog(),
    );
    if (result == null) return;

    setState(() {
      _items.add(StokItem(
        id: _nextId++,
        name: result['name'],
        qty: result['qty'],
        unit: result['unit'],
        category: result['category'],
      ));
      _addLog(
          'Item baru: ${result['name']} (${result['qty']} ${result['unit']})',
          LogType.baru);
    });
    _showToast('${result['name']} berhasil ditambahkan', kGreen);
  }

  // ── EDIT ITEM ───────────────────────────────────────────────────────────────

  Future<void> _editItem(StokItem item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _ItemFormDialog(existingItem: item),
    );
    if (result == null) return;

    setState(() {
      item.name = result['name'];
      item.qty = result['qty'];
      item.unit = result['unit'];
      item.category = result['category'];
      _addLog('${item.name} diperbarui', LogType.edit);
    });
    _showToast('${item.name} berhasil diperbarui', kOrange);
  }

  // ── DELETE ITEM ─────────────────────────────────────────────────────────────

  Future<void> _deleteItem(StokItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(item: item),
    );
    if (confirm != true) return;

    setState(() {
      _items.removeWhere((i) => i.id == item.id);
      _addLog('${item.name} dihapus dari inventaris', LogType.hapus);
    });
    _showToast('${item.name} dihapus', kRed);
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────────

  void _addLog(String msg, LogType type) {
    _logs.insert(0, LogEntry(message: msg, type: type, time: DateTime.now()));
    if (_logs.length > 10) _logs.removeLast();
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      duration: const Duration(seconds: 2),
    ));
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final displayed = _filteredItems;

    return Scaffold(
      backgroundColor: kBgColor,

      // ── APP BAR ──────────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          color: kBlueDark,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const SizedBox(width: 34),
                      const Expanded(
                        child: Text('Manajemen Stok',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${_items.length} item',
                            style: const TextStyle(
                                color: Color(0xFFBAE6FD),
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Ringkasan Inventaris',
                            style: TextStyle(
                                color: Color(0xFF93C5FD), fontSize: 11)),
                        SizedBox(height: 2),
                        Text('Stok Manager',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahItem,
        backgroundColor: kBlueMain,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Item',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── STAT CARDS ──────────────────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.4,
              children: [
                StatCard(
                    label: 'Total Item',
                    value: '$_totalItem',
                    numColor: kBlueMain,
                    iconColor: kBlueMain,
                    iconBg: kBlueSoft,
                    icon: Icons.inventory_2_rounded),
                StatCard(
                    label: 'Stok Aman',
                    value: '$_stokAman',
                    numColor: kGreen,
                    iconColor: kGreen,
                    iconBg: kGreenLight,
                    icon: Icons.check_circle_rounded),
                StatCard(
                    label: 'Menipis',
                    value: '$_hampirHabis',
                    numColor: kOrange,
                    iconColor: kOrange,
                    iconBg: kOrangeLight,
                    icon: Icons.warning_rounded),
                StatCard(
                    label: 'Stok Habis',
                    value: '$_stokHabis',
                    numColor: kRed,
                    iconColor: kRed,
                    iconBg: kRedLight,
                    icon: Icons.cancel_rounded),
              ],
            ),

            const SizedBox(height: 20),

            // ── SEARCH BAR ──────────────────────────────────────────────────
            _SectionHeader(icon: Icons.search_rounded, title: 'Cari Barang'),
            const SizedBox(height: 10),

            Container(
              height: 46,
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBlueSoft, width: 0.5),
                boxShadow: kSoftShadow,
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: kTextMain, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Cari nama, kategori, satuan...',
                  hintStyle: const TextStyle(color: kTextLight, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: kTextSub, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () => _searchCtrl.clear(),
                          child: const Icon(Icons.close_rounded,
                              color: kTextSub, size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── DAFTAR INVENTARIS ────────────────────────────────────────────
            _SectionHeader(
              icon: Icons.view_list_rounded,
              title: _searchQuery.isEmpty
                  ? 'Daftar Inventaris'
                  : 'Hasil Pencarian',
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: kBlueSoft,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color(0xFFBFDBFE), width: 0.5),
                ),
                child: Text(
                  '${displayed.length} item${_searchQuery.isNotEmpty ? ' ditemukan' : ''}',
                  style: const TextStyle(
                      color: kBlueMain,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),

            displayed.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBlueSoft, width: 0.5),
                    ),
                    child: Center(
                      child: Column(children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off_rounded
                              : Icons.inventory_2_outlined,
                          size: 52,
                          color: kTextLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ditemukan: "$_searchQuery"'
                              : 'Belum ada data',
                          style: const TextStyle(color: kTextSub, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Coba kata kunci lain'
                              : 'Tap tombol + untuk menambah item',
                          style:
                              const TextStyle(color: kTextLight, fontSize: 11),
                        ),
                      ]),
                    ),
                  )
                : Column(
                    children: displayed
                        .map((item) => _StokCard(
                              item: item,
                              onUbah: _ubahQty,
                              onEdit: () => _editItem(item),
                              onDelete: () => _deleteItem(item),
                            ))
                        .toList(),
                  ),

            // ── BOTTOM PADDING UNTUK FAB ──────────────────────────────────
            const SizedBox(height: 20),

            // ── AKTIVITAS TERKINI ────────────────────────────────────────────
            _SectionHeader(
                icon: Icons.history_rounded, title: 'Aktivitas Terkini'),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBlueSoft, width: 0.5),
                boxShadow: kSoftShadow,
              ),
              child: _logs.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Belum ada aktivitas',
                            style: TextStyle(color: kTextLight, fontSize: 12)),
                      ),
                    )
                  : Column(
                      children:
                          _logs.take(5).map((l) => _LogRow(log: l)).toList(),
                    ),
            ),

            const SizedBox(height: 80), // space untuk FAB
          ],
        ),
      ),
    );
  }
}

// ==================== SNACK HELPER ====================

SnackBar _snack(String msg, Color color) => SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      duration: const Duration(seconds: 2),
    );
