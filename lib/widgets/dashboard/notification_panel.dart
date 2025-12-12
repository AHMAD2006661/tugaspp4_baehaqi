import 'package:flutter/material.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

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
                  "Notifikasi",
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
            ...List.generate(8, (i) {
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.black54,
                      ),
                    ),
                    title: Text(
                      i % 2 == 0 ? "Top up berhasil" : "Transfer masuk",
                    ),
                    subtitle: Text("Hari ini • ${8 + i}:00"),
                    trailing: Text(i % 2 == 0 ? "+Rp 50.000" : "-"),
                  ),
                  const Divider(height: 1),
                ],
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
