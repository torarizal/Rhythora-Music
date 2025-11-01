// File: lib/services/html_stub.dart
// Ini adalah file 'pengganti' (stub) yang BENAR untuk 'dart:html'
// agar tidak error saat di-compile untuk mobile (Android/iOS).

// Definisikan 'window' sebagai getter top-level,
// sama seperti 'dart:html' yang asli.
Window get window => Window();

// Definisikan class-class palsu yang kita butuhkan
class Window {
  Stream<MessageEvent> get onMessage => Stream.empty();
  String get origin => '';
  void open(String url, String name, String options) {
    // Implementasi kosong
  }
}

class MessageEvent {
  String get origin => '';
  dynamic get data => '';
}

