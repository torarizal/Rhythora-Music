// home_screen.dart
import 'dart:ui'; // Diperlukan untuk ImageFilter.blur
import 'package:flutter/material.dart';

// --- DEFINISI WARNA (Meniru Tailwind) ---
const Color kBackgroundColor = Color(0xFF111827); // gray-900
const Color kCardColor = Color(0xFF1F2937); // gray-800
const Color kFooterColor = Color(0xFF030712); // gray-950
const Color kPrimaryRed = Color(0xFFDC2626); // red-600
const Color kPrimaryRedHover = Color(0xFFB91C1C); // red-700
const Color kPrimaryText = Color(0xFFF9FAFB); // gray-100
const Color kSecondaryText = Color(0xFF9CA3AF); // gray-400

// --- MODEL DATA (untuk menampung data dari API Anda) ---
class Movie {
  final String id;
  final String title;
  final String year;
  final double rating;
  final String posterUrl;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.posterUrl,
  });
}

// --- DATA DUMMY (Ganti ini dengan panggilan API Anda) ---
final Movie dummyHeroMovie = Movie(
  id: "1",
  title: "Judul Film Unggulan dari API",
  year: "2025",
  rating: 9.0,
  posterUrl: "https://placehold.co/1600x900/2c2c2c/FFF?text=Hero+dari+API",
);

final List<Movie> dummyNowPlaying = [
  Movie(
    id: "2",
    title: "Film Tayang Satu",
    year: "2025",
    rating: 9.1,
    posterUrl: "https://placehold.co/300x450/2a2a2a/FFF?text=API+1",
  ),
  Movie(
    id: "3",
    title: "Film Tayang Dua",
    year: "2025",
    rating: 8.5,
    posterUrl: "https://placehold.co/300x450/3a3a3a/FFF?text=API+2",
  ),
  Movie(
    id: "4",
    title: "Film Tayang Tiga",
    year: "2025",
    rating: 8.2,
    posterUrl: "https://placehold.co/300x450/4a4a4a/FFF?text=API+3",
  ),
  Movie(
    id: "5",
    title: "Film Tayang Empat",
    year: "2025",
    rating: 8.0,
    posterUrl: "https://placehold.co/300x450/5a5a5a/FFF?text=API+4",
  ),
  Movie(
    id: "6",
    title: "Film Tayang Lima",
    year: "2024",
    rating: 7.9,
    posterUrl: "https://placehold.co/300x450/6a6a6a/FFF?text=API+5",
  ),
  Movie(
    id: "7",
    title: "Film Tayang Enam",
    year: "2024",
    rating: 7.8,
    posterUrl: "https://placehold.co/300x450/7a7a7a/FFF?text=API+6",
  ),
];

final List<Movie> dummyPopular = [
  Movie(
    id: "8",
    title: "Film Populer Satu",
    year: "2024",
    rating: 9.8,
    posterUrl: "https://placehold.co/300x450/8a8a8a/FFF?text=API+7",
  ),
  Movie(
    id: "9",
    title: "Film Populer Dua",
    year: "2023",
    rating: 9.5,
    posterUrl: "https://placehold.co/300x450/9a9a9a/FFF?text=API+8",
  ),
  Movie(
    id: "10",
    title: "Film Populer Tiga",
    year: "2023",
    rating: 9.2,
    posterUrl: "https://placehold.co/300x450/aaaaaa/FFF?text=API+9",
  ),
];

