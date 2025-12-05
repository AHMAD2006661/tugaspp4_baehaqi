import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFBE29EC);
const kAccentColor = Color(0xFFFF9ECF);

/// keseluruhan riwayat transaksi (dipakai semua fitur)
class AppHistory {
  static final List<Map<String, dynamic>> items = [
    {
      'title': 'Kirim ke Budi',
      'subtitle': 'Hari ini · 10.21',
      'amount': -80000,
    },
    {'title': 'Top Up Dompet', 'subtitle': 'Kemarin · 19.00', 'amount': 500000},
    {'title': 'Pulsa Telpon', 'subtitle': 'Kemarin · 08.35', 'amount': -30000},
    {'title': 'Bayar Internet', 'subtitle': '2 hari lalu', 'amount': -280000},
  ];

  static void add(String title, String subtitle, int amount) {
    items.insert(0, {
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'time': DateTime.now(),
    });
  }
}

class GenericMenuPage extends StatelessWidget {
  final String title;

  /// dipakai untuk mengirim preset ke halaman Kirim Uang dari Daftar Penerima
  final Map<String, String>? preset;

  const GenericMenuPage({super.key, required this.title, this.preset});

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (title) {
      case 'Kirim Uang':
        body = _SendMoneyView(preset: preset);
        break;
      case 'Minta':
        body = const _RequestMoneyView();
        break;
      case 'Akun & Kartu':
        body = const _AccountCardsView();
        break;
      case 'Tarik Tunai':
        body = const _CashOutView();
        break;
      case 'Pulsa Seluler':
        body = const _MobileTopupView();
        break;
      case 'Bayar Tagihan':
        body = const _BillPaymentView();
        break;
      case 'Tabungan':
        body = const _SavingsView();
        break;
      case 'Kartu Kredit':
        body = const _CreditCardView();
        break;
      case 'Riwayat Transaksi':
      case 'Transaksi':
        body = const _HistoryView();
        break;
      case 'Daftar Penerima':
        body = const _BeneficiariesView();
        break;
      default:
        body = _PlaceholderView(title: title);
    }

    return Scaffold(appBar: _gradientAppBar(title), body: body);
  }
}

PreferredSizeWidget _gradientAppBar(String title) {
  return AppBar(
    elevation: 0,
    centerTitle: false, // judul kiri
    titleSpacing: 8, // ada jarak dari panah
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(color: Colors.white),
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    ),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, Color(0xFFDE4BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
  );
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
);

ButtonStyle _primaryButton() => ElevatedButton.styleFrom(
  backgroundColor: kPrimaryColor,
  foregroundColor: Colors.white,
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
);

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }
}

/// =============================================================
/// ====================== KIRIM UANG ===========================
/// =============================================================

class _SendMoneyView extends StatefulWidget {
  /// preset dari Daftar Penerima (misal nomor)
  final Map<String, String>? preset;

  const _SendMoneyView({this.preset});

  @override
  State<_SendMoneyView> createState() => _SendMoneyViewState();
}

