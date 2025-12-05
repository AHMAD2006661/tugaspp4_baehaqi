import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFB92DFF);

/// ================== PAGE 1 – REGISTER ==================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _agree = false;
  bool _obscurePassword = true;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorName;
  String? _errorPhone;
  String? _errorPass;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {
      _errorName = null;
      _errorPhone = null;
      _errorPass = null;
    });
  }

  bool get _isFormFilled =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty &&
      _agree;

  bool _validateForm() {
    bool ok = true;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();

    if (name.isEmpty) {
      _errorName = "Nama tidak boleh kosong";
      ok = false;
    }

    if (phone.isEmpty) {
      _errorPhone = "Nomor ponsel tidak boleh kosong";
      ok = false;
    } else {
      final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.length < 9) {
        _errorPhone = "Nomor ponsel terlalu pendek";
        ok = false;
      }
    }

    if (pass.isEmpty) {
      _errorPass = "Kata sandi tidak boleh kosong";
      ok = false;
    } else if (pass.length < 6) {
      _errorPass = "Minimal 6 karakter";
      ok = false;
    }

    if (!_agree) {
      ok = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Anda harus menyetujui Syarat & Ketentuan."),
        ),
      );
    }

    setState(() {});
    return ok;
  }

  void _onRegister() {
    if (!_validateForm()) return;

    final phone = _phoneController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyRegisterOtpPage(phoneNumber: phone),
      ),
    );
  }

  void _onTapTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Halaman Syarat & Ketentuan (mock)."),
      ),
    );
    // TODO: ganti dengan Navigator.push(...) ke halaman S&K kalau sudah ada.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // warna dasar di bawah gradient
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB92DFF), // ungu muda
              Color(0xFFB92DFF), // pink
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header atas (back + judul kecil "Daftar")
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Daftar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Card putih besar di bawah
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB92DFF),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Buat akun baru',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Ilustrasi bulat
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF9E9FF),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 70,
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: const Color(0xFFB92DFF),
                            ),
                            child: const Icon(
                              Icons.people_alt_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // TextField Nama
                        TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Nama Anda',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            errorText: _errorName,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // TextField Nomor
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Nomor Anda',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            errorText: _errorPhone,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // TextField Password
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: 'Buat Kata Sandi Anda',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            errorText: _errorPass,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // CheckboxListTile -> teks pas dengan kotak centang
                        CheckboxListTile(
                          value: _agree,
                          onChanged: (val) {
                            setState(() => _agree = val ?? false);
                          },
                          activeColor: kPrimaryColor,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'Dengan membuat akun, Anda menyetujui ',
                                ),
                                TextSpan(
                                  text: 'Syarat dan Ketentuan kami',
                                  style: const TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _onTapTerms,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tombol Daftar
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isFormFilled ? _onRegister : null,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              backgroundColor: kPrimaryColor,
                              disabledBackgroundColor:
                                   Color(0xFFBDBDBD),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Footer: Sudah punya akun? Masuk
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah punya akun? ',
                              style: TextStyle(fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: () {
                                // kembali ke halaman login
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================== PAGE 2 – VERIFIKASI OTP REGISTER ==================
class VerifyRegisterOtpPage extends StatefulWidget {
  final String phoneNumber;
  const VerifyRegisterOtpPage({super.key, required this.phoneNumber});

  @override
  State<VerifyRegisterOtpPage> createState() => _VerifyRegisterOtpPageState();
}

class _VerifyRegisterOtpPageState extends State<VerifyRegisterOtpPage> {
  final TextEditingController _codeController = TextEditingController();
  int _secondsLeft = 60;
  Timer? _timer;

  bool get _codeFilled => _codeController.text.trim().isNotEmpty;
  bool get _canResend => _secondsLeft == 0;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() {}));
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Kode verifikasi telah dikirim ulang (mock).")),
    );
    _startTimer();
  }

  void _onVerify() {
    if (!_codeFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan kode verifikasi terlebih dahulu.")),
      );
      return;
    }

    // TODO: verifikasi kode ke server
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterSuccessPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Column(
          children: [
            // Header sederhana
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Verifikasi Nomor",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Masukkan kode",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _codeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "",
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F5),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: _canResend ? _resendCode : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    disabledBackgroundColor:
                                        Color(0xFFBDBDBD),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),
                                  child: Text(
                                    _canResend
                                        ? "Kirim Ulang"
                                        : "Kirim ulang (${_secondsLeft}s)",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Kami telah mengirimkan kode untuk memverifikasi nomor ponsel Anda ${widget.phoneNumber}",
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Kode ini akan kadaluwarsa dalam 10 menit setelah pesan ini. Jika Anda tidak menerima pesan, coba kirim ulang.",
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _codeFilled ? _onVerify : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                disabledBackgroundColor:
                                    Color(0xFFBDBDBD),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text(
                                "Verifikasi & Selesai",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Kembali ke halaman sebelumnya (RegisterPage) untuk ganti nomor
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Ganti nomor ponsel Anda",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================== PAGE 3 – SUKSES DAFTAR ==================
class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const SizedBox(height: 40),
            // Ilustrasi sukses
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFCE4FF), Color(0xFFE1BEE7)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 90,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    "Akun berhasil dibuat!",
                    style: TextStyle(
                      fontSize: 20,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Selamat, akun Anda sudah aktif. Silakan masuk dan nikmati layanan kami.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Tombol ke halaman pertama (misalnya login / home)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    // Balik sampai root (misal: halaman login utama)
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Masuk Sekarang",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
