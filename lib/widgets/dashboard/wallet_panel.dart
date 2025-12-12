import 'package:flutter/material.dart';

class WalletPanel extends StatelessWidget {
  const WalletPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(left: w * 0.04, right: w * 0.04, top: 12),
        child: ListView(
          children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dompet",
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
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                color: const Color(0xFFBE29EC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Saldo",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: w * 0.035,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rp 12.580.000",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: w * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_downward),
                        label: const Text("Top Up"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFBE29EC),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_upward),
                        label: const Text("Tarik"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Riwayat Transaksi",
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(6, (i) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Colors.black54,
                  ),
                ),
                title: Text("Pembayaran #${i + 1}"),
                subtitle: const Text("Sukses • 12 Nov 2025"),
                trailing: Text(
                  i % 2 == 0 ? "-Rp 150.000" : "+Rp 50.000",
                  style: TextStyle(
                    color: i % 2 == 0 ? Colors.red : Colors.green,
                  ),
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
