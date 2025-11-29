import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'transfer_screen.dart';

import 'generic_menu_page.dart';
import '../widgets/dashboard/menu_item.dart';
import '../widgets/dashboard/wallet_panel.dart';
import '../widgets/dashboard/profile_panel.dart';
import '../widgets/dashboard/notification_panel.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.88);

  int _currentCard = 0;
  late final AnimationController _flipController1;
  late final AnimationController _flipController2;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();

    _flipController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pageController.addListener(() {
      final page = _pageController.page ?? 0;
      final idx = page.round();
      if (idx != _currentCard) setState(() => _currentCard = idx);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flipController1.dispose();
    _flipController2.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _showBlurPanel(Widget panel) {
    return showGeneralDialog(
      context: context,
      barrierLabel: "panel",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, a1, a2, child) {
        final curved = Curves.easeOut.transform(a1.value);

        return Stack(
          children: [
            Opacity(
              opacity: curved,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 8 * curved,
                  sigmaY: 8 * curved,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.12 * curved),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -50 + (1 - curved) * 300,
              child: Transform.translate(
                offset: Offset(0, (1 - curved) * 40),
                child: Opacity(
                  opacity: curved,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.88,
                    child: Material(
                      color: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                        child: Container(
                          color: Colors.white,
                          child: panel,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleFlip(int index) {
    final ctrl = (index == 0) ? _flipController1 : _flipController2;
    if (ctrl.status == AnimationStatus.completed || ctrl.value > 0.5) {
      ctrl.reverse();
    } else {
      ctrl.forward();
    }
  }

  Widget _buildFlipCard({
    required AnimationController ctrl,
    required Widget front,
    required Widget back,
  }) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final value = ctrl.value;
        final angle = value * pi;
        final isFront = value < 0.5;

        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: isFront
              ? front
              : Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: back,
                ),
        );
      },
    );
  }

  Widget _badge(String text, double size) {
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final card1Front = _cardFront(
      owner: "Jack Michael",
      type: "Amazon Platinum",
      number: "4756 1234 5678 9018",
      balance: "\$3,469.52",
      colorA: const Color(0xFF0D47A1),
      colorB: const Color(0xFF1976D2),
    );

    final card1Back = _cardBack(
      cvv: "921",
      valid: "02/30",
      colorA: const Color(0xFF0D47A1),
      colorB: const Color(0xFF1976D2),
    );

    final card2Front = _cardFront(
      owner: "John Paul",
      type: "Netflix Prime",
      number: "4920 8888 2345 1120",
      balance: "\$2,110.00",
      colorA: const Color(0xFF1B1B2F),
      colorB: const Color(0xFF3A3A6A),
    );

    final card2Back = _cardBack(
      cvv: "512",
      valid: "11/30",
      colorA: const Color(0xFF1B1B2F),
      colorB: const Color(0xFF3A3A6A),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFBE29EC),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.05,
                vertical: h * 0.018,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showBlurPanel(const ProfilePanel()),
                    child: Hero(
                      tag: 'profile_avatar',
                      child: CircleAvatar(
                        radius: w * 0.065,
                        backgroundImage: const NetworkImage("https://i.pravatar.cc/300"),
                      ),
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: Text(
                      "Hai, Jack Michael",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showBlurPanel(const NotificationPanel()),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: w * 0.075,
                          color: Colors.white,
                        ),
                        Positioned(
                          right: -2,
                          top: -6,
                          child: _badge("3", w * 0.045),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // BODY PUTIH
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: h * 0.035,
                    bottom: h * 0.03,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFDFD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(w * 0.09),
                      topRight: Radius.circular(w * 0.09),
                    ),
                  ),
                  child: Column(
                    children: [
                      // CARD CAROUSEL
                      SizedBox(
                        height: h * 0.26,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            final ctrl = (index == 0) ? _flipController1 : _flipController2;
                            final front = (index == 0) ? card1Front : card2Front;
                            final back = (index == 0) ? card1Back : card2Back;

                            return Transform.scale(
                              scale: index == _currentCard ? 1.0 : 0.94,
                              child: GestureDetector(
                                onTap: () => _toggleFlip(index),
                                child: _buildFlipCard(
                                  ctrl: ctrl,
                                  front: front,
                                  back: back,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(_currentCard == 0, w),
                          const SizedBox(width: 8),
                          _dot(_currentCard == 1, w),
                        ],
                      ),

                      SizedBox(height: h * 0.03),

                      // QUICK ACTION
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _quickAction(
                              w,
                              Icons.send,
                              'Kirim',
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GenericMenuPage(title: 'Kirim Uang'),
                                ),
                              ),
                            ),
                            _quickAction(
                              w,
                              Icons.request_page,
                              'Minta',
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GenericMenuPage(title: 'Minta'),
                                ),
                              ),
                            ),
                            _quickAction(w, Icons.qr_code, 'Scan', _onScanPressed),
                            _quickAction(
                              w,
                              Icons.wallet,
                              'Dompet',
                              () => _showBlurPanel(const WalletPanel()),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h * 0.035),

                      // GRID MENU
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: w * 0.045),
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          childAspectRatio: 0.88,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: w * 0.045,
                          mainAxisSpacing: w * 0.045,
                          children: const [
                            DashboardMenuItem(
                              icon: Icons.credit_card,
                              label: "Akun & Kartu",
                              page: GenericMenuPage(title: "Akun & Kartu"),
                            ),
                            DashboardMenuItem(
                              icon: Icons.swap_horiz,
                              label: "Transfer",
                              page: TransferScreen(),
                            ),
                            DashboardMenuItem(
                              icon: Icons.local_atm,
                              label: "Tarik Tunai",
                              page: GenericMenuPage(title: "Tarik Tunai"),
                            ),
                            DashboardMenuItem(
                              icon: Icons.phone_android,
                              label: "Pulsa Seluler",
                              page: GenericMenuPage(title: "Pulsa Seluler"),
                            ),
                            DashboardMenuItem(
                              icon: Icons.receipt_long,
                              label: "Bayar Tagihan",
                              page: GenericMenuPage(title: "Bayar Tagihan"),
                            ),
                            DashboardMenuItem(
                              icon: Icons.account_balance,
                              label: "Tabungan",
                              page: GenericMenuPage(title: "Tabungan"),
                            ),
                            DashboardMenuItem(
                              icon: Icons.credit_score,
                              label: "Kartu Kredit",
                              page: GenericMenuPage(title: "Kartu Kredit"),
                            ),
                            DashboardMenuItem(
                              icon: Icons.history,
                              label: "Riwayat",
                              page: GenericMenuPage(title: "Riwayat Transaksi"),
                            ),
                            DashboardMenuItem(
                              icon: Icons.person,
                              label: "Penerima",
                              page: GenericMenuPage(title: "Daftar Penerima"),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h * 0.12),
                    ],
                  ),
                ),
              ),
            ),

            // NAV BAWAH + SCAN BUTTON
            SizedBox(
              height: h * 0.105,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    top: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 22),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _navItem(Icons.home, 'Home', true, () {}),
                            _navItem(
                              Icons.history,
                              'Transaksi',
                              false,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GenericMenuPage(title: 'Transaksi'),
                                ),
                              ),
                            ),
                            SizedBox(width: w * 0.20),
                            _navItem(
                              Icons.account_balance_wallet,
                              'Dompet',
                              false,
                              () => _showBlurPanel(const WalletPanel()),
                            ),
                            _navItem(
                              Icons.person,
                              'Profil',
                              false,
                              () => _showBlurPanel(const ProfilePanel()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: -18,
                    left: (w / 2) - (w * 0.12),
                    child: GestureDetector(
                      onTap: _onScanPressed,
                      child: AnimatedBuilder(
                        animation: _glowCtrl,
                        builder: (_, __) {
                          final glow = 6 + (_glowCtrl.value * 6);

                          return Container(
                            width: w * 0.24,
                            height: w * 0.24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF9ECF),
                                  Color(0xFFBE29EC),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withOpacity(0.18),
                                  blurRadius: glow,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: w * 0.13,
                                height: w * 0.13,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.qr_code_scanner,
                                  color: Color(0xFFBE29EC),
                                  size: w * 0.07,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active, double w) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: active ? 18 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFBE29EC) : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _cardFront({
    required String owner,
    required String type,
    required String number,
    required String balance,
    required Color colorA,
    required Color colorB,
  }) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(w * 0.055),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [colorA, colorB]),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            owner,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            type,
            style: const TextStyle(color: Colors.white70),
          ),
          const Spacer(),
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardBack({
    required String cvv,
    required String valid,
    required Color colorA,
    required Color colorB,
  }) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(w * 0.055),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colorA.withOpacity(0.92),
            colorB.withOpacity(0.92),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 36, color: Colors.black54),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "CVV",
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                cvv,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Valid Thru",
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            valid,
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          const Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "VISA",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    double w,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: w * 0.15,
            height: w * 0.15,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(w * 0.04),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: w * 0.07,
              color: const Color(0xFFBE29EC),
            ),
          ),
          SizedBox(height: w * 0.02),
          Text(
            label,
            style: TextStyle(fontSize: w * 0.028),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: w * 0.06,
            color: active ? const Color(0xFFBE29EC) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFFBE29EC) : Colors.grey,
              fontSize: w * 0.03,
            ),
          ),
        ],
      ),
    );
  }

  void _onScanPressed() {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Scan QR (mock) — membuka scanner...'),
      ),
    );
  }
}
