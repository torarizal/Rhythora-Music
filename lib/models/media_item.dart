import 'package:equatable/equatable.dart';

/// Kelas dasar abstrak untuk semua item media di aplikasi.
///
/// Menerapkan [Inheritance] karena kelas lain seperti [Track], [Playlist],
/// dan [Artist] akan mewarisi properti dasarnya.
///
/// Menerapkan [Encapsulation] dengan membuat properti menjadi private (_)
/// dan hanya menyediakan akses baca melalui public getter.
abstract class MediaItem extends Equatable {
  final String _id;
  final String _name;

  const MediaItem({
    required String id,
    required String name,
  })  : _id = id,
        _name = name;

  /// Getter untuk mengakses ID item.
  String get id => _id;

  /// Getter untuk mengakses nama item.
  String get name => _name;

  /// Metode yang akan di-override oleh subclass untuk menampilkan detail.
  /// Ini adalah contoh [Polymorphism].
  String displayDetails();

  @override
  List<Object?> get props => [id, name];
}
