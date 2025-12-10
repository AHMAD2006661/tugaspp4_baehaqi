import 'package:flutter/material.dart';

class CreditCardWidget extends StatelessWidget {
  final String owner;
  final String type;
  final String number;
  final String balance;
  final String expiry;
  final String bank;

  const CreditCardWidget({
    super.key,
    required this.owner,
    required this.type,
    required this.number,
    required this.balance,
    required this.expiry,
    required this.bank, required Color colorA, required Color colorB,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;    // width kartu
        final h = w * 0.62;      // tinggi proporsional (visa/mastercard ratio)
        final text = w * 0.045;  // ukuran teks responsif

        return Container(
          width: w,
          height: h,
          padding: EdgeInsets.all(w * 0.06),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(w * 0.06),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BANK
              Text(
                bank,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: text * 0.9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.03),

              // CHIP
              Icon(
                Icons.credit_card,
                size: w * 0.12,
                color: Colors.white70,
              ),
              const Spacer(),

              // NUMBER
              Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: text * 1.05,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: h * 0.02),

              // OWNER + EXPIRY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    owner,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    expiry,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: text * 0.9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