class _SendMoneyViewState extends State<_SendMoneyView> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();

  String _mode =
      'Kontak Tersimpan'; // Kontak Tersimpan / Nomor Baru / Rekening Bank
  String _bank = 'BCA';
  String _sourceAccount = 'Dompet Utama';
  bool _saveAsFavorite = false;
  int _step = 0; // 0 isi data, 1 konfirmasi
  bool _isSending = false;

  final List<Map<String, String>> _savedContacts = const [
    {'name': 'Budi Santoso', 'detail': 'Budi Santoso · 0812 1234 5678'},
    {'name': 'Ana Rahma', 'detail': 'Ana Rahma · 0857 2345 8899'},
  ];

  String _selectedSavedName = 'Budi Santoso';

  bool get _canNext {
    if (_amountCtrl.text.trim().isEmpty) return false;

    if (_mode == 'Nomor Baru') {
      return _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '').length >= 10;
    }
    if (_mode == 'Rekening Bank') {
      return _accountCtrl.text.trim().length >= 6;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    // preset dari Daftar Penerima → auto isi nomor & mode Nomor Baru
    if (widget.preset != null) {
      final acc = widget.preset!['account'] ?? '';
      if (acc.isNotEmpty) {
        _mode = 'Nomor Baru';
        _phoneCtrl.text = acc;
      }
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _phoneCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  Map<String, String> _selectedSavedContactDetail() {
    return _savedContacts.firstWhere(
      (c) => c['name'] == _selectedSavedName,
      orElse: () => _savedContacts.first,
    );
  }

  Future<void> _doSend() async {
    setState(() => _isSending = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isSending = false);

    final nominal = _amountCtrl.text.trim();
    final intNominal =
        int.tryParse(nominal.replaceAll('.', '').replaceAll(',', '')) ?? 0;

    final tujuan = () {
      if (_mode == 'Nomor Baru') return _phoneCtrl.text.trim();
      if (_mode == 'Rekening Bank') {
        return '$_bank · ${_accountCtrl.text.trim()}';
      }
      final c = _selectedSavedContactDetail();
      return c['detail']!;
    }();
    final catatan = _noteCtrl.text.trim().isEmpty ? '-' : _noteCtrl.text.trim();

    // Tambah ke riwayat global
    AppHistory.add('Kirim Uang', 'Hari ini', -intNominal);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8F5E9),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 40,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Transfer Berhasil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Rp $nominal',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _confirmRow('Dari', _sourceAccount),
                  const SizedBox(height: 6),
                  _confirmRow('Ke', tujuan),
                  const SizedBox(height: 6),
                  _confirmRow('Catatan', catatan),
                  const SizedBox(height: 6),
                  _confirmRow('Biaya admin', 'Rp 0'),
                  const Divider(height: 20),
                  _confirmRow('Waktu', 'Hari ini'),
                  _confirmRow('ID Transaksi', '#TRX123456'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: _primaryButton(),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const GenericMenuPage(title: 'Riwayat Transaksi'),
                  ),
                );
              },
              child: const Text('Lihat riwayat transaksi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // STEP KONFIRMASI
    if (_step == 1) {
      final nominal = _amountCtrl.text.trim();
      final tujuan = () {
        if (_mode == 'Nomor Baru') return _phoneCtrl.text.trim();
        if (_mode == 'Rekening Bank') {
          return '$_bank · ${_accountCtrl.text.trim()}';
        }
        final c = _selectedSavedContactDetail();
        return c['detail']!;
      }();
      final catatan = _noteCtrl.text.trim().isEmpty
          ? '-'
          : _noteCtrl.text.trim();

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Konfirmasi Transaksi'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _confirmRow('Dari', _sourceAccount),
                    const SizedBox(height: 10),
                    _confirmRow('Ke', tujuan),
                    const SizedBox(height: 10),
                    _confirmRow('Nominal', 'Rp $nominal'),
                    const SizedBox(height: 10),
                    _confirmRow('Catatan', catatan),
                    const SizedBox(height: 10),
                    _confirmRow(
                      'Simpan sebagai favorit',
                      _saveAsFavorite ? 'Ya' : 'Tidak',
                    ),
                    const Divider(height: 24),
                    _confirmRow('Biaya admin', 'Rp 0'),
                    const SizedBox(height: 6),
                    _confirmRow('Total', 'Rp $nominal', isBold: true),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step = 0),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      side: const BorderSide(color: kPrimaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Ubah'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: _primaryButton(),
                      onPressed: _isSending ? null : _doSend,
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Kirim Sekarang'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // STEP FORM INPUT — scrollable biar tidak overflow
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Sumber dana'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sourceAccount,
                        items: const [
                          DropdownMenuItem(
                            value: 'Dompet Utama',
                            child: Text('Dompet Utama · Rp 5.250.000'),
                          ),
                          DropdownMenuItem(
                            value: 'Tabungan',
                            child: Text('Tabungan · Rp 12.000.000'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _sourceAccount = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle('Tujuan transfer'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Kontak Tersimpan'),
                        selected: _mode == 'Kontak Tersimpan',
                        selectedColor: kPrimaryColor,
                        labelStyle: TextStyle(
                          color: _mode == 'Kontak Tersimpan'
                              ? Colors.white
                              : Colors.black87,
                        ),
                        onSelected: (_) =>
                            setState(() => _mode = 'Kontak Tersimpan'),
                      ),
                      ChoiceChip(
                        label: const Text('Nomor Baru'),
                        selected: _mode == 'Nomor Baru',
                        selectedColor: kPrimaryColor,
                        labelStyle: TextStyle(
                          color: _mode == 'Nomor Baru'
                              ? Colors.white
                              : Colors.black87,
                        ),
                        onSelected: (_) => setState(() => _mode = 'Nomor Baru'),
                      ),
                      ChoiceChip(
                        label: const Text('Rekening Bank'),
                        selected: _mode == 'Rekening Bank',
                        selectedColor: kPrimaryColor,
                        labelStyle: TextStyle(
                          color: _mode == 'Rekening Bank'
                              ? Colors.white
                              : Colors.black87,
                        ),
                        onSelected: (_) =>
                            setState(() => _mode = 'Rekening Bank'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_mode == 'Kontak Tersimpan') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSavedName,
                          items: _savedContacts
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c['name'],
                                  child: Text(c['detail']!),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _selectedSavedName = v);
                          },
                        ),
                      ),
                    ),
                  ] else if (_mode == 'Nomor Baru') ...[
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(
                        'Masukkan nomor HP / ID akun',
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Bank tujuan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _bank,
                          items: const [
                            DropdownMenuItem(value: 'BCA', child: Text('BCA')),
                            DropdownMenuItem(value: 'BNI', child: Text('BNI')),
                            DropdownMenuItem(value: 'BRI', child: Text('BRI')),
                            DropdownMenuItem(
                              value: 'Mandiri',
                              child: Text('Mandiri'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _bank = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _accountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Nomor rekening'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const _SectionTitle('Nominal'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Masukkan jumlah (Rp)'),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final preset in [50000, 100000, 200000, 500000])
                        ActionChip(
                          label: Text('Rp $preset'),
                          onPressed: () => setState(
                            () => _amountCtrl.text = preset.toString(),
                          ),
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle('Catatan (opsional)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteCtrl,
                    decoration: _inputDecoration('Contoh: uang makan siang'),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _saveAsFavorite,
                        activeColor: kPrimaryColor,
                        onChanged: (v) =>
                            setState(() => _saveAsFavorite = v ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'Simpan tujuan ini sebagai penerima favorit',
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: _primaryButton(),
                      onPressed: _canNext
                          ? () => setState(() => _step = 1)
                          : null,
                      child: const Text('Lanjut'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _confirmRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// =============================================================
/// ====================== MINTA UANG ===========================
/// =============================================================

class _RequestMoneyView extends StatefulWidget {
  const _RequestMoneyView();

  @override
  State<_RequestMoneyView> createState() => _RequestMoneyViewState();
}

class _RequestMoneyViewState extends State<_RequestMoneyView> {
  final _amountCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  bool _viaLink = true;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _messageCtrl.dispose();
    _fromCtrl.dispose();
    super.dispose();
  }

  String _generateLink() {
    final nominal = _amountCtrl.text.trim();
    if (nominal.isEmpty) return '-';
    return 'https://paylink.app/req?amt=$nominal';
  }

  @override
  Widget build(BuildContext context) {
    final link = _generateLink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Metode permintaan'),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Link'),
                selected: _viaLink,
                selectedColor: kPrimaryColor,
                labelStyle: TextStyle(
                  color: _viaLink ? Colors.white : Colors.black87,
                ),
                onSelected: (_) => setState(() => _viaLink = true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Langsung ke kontak'),
                selected: !_viaLink,
                selectedColor: kPrimaryColor,
                labelStyle: TextStyle(
                  color: !_viaLink ? Colors.white : Colors.black87,
                ),
                onSelected: (_) => setState(() => _viaLink = false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_viaLink) ...[
            const _SectionTitle('Dari siapa?'),
            const SizedBox(height: 8),
            TextField(
              controller: _fromCtrl,
              decoration: _inputDecoration('Nama atau nomor ponsel'),
            ),
            const SizedBox(height: 16),
          ],
          const _SectionTitle('Nominal'),
          const SizedBox(height: 8),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Masukkan jumlah (Rp)'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('Pesan (opsional)'),
          const SizedBox(height: 8),
          TextField(
            controller: _messageCtrl,
            maxLines: 3,
            decoration: _inputDecoration('Contoh: tolong ganti uang kemarin'),
          ),
          const SizedBox(height: 16),
          if (_viaLink && link != '-') ...[
            const _SectionTitle('Link permintaan'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      link,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link disalin ke clipboard'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: _primaryButton(),
              onPressed: () {
                if (_amountCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nominal belum diisi.')),
                  );
                  return;
                }
                if (!_viaLink && _fromCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama/nomor kontak belum diisi.'),
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _viaLink
                          ? 'Link permintaan siap dibagikan.'
                          : 'Permintaan dikirim ke ${_fromCtrl.text.trim()}.',
                    ),
                  ),
                );
              },
              child: Text(_viaLink ? 'Buat Link' : 'Kirim Permintaan'),
            ),
          ),
        ],
      ),
    );
  }
}

