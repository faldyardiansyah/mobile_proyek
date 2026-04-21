import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // KONTEN UTAMA (SCROLLABLE)
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Header
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      // Gunakan direct link ke gambar (contoh menggunakan placeholder)
                      image: NetworkImage('https://picsum.photos/800/1200'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "PUTRI ONLY",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange, size: 20),
                              Text(" 4.8", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(" (128 Ulasan)", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 15),
                      const Text("Kost Eksklusif Green Garden", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const Text("Jakarta Selatan", style: TextStyle(color: Colors.grey)),

                      const SizedBox(height: 25),
                      const Text("Ketersediaan Kamar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 15),
                      
                      // Grid Kamar
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          bool isTersedia = index != 1 && index != 3; 
                          return Container(
                            decoration: BoxDecoration(
                              color: isTersedia ? Colors.blue.withOpacity(0.05) : Colors.grey[100],
                              border: Border.all(color: isTersedia ? Colors.blue : Colors.transparent),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("A${index + 1}", 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: isTersedia ? Colors.blue : Colors.grey
                                  )
                                ),
                                Text(isTersedia ? "Tersedia" : "Terisi", 
                                  style: TextStyle(
                                    fontSize: 10, 
                                    color: isTersedia ? Colors.blue : Colors.grey
                                  )
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 100), // Spacer bawah
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}