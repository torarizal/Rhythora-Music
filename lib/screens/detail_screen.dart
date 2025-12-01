import 'dart:convert'; // Untuk JSON decode
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import HTTP
import 'package:rhythora/models/track_model.dart';
import 'package:rhythora/screens/player_screens.dart';

class TrackInfoScreen extends StatefulWidget {
  final Track track; 

  const TrackInfoScreen({super.key, required this.track});

  @override
  State<TrackInfoScreen> createState() => _TrackInfoScreenState();
}

class _TrackInfoScreenState extends State<TrackInfoScreen> {
  late Future<Map<String, dynamic>> _trackDetailFuture;

  @override
  void initState() {
    super.initState();
    _trackDetailFuture = _fetchTrackDetails();
  }

  // --- FUNGSI UNTUK MENDAPATKAN TOKEN DARI LINK ---
  Future<String> _getAccessToken() async {
    // GANTI string di bawah ini dengan Link/URL penghasil token Anda
    const String tokenUrl = "MASUKKAN_LINK_TOKEN_ANDA_DISINI"; 

    try {
      final response = await http.get(Uri.parse(tokenUrl));

      if (response.statusCode == 200) {
        // SKENARIO 1: Jika link mengembalikan JSON (misal: {"access_token": "..."})
        // Sesuaikan key 'access_token' dengan format JSON link Anda
        final data = jsonDecode(response.body);
        return data['access_token']; 

        // SKENARIO 2: Jika link LANGSUNG mengembalikan string token mentah (plain text)
        // Hapus kode Skenario 1 di atas, dan gunakan baris ini:
        // return response.body; 
      } else {
        debugPrint("Gagal mengambil token dari link. Status: ${response.statusCode}");
        return "";
      }
    } catch (e) {
      debugPrint("Error koneksi ke link token: $e");
      return "";
    }
  }

  // --- FETCH DATA DARI SPOTIFY API ---
  Future<Map<String, dynamic>> _fetchTrackDetails() async {
    try {
      final token = await _getAccessToken();
      
      // Cek jika token gagal diambil
      if (token.isEmpty) {
        throw Exception("Token tidak valid atau kosong.");
      }

      final headers = {'Authorization': 'Bearer $token'};

      // 1. Ambil Detail Lagu (Untuk Popularitas, Tanggal Rilis, ID Artis)
      final trackUrl = Uri.parse('https://api.spotify.com/v1/tracks/${widget.track.id}');
      final trackRes = await http.get(trackUrl, headers: headers);

      if (trackRes.statusCode != 200) {
        throw Exception('Gagal memuat lagu (Spotify API): ${trackRes.statusCode}');
      }
      final trackData = jsonDecode(trackRes.body);

      // Ambil ID Artis pertama untuk cari Genre
      final artistId = trackData['artists'][0]['id'];
      
      // 2. Ambil Detail Artis (Untuk Genre)
      final artistUrl = Uri.parse('https://api.spotify.com/v1/artists/$artistId');
      final artistRes = await http.get(artistUrl, headers: headers);
      
      List<String> genres = ["Music"];
      if (artistRes.statusCode == 200) {
        final artistData = jsonDecode(artistRes.body);
        // Ambil genre dan ubah huruf pertama jadi besar
        genres = (artistData['genres'] as List).map((g) => g.toString().capitalize()).toList();
      }

      // 3. Susun Data
      final releaseDate = trackData['album']['release_date'] ?? "Unknown";
      final popularity = trackData['popularity'] ?? 0;
      final albumName = trackData['album']['name'];
      final artistName = trackData['artists'][0]['name'];

      // 4. Buat Deskripsi Dinamis
      String dynamicDescription = 
          "'$albumName' adalah karya dari $artistName yang dirilis secara resmi pada $releaseDate. "
          "Lagu ini mendapatkan skor popularitas $popularity dari 100 di Spotify, "
          "menjadikannya salah satu track yang patut diperhitungkan dalam diskografi mereka.\n\n"
          "Dengan nuansa ${genres.isNotEmpty ? genres.first : 'khas'}, lagu ini menunjukkan karakteristik musik yang kuat. "
          "Dengarkan sekarang untuk merasakan energinya.";

      return {
        "description": dynamicDescription,
        "genre": genres.isNotEmpty ? genres.join(", ") : "Pop",
        "releaseDate": releaseDate,
        "label": "Spotify Music", 
        "popularity": popularity,
      };

    } catch (e) {
      debugPrint("Error fetching details: $e");
      // Fallback data jika API gagal / Token expired
      return {
        "description": "Gagal memuat detail dari Spotify. Pastikan koneksi internet lancar dan link token valid.\n\nError: $e",
        "genre": "Unknown",
        "releaseDate": "-",
        "label": "-",
        "popularity": 0
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageUrl = widget.track.albumImageUrl ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _trackDetailFuture,
        builder: (context, snapshot) {
          // 1. LOADING STATE
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(
              children: [
                // Tampilkan background blur saat loading agar tidak hitam polos
                Container(
                   decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                   ),
                   child: BackdropFilter(
                     filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                     child: Container(color: Colors.black.withOpacity(0.5)),
                   ),
                ),
                const Center(child: CircularProgressIndicator(color: Colors.white)),
              ],
            );
          }

          final details = snapshot.data ?? {};
          final description = details['description'] ?? "No description available.";
          final genreStr = details['genre'] ?? "Music";

          return Stack(
            children: [
              // --- BACKGROUND IMAGE (Blur) ---
              Container(
                height: size.height * 0.6,
                width: size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.5, 0.9],
                  ),
                ),
              ),

              // --- CONTENT ---
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: true,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                    expandedHeight: size.height * 0.45,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Hero(
                            tag: 'albumArt_${widget.track.name}',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))
                                ]
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Detail Teks
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.track.name,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.grey, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                widget.track.artistName,
                                style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              _InfoChip(text: widget.track.albumName ?? "Single", icon: Icons.album),
                              const SizedBox(width: 10),
                              _InfoChip(text: genreStr.split(',').first, icon: Icons.music_note),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _InfoChip(text: "Popularity: ${details['popularity']}%", icon: Icons.trending_up),
                              const SizedBox(width: 10),
                              _InfoChip(text: "Released: ${details['releaseDate']}", icon: Icons.calendar_today),
                            ],
                          ),


                          const SizedBox(height: 32),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 16),

                          const Text(
                            "ABOUT",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                          
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackDetailScreen(track: widget.track),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 10,
              shadowColor: const Color(0xFF1DB954).withOpacity(0.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, size: 30),
                SizedBox(width: 10),
                Text("LISTEN NOW", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget Kecil untuk Badge Info
class _InfoChip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _InfoChip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

// Extension Helper untuk Capitalize Genre
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}