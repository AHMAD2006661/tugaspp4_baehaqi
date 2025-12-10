import 'package:flutter/material.dart';

class CreditCardWidget extends StatelessWidget {
  final String owner;
  final String type;
  final String number;
  final String balance;
  final Color colorA;
  final Color colorB;

  const CreditCardWidget({
    super.key,
    required this.owner,
    required this.type,
    required this.number,
    required this.balance,
    this.colorA = const Color(0xFF3B82F6),
    this.colorB = const Color(0xFF8B5CF6),
  });

  String get formattedNumber {
    final digits = number.replaceAll(' ', '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buf.write(digits[i]);
      if ((i + 1) % 4 == 0 && i != digits.length - 1) buf.write(' ');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.88;
    final height = width * 0.62;

    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorA, colorB],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CHIP + NETWORK LOGO
              Row(
                children: [
                  Container(
                    width: width * 0.14,
                    height: width * 0.10,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.credit_card, color: Colors.white, size: 36),
                ],
              ),

              const Spacer(),

              // CARD NUMBER
              Text(
                formattedNumber,
                style: TextStyle(
                  fontSize: width * 0.075,
                  color: Colors.white,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: height * 0.06),

              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CARDHOLDER",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: width * 0.03,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        owner,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        type,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: width * 0.03,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        balance,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
