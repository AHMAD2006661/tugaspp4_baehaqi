// transfer_screen.dart
// Transfer screen ala aplikasi dompet digital (DANA-style)
// Theme color: deep purple 0xFFBE29EC

import 'dart:async';
import 'package:flutter/material.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class Beneficiary {
  String name;
  String account;
  String bank;
  Beneficiary({required this.name, required this.account, required this.bank});
}

class TransferRecord {
  final String id;
  final String toName;
  final String toAccount;
  final String bank;
  final String amount;
  final DateTime time;
  final String note;

  TransferRecord({
    required this.id,
    required this.toName,
    required this.toAccount,
    required this.bank,
    required this.amount,
    required this.time,
    required this.note,
  });
}

class _TransferScreenState extends State<TransferScreen>
    with TickerProviderStateMixin {
  final Color primary = const Color(0xFFBE29EC);

  // controllers
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _accountCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  // state
  bool _saveBeneficiary = true;
  String selectedMethod = "Sesama Bank";
  final List<String> methods = ["Sesama Bank", "Antar Bank", "Nomor Kartu"];
  String selectedBank = "BCA";

  bool _accountValid = false;
  String _detectedName = "";
  bool _detecting = false;

  List<Beneficiary> beneficiaries = [
    Beneficiary(name: "Budi Santoso", account: "0812 1234 5678", bank: "BCA"),
    Beneficiary(name: "Ana Rahma", account: "0857 2345 8899", bank: "Mandiri"),
  ];

  List<TransferRecord> history = [];

  // animation controller (kalau nanti mau dipakai ke dialog animasi)
  late final AnimationController _successCtrl;

  Timer? _debounceTimer;

  // slide to confirm
  double _slidePos = 0.0;
  bool _slideConfirmed = false;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _accountCtrl.addListener(_onAccountChanged);
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    _nameCtrl.dispose();
    _accountCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // =========================================================
  // =========== HELPER: DETEKSI NAMA REKENING ===============
  // =========================================================

  void _onAccountChanged() {
    _debounceAccountDetect();
  }

  void _debounceAccountDetect() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      final acc = _accountCtrl.text;
      if (acc.trim().isEmpty) {
        setState(() {
          _detectedName = "";
          _accountValid = false;
          _detecting = false;
        });
        return;
      }
      _autoDetectName(acc);
    });
  }

  Future<void> _autoDetectName(String account) async {
    setState(() {
      _detectedName = "";
      _detecting = true;
      _accountValid = false;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    final clean = account.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length >= 6) {
      final lastDigit =
          clean.isNotEmpty ? int.parse(clean[clean.length - 1]) : 0;
      final mockNames = [
        "Aria",
        "Budi",
        "Cahya",
        "Dewi",
        "Eka",
        "Fajar",
        "Gita",
        "Hana",
        "Irfan",
        "Jono"
      ];
      final name = mockNames[lastDigit % mockNames.length];
      setState(() {
        _detectedName = "$name $clean";
        _accountValid = true;
        _detecting = false;
        _nameCtrl.text = _detectedName;
      });
    } else {
      setState(() {
        _detectedName = "";
        _accountValid = false;
        _detecting = false;
      });
    }
  }

  // =========================================================
  // ================== FORMAT RUPIAH INPUT ==================
  // =========================================================

  String _formatRupiah(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final chars = digits.split('');
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      final revIndex = chars.length - 1 - i;
      buffer.write(chars[revIndex]);
      if ((i + 1) % 3 == 0 && revIndex != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join();
  }

  // =========================================================
  // ======================= VALIDASI =========================
  // =========================================================

  bool _validateAll() {
    if (_nameCtrl.text.trim().isEmpty) return false;
    if (_accountCtrl.text.trim().length < 6) return false;
    if (_amountCtrl.text.trim().isEmpty) return false;
    return true;
  }

  void _showMissingDataSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lengkapi data terlebih dahulu.")),
    );
  }

  // =========================================================
  // ==================== TRANSFER LOGIC ======================
  // =========================================================

  Future<void> _performTransfer() async {
    final String id = 'TRX${DateTime.now().millisecondsSinceEpoch}';
    final String name = _nameCtrl.text.trim();
    final String acc = _accountCtrl.text.trim();
    final String bank = selectedBank;
    final String amount = _amountCtrl.text.trim();
    final String note = _noteCtrl.text.trim();

    final record = TransferRecord(
      id: id,
      toName: name,
      toAccount: acc,
      bank: bank,
      amount: amount,
      time: DateTime.now(),
      note: note,
    );

    setState(() {
      history.insert(0, record);
      if (_saveBeneficiary) {
        final already = beneficiaries.indexWhere(
              (b) => b.account == acc && b.bank == bank,
            ) !=
            -1;
        if (!already) {
          beneficiaries.insert(
            0,
            Beneficiary(name: name, account: acc, bank: bank),
          );
        }
      }
    });

    await _showSuccessSheet(record);

    // reset form
    _nameCtrl.clear();
    _accountCtrl.clear();
    _amountCtrl.clear();
    _noteCtrl.clear();
    setState(() {
      _detectedName = "";
      _accountValid = false;
      _slideConfirmed = false;
      _slidePos = 0.0;
    });
  }

  Future<void> _showSuccessSheet(TransferRecord record) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8F5E9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
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
                'Rp ${record.amount}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                record.toName,
                style: const TextStyle(fontSize: 14),
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
                    _detailRow('Ke', '${record.toName} · ${record.toAccount}'),
                    const SizedBox(height: 4),
                    _detailRow('Bank', record.bank),
                    const SizedBox(height: 4),
                    _detailRow('Catatan', record.note.isEmpty ? '-' : record.note),
                    const SizedBox(height: 4),
                    _detailRow('Biaya admin', 'Rp 0'),
                    const Divider(height: 22),
                    _detailRow('ID Transaksi', record.id),
                    _detailRow(
                      'Waktu',
                      '${record.time.day.toString().padLeft(2, '0')}-'
                      '${record.time.month.toString().padLeft(2, '0')}-'
                      '${record.time.year} '
                      '${record.time.hour.toString().padLeft(2, '0')}:'
                      '${record.time.minute.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Kembali'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openHistory();
                },
                child: const Text('Lihat riwayat transaksi'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
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

  // =========================================================
  // ====================== PILIH BANK ========================
  // =========================================================

  List<String> _bankList() {
    return [
      "BCA",
      "BRI",
      "BNI",
      "Mandiri",
      "BTN",
      "Danamon",
      "CIMB Niaga",
      "Permata",
      "Mega",
      "Sinarmas",
      "BTPN (Jenius)",
      "Maybank",
      "OCBC NISP",
      "Panin",
      "Bank DKI",
      "Bank Jatim",
      "Bank Aceh",
      // beberapa internasional
      "Visa",
      "Mastercard",
      "American Express",
      "PayPal",
    ];
  }

  Widget _bankIcon(String bank) {
    const internationals = {
      "Visa",
      "Mastercard",
      "American Express",
      "PayPal",
    };
    if (internationals.contains(bank)) {
      return CircleAvatar(
        backgroundColor: primary.withOpacity(0.12),
        child: Text(
          bank[0],
          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          bank.substring(0, 1),
          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showBankPicker() {
    final banks = _bankList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: 420,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                height: 5,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pilih Bank',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: banks.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final b = banks[i];
                    return ListTile(
                      leading: _bankIcon(b),
                      title: Text(b),
                      onTap: () {
                        setState(() => selectedBank = b);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // =============== PENERIMA / BENEFICIARIES ================
  // =========================================================

  Widget _addBeneficiaryTile() {
    return GestureDetector(
      onTap: _showAddBeneficiaryDialog,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          const Text('Tambah', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showAddBeneficiaryDialog() {
    final nameCtrl = TextEditingController();
    final accCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Penerima'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: accCtrl,
              decoration: const InputDecoration(labelText: 'No. Rekening / HP'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final n = nameCtrl.text.trim();
              final a = accCtrl.text.trim();
              if (n.isNotEmpty && a.isNotEmpty) {
                setState(() {
                  beneficiaries.insert(
                    0,
                    Beneficiary(name: n, account: a, bank: selectedBank),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showBeneficiaryManager() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setStateModal) {
            return SizedBox(
              height: 420,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    height: 5,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Daftar Penerima',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: beneficiaries.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada penerima tersimpan',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: beneficiaries.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final b = beneficiaries[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      primary.withOpacity(0.12),
                                  child: Text(
                                    b.name[0],
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(b.name),
                                subtitle:
                                    Text('${b.bank} · ${b.account}'),
                                trailing: PopupMenuButton<String>(
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Ubah'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Hapus'),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      setStateModal(
                                        () =>
                                            beneficiaries.removeAt(i),
                                      );
                                      setState(() {});
                                    } else if (value == 'edit') {
                                      // Untuk sekarang, mock edit
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Fitur ubah penerima (mock).'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                onTap: () {
                                  // pilih penerima
                                  setState(() {
                                    _nameCtrl.text = b.name;
                                    _accountCtrl.text = b.account;
                                    selectedBank = b.bank;
                                    _detectedName = b.name;
                                    _accountValid = true;
                                  });
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showAddBeneficiaryDialog();
                        },
                        child: const Text('Tambah Penerima'),
                      ),
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

  // =========================================================
  // =============== SLIDE TO CONFIRM WIDGET =================
  // =========================================================

  Widget _buildSlideToConfirm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const knobSize = 56.0;
        final maxPos = width - knobSize;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _slidePos += details.delta.dx;
              if (_slidePos < 0) _slidePos = 0;
              if (_slidePos > maxPos) _slidePos = maxPos;
            });
          },
          onHorizontalDragEnd: (details) {
            if (_slidePos > maxPos * 0.75) {
              setState(() {
                _slidePos = maxPos;
                _slideConfirmed = true;
              });
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_validateAll()) {
                  _performTransfer();
                } else {
                  _showMissingDataSnackbar();
                  setState(() {
                    _slidePos = 0;
                    _slideConfirmed = false;
                  });
                }
              });
            } else {
              setState(() {
                _slidePos = 0;
                _slideConfirmed = false;
              });
            }
          },
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: knobSize,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Text(
                    _slideConfirmed
                        ? 'Terkonfirmasi'
                        : 'Geser untuk kirim',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _slidePos,
                child: Container(
                  width: knobSize,
                  height: knobSize,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // ================== KONFIRMASI BOTTOM SHEET ==============
  // =========================================================

  void _showConfirmationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          child: SizedBox(
            height: 260,
            child: Column(
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
                Text(
                  'Konfirmasi Transfer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 16),
                _confirmationRow(
                  'Nama penerima',
                  _nameCtrl.text.trim().isEmpty
                      ? '-'
                      : _nameCtrl.text.trim(),
                ),
                const SizedBox(height: 8),
                _confirmationRow(
                  'No. rekening / HP',
                  _accountCtrl.text.trim().isEmpty
                      ? '-'
                      : _accountCtrl.text.trim(),
                ),
                const SizedBox(height: 8),
                _confirmationRow(
                  'Bank',
                  selectedBank,
                ),
                const SizedBox(height: 8),
                _confirmationRow(
                  'Nominal',
                  _amountCtrl.text.trim().isEmpty
                      ? '-'
                      : 'Rp ${_amountCtrl.text.trim()}',
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (_validateAll()) {
                        _performTransfer();
                      } else {
                        _showMissingDataSnackbar();
                      }
                    },
                    child: const Text(
                      'Kirim Sekarang',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _confirmationRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ==================== RIWAYAT TRANSFER ====================
  // =========================================================

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoryPage(history: history, primary: primary),
      ),
    );
  }

  // =========================================================
  // ========================= UI MAIN ========================
  // =========================================================

  InputDecoration _inputDecoration(String label,
      {Widget? suffix, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 8,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Transfer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, const Color(0xFFDE4BFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _openHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // kartu sumber saldo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, const Color(0xFF7F1FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Dompet Utama',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '**** 8234',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Saldo tersedia',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp 5.250.000',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Metode tujuan',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: methods.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final m = methods[i];
                  final selected = m == selectedMethod;
                  return GestureDetector(
                    onTap: () => setState(() => selectedMethod = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 150,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? primary
                              : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          if (selected)
                            BoxShadow(
                              color: primary.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          m,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Penerima tersimpan',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: _showBeneficiaryManager,
                  child: Text(
                    'Kelola',
                    style: TextStyle(color: primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: beneficiaries.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (index == 0) return _addBeneficiaryTile();
                  final b = beneficiaries[index - 1];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _nameCtrl.text = b.name;
                        _accountCtrl.text = b.account;
                        selectedBank = b.bank;
                        _detectedName = b.name;
                        _accountValid = true;
                      });
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: primary.withOpacity(0.14),
                          child: Text(
                            b.name[0],
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.name,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            // INPUT AREA
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: _inputDecoration(
                      'Nama penerima',
                      hint: 'Contoh: Budi Santoso',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    OutlinedButton(
                      onPressed: _showBankPicker,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance, color: primary),
                          const SizedBox(height: 4),
                          Text(
                            selectedBank,
                            style: TextStyle(
                              color: primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _accountCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'No. rekening / HP',
                hint: 'Masukkan nomor rekening atau HP',
                suffix: _detecting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : (_accountValid
                        ? const Icon(Icons.check_circle,
                            color: Colors.green)
                        : null),
              ),
            ),
            const SizedBox(height: 4),
            if (_detectedName.isNotEmpty)
              Text(
                'Nama rekening terdeteksi: $_detectedName',
                style: const TextStyle(
                    fontSize: 12, color: Colors.green),
              )
            else if (_accountCtrl.text.isNotEmpty &&
                !_detecting &&
                !_accountValid)
              const Text(
                'Nomor belum valid, periksa kembali.',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final formatted = _formatRupiah(v);
                if (formatted != v) {
                  _amountCtrl.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                        offset: formatted.length),
                  );
                }
              },
              decoration: _inputDecoration(
                'Nominal (Rp)',
                hint: 'Contoh: 150.000',
              ),
            ),
            const SizedBox(height: 8),
            if (_amountCtrl.text.isNotEmpty)
              Text(
                'Total: Rp ${_amountCtrl.text}',
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              decoration: _inputDecoration(
                'Catatan (opsional)',
                hint: 'Contoh: uang makan siang',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _saveBeneficiary,
                  activeColor: primary,
                  onChanged: (v) =>
                      setState(() => _saveBeneficiary = v ?? true),
                ),
                const Expanded(
                  child: Text(
                    'Simpan penerima ke daftar favorit',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildSlideToConfirm(),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      if (_validateAll()) {
                        _showConfirmationSheet();
                      } else {
                        _showMissingDataSnackbar();
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Lanjutkan'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _openHistory,
                  icon: Icon(Icons.receipt_long, color: primary),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// ======================= HISTORY PAGE ========================
// =============================================================

class HistoryPage extends StatelessWidget {
  final List<TransferRecord> history;
  final Color primary;

  const HistoryPage({
    super.key,
    required this.history,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transfer'),
        centerTitle: false,
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          color: primary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'Belum ada riwayat transfer',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final h = history[i];
                final timeStr =
                    '${h.time.day.toString().padLeft(2, '0')}-'
                    '${h.time.month.toString().padLeft(2, '0')}-'
                    '${h.time.year} · '
                    '${h.time.hour.toString().padLeft(2, '0')}:'
                    '${h.time.minute.toString().padLeft(2, '0')}';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primary.withOpacity(0.14),
                    child: Text(
                      h.toName[0],
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text('Rp ${h.amount} · ${h.toName}'),
                  subtitle: Text(
                    '${h.bank} · ${h.toAccount}\n$timeStr',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    // detail riwayat (mock)
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (ctx) => Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
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
                            const SizedBox(height: 12),
                            const Text(
                              'Detail Transfer',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _TransferDetailRow(
                              label: 'ID Transaksi',
                              value: h.id,
                            ),
                            const SizedBox(height: 4),
                            _TransferDetailRow(
                              label: 'Penerima',
                              value: h.toName,
                            ),
                            const SizedBox(height: 4),
                            _TransferDetailRow(
                              label: 'No. Rekening',
                              value: h.toAccount,
                            ),
                            const SizedBox(height: 4),
                            _TransferDetailRow(
                              label: 'Bank',
                              value: h.bank,
                            ),
                            const SizedBox(height: 4),
                            _TransferDetailRow(
                              label: 'Nominal',
                              value: 'Rp ${h.amount}',
                            ),
                            const SizedBox(height: 4),
                            _TransferDetailRow(
                              label: 'Catatan',
                              value: h.note.isEmpty ? '-' : h.note,
                            ),
                            const SizedBox(height: 4),
                            _TransferDetailRow(
                              label: 'Waktu',
                              value: timeStr,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Ulangi transfer (mock).'),
                                    ),
                                  );
                                },
                                child: const Text('Ulangi Transfer'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _TransferDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _TransferDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
 