// --- WIDGET UTAMA (HOME SCREEN) ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // endDrawer digunakan untuk menu mobile
      endDrawer: _buildMobileDrawer(),
      body: Stack(
        children: [
          // 1. Konten Utama (Bisa di-scroll)
          _buildContent(),

          // 2. App Bar (Efek blur saat scroll)
          _buildBlurredAppBar(),
        ],
      ),
    );
  }

  // --- WIDGET APP BAR DENGAN EFEK "WOW" ---
  Widget _buildBlurredAppBar() {
    // Tentukan opasitas berdasarkan seberapa jauh di-scroll
    // Akan full opacity setelah scroll 100 pixels
    double opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          // Efek blur (mirip backdrop-blur-md)
          filter: ImageFilter.blur(sigmaX: opacity * 10, sigmaY: opacity * 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            // Latar belakang (mirip bg-gray-900/80)
            color: kBackgroundColor.withOpacity(opacity * 0.8),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Cek lebar layar untuk layout responsif
                  if (constraints.maxWidth > 768) {
                    return _buildDesktopNav(); // Tampilan Desktop
                  } else {
                    return _buildMobileNav(); // Tampilan Mobile
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Navigasi versi Desktop (mirip md:flex)
  Widget _buildDesktopNav() {
    return Row(
      children: [
        const Text(
          "MOVIELIX",
          style: TextStyle(
            color: kPrimaryRed,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 40),
        _buildNavButton("Beranda", isActive: true),
        _buildNavButton("Film"),
        _buildNavButton("Acara TV"),
        _buildNavButton("Genre"),
        const Spacer(),
        SizedBox(width: 250, child: _buildSearchBar()),
      ],
    );
  }

  // Navigasi versi Mobile (mirip md:hidden)
  Widget _buildMobileNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "MOVIELIX",
          style: TextStyle(
            color: kPrimaryRed,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        // Tombol hamburger untuk membuka drawer
        IconButton(
          icon: const Icon(Icons.menu, color: kPrimaryText, size: 28),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
        ),
      ],
    );
  }

  // Tombol navigasi untuk desktop
  Widget _buildNavButton(String text, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? kPrimaryText : kSecondaryText,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  // Search bar
  Widget _buildSearchBar() {
    return TextField(
      style: const TextStyle(color: kPrimaryText, fontSize: 14),
      decoration: InputDecoration(
        hintText: "Cari film...",
        hintStyle: const TextStyle(color: kSecondaryText, fontSize: 14),
        filled: true,
        fillColor: kCardColor,
        prefixIcon: const Icon(Icons.search, color: kSecondaryText, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kPrimaryRed, width: 2),
        ),
      ),
    );
  }

  // Drawer untuk menu mobile
  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: kBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 40),
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildDrawerItem("Beranda", Icons.home, isActive: true),
          _buildDrawerItem("Film", Icons.movie),
          _buildDrawerItem("Acara TV", Icons.tv),
          _buildDrawerItem("Genre", Icons.category),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    String title,
    IconData icon, {
    bool isActive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isActive ? kPrimaryRed : kSecondaryText),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? kPrimaryText : kSecondaryText,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Tutup drawer
      },
    );
  }

  // --- WIDGET KONTEN UTAMA ---
  Widget _buildContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 1. Hero Section
        SliverToBoxAdapter(child: _buildHeroSection()),

        // 2. Section "Sedang Tayang"
        SliverToBoxAdapter(child: _buildSectionTitle("Sedang Tayang")),
        _buildMovieGrid(dummyNowPlaying),

        // 3. Section "Paling Populer"
        SliverToBoxAdapter(child: _buildSectionTitle("Paling Populer")),
        _buildMovieGrid(dummyPopular),

        // 4. Footer
        SliverToBoxAdapter(child: _buildFooter()),
      ],
    );
  }

  // --- Bagian Hero ---
  Widget _buildHeroSection() {
    return AspectRatio(
      aspectRatio: 16 / 8, // Rasio gambar hero
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gambar Latar
          Image.network(
            dummyHeroMovie.posterUrl,
            fit: BoxFit.cover,
            // Tampilkan loading spinner saat gambar dimuat
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: kPrimaryRed),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: kCardColor,
                child: const Center(
                  child: Icon(Icons.error, color: kSecondaryText),
                ),
              );
            },
          ),

          // Overlay Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [kBackgroundColor, kBackgroundColor.withOpacity(0.0)],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [kBackgroundColor, kBackgroundColor.withOpacity(0.0)],
                stops: const [0.0, 0.5],
              ),
            ),
          ),

          // Konten Teks Hero
          Positioned(
            bottom: 40,
            left: 40,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "BARU RILIS",
                    style: TextStyle(
                      color: kPrimaryRed,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dummyHeroMovie.title,
                    style: const TextStyle(
                      color: kPrimaryText,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Deskripsi film ini diambil dari API, menceritakan premis yang sangat menarik dan penuh aksi.",
                    style: TextStyle(
                      color: kSecondaryText,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow, color: kPrimaryText),
                    label: const Text("Tonton Sekarang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryRed, // <-- Ini gantinya primary
                      foregroundColor:
                          kPrimaryText, // <-- Ini gantinya onPrimary
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Judul Section (misal: "Sedang Tayang") ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 20.0),
      child: Row(
        children: [
          // Aksen garis merah (border-l-4)
          Container(
            width: 5,
            height: 28,
            color: kPrimaryRed,
            margin: const EdgeInsets.only(right: 12),
          ),
          Text(
            title,
            style: const TextStyle(
              color: kPrimaryText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Grid Daftar Film ---
  Widget _buildMovieGrid(List<Movie> movies) {
    // SliverPadding agar ada jarak di sisi grid
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      sliver: SliverGrid(
        // GridView yang responsif (mirip grid-cols-2 sm:grid-cols-3 ...)
        delegate: SliverChildBuilderDelegate((context, index) {
          return _MovieCard(movie: movies[index]);
        }, childCount: movies.length),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // Lebar maks setiap item
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 2 / 3.5, // Rasio (width/height) kartu
        ),
      ),
    );
  }

  // --- Footer ---
  Widget _buildFooter() {
    return Container(
      color: kFooterColor,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      margin: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          const Text(
            "MOVIELIX",
            style: TextStyle(
              color: kPrimaryRed,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink("Tentang Kami"),
              _buildFooterLink("FAQ"),
              _buildFooterLink("Kebijakan Privasi"),
              _buildFooterLink("Kontak"),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(
                Icons.facebook,
              ), // Ganti dengan ikon brand jika perlu
              _buildSocialIcon(Icons.camera_alt), // Ganti dengan Twitter
              _buildSocialIcon(Icons.camera), // Ganti dengan Instagram
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "© 2025 Movielix. Semua Hak Cipta Dilindungi.",
            style: TextStyle(color: kSecondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        text,
        style: const TextStyle(color: kSecondaryText, fontSize: 14),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Icon(icon, color: kSecondaryText, size: 24),
    );
  }
}

// --- WIDGET KARTU FILM (Stateful untuk efek hover) ---
class _MovieCard extends StatefulWidget {
  final Movie movie;
  const _MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  __MovieCardState createState() => __MovieCardState();
}

class __MovieCardState extends State<_MovieCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // AnimatedContainer untuk transisi scale dan shadow
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      // Efek scale (hover:scale-[1.03])
      transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(8),
        // Efek shadow (hover:shadow-2xl hover:shadow-red-600/40)
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: kPrimaryRed.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: () {
            // Nanti navigasi ke halaman detail
            // Navigator.push(context, MaterialPageRoute(builder: ...));
            print("Tapped on ${widget.movie.title}");
          },
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Film (aspect-[2/3])
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Image.network(
                    widget.movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: kBackgroundColor,
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            color: kSecondaryText,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Info Teks
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movie.title,
                      style: const TextStyle(
                        color: kPrimaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          widget.movie.year,
                          style: const TextStyle(
                            color: kSecondaryText,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          widget.movie.rating.toString(),
                          style: const TextStyle(
                            color: kSecondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
