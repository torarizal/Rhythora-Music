import 'package:flutter/material.dart';
import 'package:rhythora/models/track_model.dart';

class TrackDetailScreen extends StatelessWidget {
  final Track track;

  const TrackDetailScreen({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
      ),
    ),

      // ============================
      //        BAGIAN ATAS
      // ============================
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 40),



            // --- Gambar Album ---
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                track.albumImageUrl ?? "",
                height: 260,
                width: 260,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 260,
                  width: 260,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.music_note, color: Colors.white, size: 60),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Judul Lagu ---
            Text(
              track.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // --- Artist ---
            Text(
              track.artistName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 20),

            // --- Progress Bar Dummy ---
            Slider(
              value: 20,
              min: 0,
              max: 100,
              onChanged: (v) {},
              activeColor: Colors.white,
              inactiveColor: Colors.white30,
            ),

            const SizedBox(height: 8),

            // --- Waktu dummy ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("0:20", style: TextStyle(color: Colors.white54)),
                Text("3:00", style: TextStyle(color: Colors.white54)),
              ],
            ),

            const Spacer(),
          ],
        ),
      ),

      // ============================
      //        KONTROL DI BAWAH
      // ============================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white, size: 34),
              onPressed: () {},
            ),

            const SizedBox(width: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.black, size: 32),
            ),

            const SizedBox(width: 24),

            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 34),
              onPressed: () {},
            ),

            
          

          ],
        ),
      ),
    );
  }
}