/// =============================================================
/// ==================== AKUN & KARTU ===========================
/// =============================================================

class _AccountCardsView extends StatefulWidget {
  const _AccountCardsView();

  @override
  State<_AccountCardsView> createState() => _AccountCardsViewState();
}

class _AccountCardsViewState extends State<_AccountCardsView> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _current = 0;

  final List<Map<String, dynamic>> _cards = [
    {
      'name': 'Debit Utama',
      'number': '**** 8234',
      'balance': 'Rp 12.500.000',
      'brand': 'VISA',
      'hidden': false,
      'blocked': false,
      'limit': 5000000,
    },
    {
      'name': 'Kartu Belanja',
      'number': '**** 1120',
      'balance': 'Rp 3.250.000',
      'brand': 'MasterCard',
      'hidden': false,
      'blocked': false,
      'limit': 3000000,
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openCardActions(int index) {
    final card = _cards[index];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                card['name'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined),
                title: Text(
                  (card['hidden'] as bool)
                      ? 'Tampilkan saldo'
                      : 'Sembunyikan saldo',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _cards[index]['hidden'] = !(card['hidden'] as bool);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Atur limit transaksi'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final limitCtrl = TextEditingController(
                    text: (card['limit'] as int).toString(),
                  );
                  final res = await showDialog<int>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Atur limit transaksi'),
                      content: TextField(
                        controller: limitCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          'Limit per transaksi (Rp)',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            final v = int.tryParse(limitCtrl.text.trim());
                            Navigator.pop(dCtx, v);
                          },
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  );
                  if (res != null) {
                    setState(() {
                      _cards[index]['limit'] = res;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Limit transaksi diperbarui.'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(
                  (card['blocked'] as bool)
                      ? 'Buka blokir kartu'
                      : 'Blokir kartu sementara',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _cards[index]['blocked'] = !(card['blocked'] as bool);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        (card['blocked'] as bool)
                            ? 'Kartu diblokir sementara.'
                            : 'Blokir kartu dibuka.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _cards[_current];
    final bool blocked = currentCard['blocked'] as bool;
    final int limit = currentCard['limit'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _cards.length,
            itemBuilder: (ctx, i) {
              final c = _cards[i];
              final bool isBlocked = c['blocked'] as bool;
              final bool isHidden = c['hidden'] as bool;

              return GestureDetector(
                onTap: () => _openCardActions(i),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  scale: i == _current ? 1.0 : 0.94,
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: i == 0
                                ? const [Color(0xFF0D47A1), Color(0xFF1976D2)]
                                : const [Color(0xFF1B1B2F), Color(0xFF3A3A6A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  c['name'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  c['brand'] as String,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              c['number'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Saldo',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              isHidden ? '••••••••' : c['balance'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isBlocked)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black.withOpacity(0.45),
                          ),
                          child: const Center(
                            child: Text(
                              'KARTU DIBLOKIR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _cards.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _current ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _current ? kPrimaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _CardInfoRow(
            label: 'Kartu aktif',
            value: currentCard['name'] as String,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _CardInfoRow(
            label: 'No. kartu',
            value: currentCard['number'] as String,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _CardInfoRow(label: 'Limit transaksi', value: 'Rp $limit'),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: _primaryButton(),
                  onPressed: blocked ? null : () => _openCardActions(_current),
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Kelola Kartu'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ajukan kartu baru (mock).')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimaryColor,
                  side: const BorderSide(color: kPrimaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Kartu Baru'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _CardInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// =============================================================
/// ====================== TARIK TUNAI ==========================
/// =============================================================

class _CashOutView extends StatelessWidget {
  const _CashOutView();

  void _openDetail(BuildContext context, String title, String desc) {
    if (title == 'Agen Terdekat') {
      _openAgentOptions(context);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(desc),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: _primaryButton(),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title: kode tarik tunai dibuat.')),
                  );
                },
                child: const Text('Buat Kode Tarik Tunai'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAgentOptions(BuildContext context) {
    String selected = 'Indomaret';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateSheet) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Pilih Agen Tarik Tunai',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<String>(
                    value: 'Indomaret',
                    groupValue: selected,
                    onChanged: (v) => setStateSheet(() => selected = v!),
                    title: const Text('Indomaret'),
                  ),
                  RadioListTile<String>(
                    value: 'Alfamart',
                    groupValue: selected,
                    onChanged: (v) => setStateSheet(() => selected = v!),
                    title: const Text('Alfamart'),
                  ),
                  RadioListTile<String>(
                    value: 'Alfamidi',
                    groupValue: selected,
                    onChanged: (v) => setStateSheet(() => selected = v!),
                    title: const Text('Alfamidi'),
                  ),
                  RadioListTile<String>(
                    value: 'Pegadaian',
                    groupValue: selected,
                    onChanged: (v) => setStateSheet(() => selected = v!),
                    title: const Text('Pegadaian'),
                  ),
                  RadioListTile<String>(
                    value: 'Kantor Pos',
                    groupValue: selected,
                    onChanged: (v) => setStateSheet(() => selected = v!),
                    title: const Text('Kantor Pos'),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: _primaryButton(),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Kode tarik tunai untuk $selected berhasil dibuat.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Buat Kode Tarik Tunai'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> methods = [
      {
        'title': 'ATM Tanpa Kartu',
        'subtitle': 'Tarik tunai via kode QR atau kode angka.',
        'desc':
            'Gunakan fitur ini untuk tarik tunai di ATM tanpa kartu fisik. '
            'Setelah membuat kode, buka ATM yang mendukung dan scan QR/kode tersebut.',
      },
      {
        'title': 'Agen Terdekat',
        'subtitle': 'Tarik tunai di Indomaret, Alfamart, dan agen lain.',
        'desc':
            'Datangi agen resmi yang bekerja sama, tunjukkan kode tarik tunai dan KTP untuk menarik uang tunai.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: methods.length,
      itemBuilder: (context, i) {
        final m = methods[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: kPrimaryColor.withOpacity(0.08),
              child: Icon(
                i == 0 ? Icons.qr_code_2_rounded : Icons.store_rounded,
                color: kPrimaryColor,
              ),
            ),
            title: Text(m['title']!),
            subtitle: Text(m['subtitle']!),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _openDetail(context, m['title']!, m['desc']!),
          ),
        );
      },
    );
  }
}

/// =============================================================
/// ===================== PULSA SELULER =========================
/// =============================================================

class _MobileTopupView extends StatefulWidget {
  const _MobileTopupView();

  @override
  State<_MobileTopupView> createState() => _MobileTopupViewState();
}

class _MobileTopupViewState extends State<_MobileTopupView> {
  final TextEditingController _phoneCtrl = TextEditingController();

  int _selectedType = 0; // 0 = Pulsa, 1 = Data
  int _selectedPulsaIndex = 1;
  int _selectedDataIndex = 0;

  final List<int> _pulsaAmounts = const [
    10000,
    20000,
    25000,
    50000,
    100000,
    150000,
    200000,
  ];

  final List<Map<String, String>> _favoriteNumbers = const [
    {'label': 'Saya', 'number': '0812 3456 7890'},
    {'label': 'Mama', 'number': '0857 2345 8899'},
    {'label': 'Ayah', 'number': '0813 8765 4321'},
  ];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _detectOperator(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('0812') ||
        clean.startsWith('0813') ||
        clean.startsWith('0821')) {
      return 'Telkomsel';
    } else if (clean.startsWith('0857') ||
        clean.startsWith('0856') ||
        clean.startsWith('0858')) {
      return 'Indosat';
    } else if (clean.startsWith('0817') ||
        clean.startsWith('0818') ||
        clean.startsWith('0819')) {
      return 'XL';
    } else if (clean.startsWith('0896') || clean.startsWith('0897')) {
      return 'Tri';
    } else if (clean.startsWith('0838') || clean.startsWith('0831')) {
      return 'Axis';
    } else if (clean.length >= 4) {
      return 'Operator lain';
    }
    return '-';
  }

  List<Map<String, dynamic>> _packagesForOperator(String op) {
    if (op == 'Telkomsel') {
      return [
        {
          'name': 'Combo 5 GB',
          'quota': '5 GB + Telp 30 menit',
          'validity': '7 hari',
          'price': 45000,
        },
        {
          'name': 'Internet 15 GB',
          'quota': '15 GB',
          'validity': '30 hari',
          'price': 110000,
        },
        {
          'name': 'Malam 10 GB',
          'quota': '10 GB',
          'validity': '7 hari',
          'price': 35000,
        },
      ];
    } else if (op == 'Indosat') {
      return [
        {
          'name': 'Freedom 8 GB',
          'quota': '8 GB',
          'validity': '14 hari',
          'price': 40000,
        },
        {
          'name': 'Freedom 20 GB',
          'quota': '20 GB',
          'validity': '30 hari',
          'price': 90000,
        },
        {
          'name': 'Harian 2 GB',
          'quota': '2 GB',
          'validity': '1 hari',
          'price': 7000,
        },
      ];
    } else if (op == 'XL') {
      return [
        {
          'name': 'Xtra Combo 10 GB',
          'quota': '10 GB',
          'validity': '30 hari',
          'price': 80000,
        },
        {
          'name': 'Xtra 25 GB',
          'quota': '25 GB',
          'validity': '30 hari',
          'price': 130000,
        },
        {
          'name': 'Combo Harian 3 GB',
          'quota': '3 GB',
          'validity': '3 hari',
          'price': 20000,
        },
      ];
    } else if (op == 'Tri') {
      return [
        {
          'name': 'Tri 10 GB',
          'quota': '10 GB',
          'validity': '30 hari',
          'price': 70000,
        },
        {
          'name': 'Tri Harian 3 GB',
          'quota': '3 GB',
          'validity': '1 hari',
          'price': 9000,
        },
      ];
    } else if (op == 'Axis') {
      return [
        {
          'name': 'Axis Bronet 8 GB',
          'quota': '8 GB',
          'validity': '30 hari',
          'price': 60000,
        },
        {
          'name': 'Axis Harian 2 GB',
          'quota': '2 GB',
          'validity': '1 hari',
          'price': 6000,
        },
      ];
    } else {
      return [
        {
          'name': 'Data 5 GB',
          'quota': '5 GB',
          'validity': '7 hari',
          'price': 30000,
        },
        {
          'name': 'Data 12 GB',
          'quota': '12 GB',
          'validity': '30 hari',
          'price': 75000,
        },
      ];
    }
  }

  bool get _canPay {
    final phoneValid =
        _phoneCtrl.text.replaceAll(RegExp(r'\D'), '').length >= 10;
    return phoneValid;
  }

  void _selectFavorite(Map<String, String> fav) {
    setState(() {
      _phoneCtrl.text = fav['number']!;
    });
  }

  int _pricePulsaForOperator(String op, int base) {
    if (op == 'Telkomsel') return (base * 1.08).round();
    if (op == 'Indosat') return (base * 1.05).round();
    if (op == 'XL') return (base * 1.06).round();
    if (op == 'Tri') return (base * 1.04).round();
    if (op == 'Axis') return (base * 1.045).round();
    return base;
  }

  Future<void> _showConfirmSheet() async {
    if (!_canPay) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor ponsel belum valid.')),
      );
      return;
    }

    final phone = _phoneCtrl.text.trim();
    final operator = _detectOperator(phone);
    final isPulsa = _selectedType == 0;
    final packages = _packagesForOperator(operator);

    final int price;
    final String productName;

    if (isPulsa) {
      price = _pricePulsaForOperator(
        operator,
        _pulsaAmounts[_selectedPulsaIndex],
      );
      productName = 'Pulsa Rp ${_pulsaAmounts[_selectedPulsaIndex]}';
    } else {
      final pkg = packages[_selectedDataIndex % packages.length];
      price = pkg['price'] as int;
      productName = pkg['name'] as String;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: _ConfirmTopupSheet(
            phone: phone,
            operatorInfo: operator,
            productName: productName,
            price: price,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final op = _detectOperator(_phoneCtrl.text);
    final packages = _packagesForOperator(op);
    final isPulsa = _selectedType == 0;

    final int selectedPrice = isPulsa
        ? _pricePulsaForOperator(op, _pulsaAmounts[_selectedPulsaIndex])
        : packages[_selectedDataIndex % packages.length]['price'] as int;
    final String selectedProduct = isPulsa
        ? 'Pulsa Rp ${_pulsaAmounts[_selectedPulsaIndex]}'
        : packages[_selectedDataIndex % packages.length]['name'] as String;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Nomor tujuan'),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Contoh: 0857 23xx xxxx'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.sim_card_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      op == '-' ? 'Masukkan nomor untuk deteksi operator' : op,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.contacts_outlined, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Buka kontak (mock).')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _favoriteNumbers.map((fav) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fav['label']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                fav['number']!,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          avatar: const Icon(Icons.person, size: 18),
                          onPressed: () => _selectFavorite(fav),
                          backgroundColor: Colors.white,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),
                const _SectionTitle('Jenis isi ulang'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedType = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedType == 0
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Pulsa',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _selectedType == 0
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedType = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedType == 1
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Paket Data',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _selectedType == 1
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 230,
                  child: isPulsa
                      ? _buildPulsaGrid(op)
                      : _buildDataList(packages),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _summaryRow(
                        'Nomor',
                        _phoneCtrl.text.isEmpty ? '-' : _phoneCtrl.text,
                      ),
                      const SizedBox(height: 4),
                      _summaryRow('Operator', op),
                      const SizedBox(height: 4),
                      _summaryRow('Produk', selectedProduct),
                      const SizedBox(height: 4),
                      _summaryRow('Total bayar', 'Rp $selectedPrice'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: _primaryButton(),
                    onPressed: _canPay ? _showConfirmSheet : null,
                    icon: const Icon(Icons.lock),
                    label: const Text('Bayar dengan Saldo'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsaGrid(String op) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Nominal pulsa'),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (int i = 0; i < _pulsaAmounts.length; i++)
                  ChoiceChip(
                    label: Text(
                      'Rp ${_pricePulsaForOperator(op, _pulsaAmounts[i])}',
                    ),
                    selected: _selectedPulsaIndex == i,
                    selectedColor: kPrimaryColor,
                    labelStyle: TextStyle(
                      color: _selectedPulsaIndex == i
                          ? Colors.white
                          : Colors.black87,
                    ),
                    onSelected: (_) => setState(() => _selectedPulsaIndex = i),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataList(List<Map<String, dynamic>> packages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Paket data tersedia'),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: packages.length,
            itemBuilder: (ctx, i) {
              final p = packages[i];
              final selected = _selectedDataIndex == i;

              return GestureDetector(
                onTap: () => setState(() => _selectedDataIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? kPrimaryColor.withOpacity(0.07)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? kPrimaryColor : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.data_usage,
                        color: selected ? kPrimaryColor : Colors.grey[600],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.black
                                    : Colors.grey[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${p['quota']} • ${p['validity']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Rp ${p['price']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected ? kPrimaryColor : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _ConfirmTopupSheet extends StatefulWidget {
  final String phone;
  final String operatorInfo;
  final String productName;
  final int price;

  const _ConfirmTopupSheet({
    required this.phone,
    required this.operatorInfo,
    required this.productName,
    required this.price,
  });

  @override
  State<_ConfirmTopupSheet> createState() => _ConfirmTopupSheetState();
}

class _ConfirmTopupSheetState extends State<_ConfirmTopupSheet> {
  bool _processing = false;
  bool _success = false;

  Future<void> _doPay() async {
    setState(() {
      _processing = true;
      _success = false;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Tambah ke riwayat global
    AppHistory.add('Pulsa / Data', 'Hari ini', -widget.price);

    setState(() {
      _processing = false;
      _success = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F5E9),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 40,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pembayaran Berhasil',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(widget.productName, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            'Rp ${widget.price}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            widget.phone,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail transaksi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                _sheetRow('Nomor', widget.phone),
                const SizedBox(height: 4),
                _sheetRow('Operator', widget.operatorInfo),
                const SizedBox(height: 4),
                _sheetRow('Produk', widget.productName),
                const SizedBox(height: 4),
                _sheetRow('Biaya admin', 'Rp 0'),
                const Divider(height: 22),
                _sheetRow('Total bayar', 'Rp ${widget.price}', bold: true),
                _sheetRow('ID Transaksi', '#TOPUP123456'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: _primaryButton(),
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const GenericMenuPage(title: 'Riwayat Transaksi'),
                ),
              );
            },
            child: const Text('Lihat riwayat transaksi'),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const Text(
          'Konfirmasi Pembayaran',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        _sheetRow('Nomor', widget.phone),
        const SizedBox(height: 6),
        _sheetRow('Operator', widget.operatorInfo),
        const SizedBox(height: 6),
        _sheetRow('Produk', widget.productName),
        const SizedBox(height: 6),
        _sheetRow('Biaya admin', 'Rp 0'),
        const Divider(height: 24),
        _sheetRow('Total bayar', 'Rp ${widget.price}', bold: true),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: _primaryButton(),
            onPressed: _processing ? null : _doPay,
            child: _processing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Bayar Sekarang'),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  static Widget _sheetRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// =============================================================
/// ==================== BAYAR TAGIHAN ==========================
/// =============================================================

class _BillPaymentView extends StatelessWidget {
  const _BillPaymentView();

  void _openBillForm(BuildContext context, String billType) {
    final idCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: _BillFormSheet(
          billType: billType,
          idCtrl: idCtrl,
          amountCtrl: amountCtrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> favorites = [
      {'title': 'Listrik', 'icon': Icons.bolt_rounded},
      {'title': 'Internet', 'icon': Icons.wifi_rounded},
    ];

    final List<Map<String, Object>> others = [
      {'title': 'Air', 'icon': Icons.water_drop_rounded},
      {'title': 'TV Kabel', 'icon': Icons.live_tv_rounded},
      {'title': 'Telkom', 'icon': Icons.phone},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle('Favorit'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: favorites
              .map(
                (b) => _BillChip(
                  title: b['title'] as String,
                  icon: b['icon'] as IconData,
                  onTap: () => _openBillForm(context, b['title'] as String),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Semua layanan'),
        const SizedBox(height: 8),
        ...others.map(
          (b) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: kPrimaryColor.withOpacity(0.08),
                child: Icon(b['icon'] as IconData, color: kPrimaryColor),
              ),
              title: Text(b['title'] as String),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _openBillForm(context, b['title'] as String),
            ),
          ),
        ),
      ],
    );
  }
}

class _BillChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _BillChip({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: kPrimaryColor),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class _BillFormSheet extends StatefulWidget {
  final String billType;
  final TextEditingController idCtrl;
  final TextEditingController amountCtrl;

  const _BillFormSheet({
    required this.billType,
    required this.idCtrl,
    required this.amountCtrl,
  });

  @override
  State<_BillFormSheet> createState() => _BillFormSheetState();
}

class _BillFormSheetState extends State<_BillFormSheet> {
  bool _processing = false;
  bool _fixedAmount = true;
  bool _success = false;

  int get _defaultAmount {
    switch (widget.billType) {
      case 'Listrik':
        return 250000;
      case 'Internet':
        return 280000;
      case 'Air':
        return 90000;
      case 'TV Kabel':
        return 150000;
      case 'Telkom':
        return 120000;
      default:
        return 100000;
    }
  }

  Future<void> _processPayment() async {
    if (widget.idCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID pelanggan wajib diisi.')),
      );
      return;
    }

    if (!_fixedAmount && widget.amountCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tagihan wajib diisi.')),
      );
      return;
    }

    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final int amount = _fixedAmount
        ? _defaultAmount
        : int.tryParse(widget.amountCtrl.text.trim()) ?? _defaultAmount;

    // Tambah ke riwayat global
    AppHistory.add('Bayar ${widget.billType}', 'Hari ini', -amount);

    setState(() {
      _processing = false;
      _success = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int amount = _fixedAmount
        ? _defaultAmount
        : int.tryParse(widget.amountCtrl.text.trim()) ?? _defaultAmount;

    if (_success) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8F5E9),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Pembayaran ${widget.billType} Berhasil',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail pembayaran',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                _summaryRow('Layanan', widget.billType),
                const SizedBox(height: 4),
                _summaryRow(
                  'ID Pelanggan',
                  widget.idCtrl.text.trim().isEmpty
                      ? '-'
                      : widget.idCtrl.text.trim(),
                ),
                const SizedBox(height: 4),
                _summaryRow('Biaya admin', 'Rp 0'),
                const Divider(height: 22),
                _summaryRow('Total bayar', 'Rp $amount', bold: true),
                _summaryRow('ID Transaksi', '#BILL123456'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: _primaryButton(),
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const GenericMenuPage(title: 'Riwayat Transaksi'),
                  ),
                );
              },
              child: const Text('Lihat riwayat transaksi'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text(
          'Bayar ${widget.billType}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: widget.idCtrl,
          decoration: _inputDecoration('ID pelanggan'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Nominal tagihan',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Switch(
              value: _fixedAmount,
              activeThumbColor: kPrimaryColor,
              onChanged: (v) => setState(() => _fixedAmount = v),
            ),
            Text(
              _fixedAmount ? 'Otomatis' : 'Manual',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        if (!_fixedAmount) ...[
          const SizedBox(height: 4),
          TextField(
            controller: widget.amountCtrl,
            decoration: _inputDecoration('Masukkan nominal (Rp)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
        ] else ...[
          const SizedBox(height: 4),
          Text(
            'Perkiraan tagihan: Rp $_defaultAmount',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              _summaryRow('Layanan', widget.billType),
              const SizedBox(height: 4),
              _summaryRow(
                'ID Pelanggan',
                widget.idCtrl.text.trim().isEmpty
                    ? '-'
                    : widget.idCtrl.text.trim(),
              ),
              const SizedBox(height: 4),
              _summaryRow('Biaya admin', 'Rp 0'),
              const Divider(height: 22),
              _summaryRow('Total bayar', 'Rp $amount', bold: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: _primaryButton(),
            onPressed: _processing ? null : _processPayment,
            child: _processing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Bayar Sekarang'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  static Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// =============================================================
/// ======================== TABUNGAN ===========================
/// =============================================================

class _SavingsView extends StatefulWidget {
  const _SavingsView();

  @override
  State<_SavingsView> createState() => _SavingsViewState();
}

class _SavingsViewState extends State<_SavingsView> {
  final List<Map<String, dynamic>> _goals = [
    {'name': 'Liburan Bali', 'target': 10000000, 'current': 6000000},
    {'name': 'Dana Darurat', 'target': 15000000, 'current': 4500000},
  ];

  void _showAddGoalSheet() {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Buat Tabungan Baru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: _inputDecoration('Nama tujuan'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Target (Rp)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: _primaryButton(),
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty ||
                      targetCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama & target wajib diisi.'),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _goals.add({
                      'name': nameCtrl.text.trim(),
                      'target': int.tryParse(targetCtrl.text.trim()) ?? 0,
                      'current': 0,
                    });
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _topUpGoal(int index) {
    final topUpCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tambah Tabungan (${_goals[index]['name']})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: topUpCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Nominal (Rp)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: _primaryButton(),
                onPressed: () {
                  final add = int.tryParse(topUpCtrl.text.trim()) ?? 0;
                  if (add <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nominal tidak valid.')),
                    );
                    return;
                  }
                  setState(() {
                    _goals[index]['current'] =
                        (_goals[index]['current'] as int) + add;
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Tambahkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _goals.length,
          itemBuilder: (ctx, i) {
            final g = _goals[i];
            final double progress =
                (g['current'] as int) / (g['target'] as int);

            return GestureDetector(
              onTap: () => _topUpGoal(i),
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Target: Rp ${g['target']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Terkumpul: Rp ${g['current']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        color: kPrimaryColor,
                        minHeight: 6,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}% tercapai',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: kPrimaryColor,
            onPressed: _showAddGoalSheet,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

/// =============================================================
/// ===================== KARTU KREDIT ==========================
/// =============================================================

class _CreditCardView extends StatefulWidget {
  const _CreditCardView();

  @override
  State<_CreditCardView> createState() => _CreditCardViewState();
}

class _CreditCardViewState extends State<_CreditCardView> {
  int _tab = 0; // 0 ringkasan, 1 rincian

  void _openPaySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool processing = false;
        bool success = false;
        String method = 'Saldo Dompet';

        return StatefulBuilder(
          builder: (ctx, setStateSheet) {
            Future<void> doPay() async {
              setStateSheet(() {
                processing = true;
                success = false;
              });
              await Future.delayed(const Duration(seconds: 2));
              if (!mounted) return;

              // Tambah ke riwayat global
              AppHistory.add('Bayar Kartu Kredit', 'Hari ini', -2450000);

              setStateSheet(() {
                processing = false;
                success = true;
              });
            }

            if (success) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE8F5E9),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pembayaran Berhasil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kartu Kredit · Platinum Card',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Rp 2.450.000',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Detail pembayaran',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 6),
                          _HistoryDetailRow(
                            label: 'Metode',
                            value: 'Saldo Dompet',
                          ),
                          SizedBox(height: 4),
                          _HistoryDetailRow(
                            label: 'Biaya admin',
                            value: 'Rp 0',
                          ),
                          Divider(height: 22),
                          _HistoryDetailRow(
                            label: 'ID Transaksi',
                            value: '#CCPAY123456',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: _primaryButton(),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GenericMenuPage(
                              title: 'Riwayat Transaksi',
                            ),
                          ),
                        );
                      },
                      child: const Text('Lihat riwayat transaksi'),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Konfirmasi Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tagihan bulan ini',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rp 2.450.000',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Metode pembayaran',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  RadioListTile<String>(
                    value: 'Saldo Dompet',
                    groupValue: method,
                    onChanged: (v) =>
                        setStateSheet(() => method = v ?? 'Saldo Dompet'),
                    title: const Text('Saldo Dompet'),
                  ),
                  RadioListTile<String>(
                    value: 'Rekening Utama',
                    groupValue: method,
                    onChanged: (v) =>
                        setStateSheet(() => method = v ?? 'Rekening Utama'),
                    title: const Text('Rekening Utama'),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: _primaryButton(),
                      onPressed: processing ? null : doPay,
                      child: processing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Bayar Sekarang'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimaryColor, Color(0xFF7F1FFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Platinum Card',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '**** 5678',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Tagihan bulan ini',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 4),
                Text(
                  'Rp 2.450.000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Jatuh tempo: 15 Des 2025',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _tab == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Ringkasan',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _tab == 0 ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _tab == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Rincian',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _tab == 1 ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _tab == 0
                ? ListView(
                    children: const [
                      _TransactionTile(
                        title: 'Belanja Marketplace',
                        subtitle: 'Kemarin',
                        amount: '-Rp 750.000',
                      ),
                      _TransactionTile(
                        title: 'Restoran',
                        subtitle: '2 hari lalu',
                        amount: '-Rp 320.000',
                      ),
                      _TransactionTile(
                        title: 'Langganan Streaming',
                        subtitle: '5 hari lalu',
                        amount: '-Rp 120.000',
                      ),
                    ],
                  )
                : ListView(
                    children: const [
                      ListTile(
                        title: Text('Limit kartu'),
                        trailing: Text('Rp 15.000.000'),
                      ),
                      ListTile(
                        title: Text('Sisa limit'),
                        trailing: Text('Rp 12.550.000'),
                      ),
                      ListTile(
                        title: Text('Bunga per bulan'),
                        trailing: Text('1.99%'),
                      ),
                      ListTile(
                        title: Text('Minimum pembayaran'),
                        trailing: Text('Rp 250.000'),
                      ),
                    ],
                  ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: _primaryButton(),
              onPressed: _openPaySheet,
              child: const Text('Bayar Sekarang'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _HistoryDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

/// =============================================================
/// ================== RIWAYAT TRANSAKSI ========================
/// =============================================================

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  int _filter = 0; // 0 semua, 1 masuk, 2 keluar

  @override
  Widget build(BuildContext context) {
    final raw = AppHistory.items;

    final filtered = raw.where((t) {
      final amount = t['amount'] as int;
      if (_filter == 1) {
        return amount > 0;
      }
      if (_filter == 2) {
        return amount < 0;
      }
      return true;
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Semua'),
                selected: _filter == 0,
                selectedColor: kPrimaryColor,
                labelStyle: TextStyle(
                  color: _filter == 0 ? Colors.white : Colors.black87,
                ),
                onSelected: (_) => setState(() => _filter = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Masuk'),
                selected: _filter == 1,
                selectedColor: Colors.green,
                labelStyle: TextStyle(
                  color: _filter == 1 ? Colors.white : Colors.black87,
                ),
                onSelected: (_) => setState(() => _filter = 1),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Keluar'),
                selected: _filter == 2,
                selectedColor: Colors.red,
                labelStyle: TextStyle(
                  color: _filter == 2 ? Colors.white : Colors.black87,
                ),
                onSelected: (_) => setState(() => _filter = 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final t = filtered[i];
              final amount = t['amount'] as int;
              final isPositive = amount > 0;
              final amountStr = '${isPositive ? '+' : '-'}Rp ${amount.abs()}';

              return _TransactionTile(
                title: t['title'] as String,
                subtitle: t['subtitle'] as String,
                amount: amountStr,
                positive: isPositive,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool positive;

  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.positive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive ? Colors.green : Colors.red;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimaryColor.withOpacity(0.1),
          child: Icon(
            positive
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: kPrimaryColor,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          amount,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// =============================================================
/// ==================== DAFTAR PENERIMA ========================
/// =============================================================

class _BeneficiariesView extends StatefulWidget {
  const _BeneficiariesView();

  @override
  State<_BeneficiariesView> createState() => _BeneficiariesViewState();
}

class _BeneficiariesViewState extends State<_BeneficiariesView> {
  final List<Map<String, String>> _recipients = [
    {'name': 'Budi Santoso', 'account': '0812 1234 5678'},
    {'name': 'Ana Rahma', 'account': '0857 2345 8899'},
    {'name': 'Orang Tua', 'account': '123-456-789'},
  ];

  String _query = '';

  void _openRecipientActions(Map<String, String> r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                r['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(r['account']!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.send_rounded),
                title: const Text('Kirim uang'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GenericMenuPage(title: 'Kirim Uang', preset: r),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Ubah alias'),
                onTap: () {
                  Navigator.pop(ctx);
                  final aliasCtrl = TextEditingController(text: r['name']!);
                  showDialog(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Ubah alias'),
                      content: TextField(
                        controller: aliasCtrl,
                        decoration: _inputDecoration('Nama baru'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            final newName = aliasCtrl.text.trim();
                            if (newName.isNotEmpty) {
                              setState(() {
                                final idx = _recipients.indexWhere(
                                  (e) => e['account'] == r['account'],
                                );
                                if (idx != -1) {
                                  _recipients[idx]['name'] = newName;
                                }
                              });
                            }
                            Navigator.pop(dCtx);
                          },
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Hapus penerima',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Hapus penerima'),
                      content: Text(
                        'Yakin ingin menghapus ${r['name']} dari daftar penerima?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _recipients.removeWhere(
                                (e) => e['account'] == r['account'],
                              );
                            });
                            Navigator.pop(dCtx);
                          },
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _recipients.where((r) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return r['name']!.toLowerCase().contains(q) ||
          r['account']!.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: _inputDecoration('Cari nama atau nomor'),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Penerima tidak ditemukan',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final r = filtered[i];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kPrimaryColor.withOpacity(0.08),
                          child: Text(
                            r['name']!.substring(0, 1),
                            style: const TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(r['name']!),
                        subtitle: Text(r['account']!),
                        trailing: const Icon(Icons.more_horiz_rounded),
                        onTap: () => _openRecipientActions(r),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// =============================================================
/// ========================= FALLBACK ==========================
/// =============================================================

class _PlaceholderView extends StatelessWidget {
  final String title;
  const _PlaceholderView({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Halaman "$title" belum diatur khusus.\nSilakan sesuaikan sendiri.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
