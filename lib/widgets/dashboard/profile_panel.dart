import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFBE29EC);

/// ================== BOTTOM SHEET PROFIL ==================
class ProfilePanel extends StatelessWidget {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(left: w * 0.05, right: w * 0.05, top: 12),
        child: ListView(
          children: [
            // drag handle
            Center(
              child: Container(
                width: w * 0.18,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // title + close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Profil Saya",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: w * 0.07),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // avatar
            Center(
              child: CircleAvatar(
                radius: w * 0.13,
                backgroundImage:
                    const NetworkImage("https://i.pravatar.cc/300"),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                "Jack Michael",
                style: TextStyle(
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "jackmichael@gmail.com",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 20),

            const ListTile(
              leading: Icon(Icons.phone_android),
              title: Text("Nomor HP"),
              subtitle: Text("+62 812-4567-8990"),
            ),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text("Email"),
              subtitle: Text("jackmichael@gmail.com"),
            ),
            const ListTile(
              leading: Icon(Icons.location_on),
              title: Text("Alamat"),
              subtitle: Text("Jakarta, Indonesia"),
            ),
            const SizedBox(height: 16),

            // tombol Edit Profil (INTERAKTIF)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // buka halaman EditProfilePage seperti app DANA
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfilePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: w * 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Edit Profil",
                  style: TextStyle(
                    color: Colors.white, // teks putih biar jelas
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                // contoh: kembali ke root (misal halaman login)
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// ================== HALAMAN EDIT PROFIL FULLSCREEN ==================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameCtrl =
      TextEditingController(text: "Jack Michael");
  final TextEditingController _emailCtrl =
      TextEditingController(text: "jackmichael@gmail.com");
  final TextEditingController _phoneCtrl =
      TextEditingController(text: "+62 812-4567-8990");
  final TextEditingController _addressCtrl =
      TextEditingController(text: "Jakarta, Indonesia");

  final _formKey = GlobalKey<FormState>();

  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    // simulasi call API
    await Future.delayed(const Duration(milliseconds: 900));

    setState(() => _saving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil diperbarui (mock).")),
    );

    Navigator.pop(context);
  }

  Widget _buildProfileAvatar(double size) {
    return Stack(
      children: [
        CircleAvatar(
          radius: size,
          backgroundImage: const NetworkImage("https://i.pravatar.cc/300"),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: () {
              // TODO: buka picker foto
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Ganti foto profil (mock)."),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Edit Profil",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // avatar
            Center(child: _buildProfileAvatar(w * 0.17)),
            const SizedBox(height: 8),
            const Text(
              "Ubah data profil Anda",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // form
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration:
                            _fieldDecoration("Nama Lengkap"),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Nama tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration("Nomor HP"),
                        validator: (v) {
                          final text = v?.trim() ?? "";
                          if (text.isEmpty) {
                            return "Nomor HP tidak boleh kosong";
                          }
                          if (text.replaceAll(RegExp(r'[^0-9]'), '').length <
                              9) {
                            return "Nomor HP terlalu pendek";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration("Email"),
                        validator: (v) {
                          final text = v?.trim() ?? "";
                          if (text.isEmpty) {
                            return "Email tidak boleh kosong";
                          }
                          final emailReg =
                              RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailReg.hasMatch(text)) {
                            return "Format email tidak valid";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _addressCtrl,
                        textInputAction: TextInputAction.done,
                        maxLines: 2,
                        decoration:
                            _fieldDecoration("Alamat", hint: "Alamat domisili"),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // tombol simpan
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    disabledBackgroundColor:
                        kPrimaryColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Simpan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
