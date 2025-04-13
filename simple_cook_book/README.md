# Simple Cookbook - Aplikasi Resep Masakan Offline dengan Flutter & Hive

## Tentang Aplikasi Ini

Ini adalah aplikasi Simple Cookbook yang saya buat sebagai proyek pertama yang menggunakan Database saat belajar Flutter. Aplikasi ini menggunakan database lokal bernama Hive untuk menyimpan resep-resep masakan tanpa perlu internet.

#### 1. Database & Penyimpanan Data

**Hive di Flutter:**
Hive itu seperti kotak penyimpanan yang ada di HP kita sendiri. Kita tinggal buka, ambil atau simpan data langsung tanpa perlu terhubung ke internet.

**Database di Website:**
Kalau di website, database itu seperti gudang di tempat yang jauh. Setiap mau ambil atau simpan data, kita harus telepon dulu ke gudang itu (lewat API).

#### 2. Cara Membuat Model Data

**Hive di Flutter:**
Di Hive, kita tinggal kasih label (seperti stiker) di data kita pakai @HiveType dan @HiveField.

**Database Website:**
Di website, kita harus bikin struktur tabel dulu, tentuin kolom-kolomnya, terus pasang relasi antar tabel.

#### 3. Cara Akses Database

**Hive di Flutter:**
Pakai Hive itu kayak buka laci sendiri - tinggal buka, ambil, tutup. 

**Database Website:**
Di website, kita harus login ke server dulu, kirim requst, dan tunggu balasan.

## Alur Pembuatan website

### 1. Tambah Package di pubspec.yaml

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1

dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.3.3
```

### 2. Bikin Model dengan Anotasi Hive

```dart
@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late List<String> ingredients;

  @HiveField(3)
  late List<String> steps;
  
  @HiveField(4)
  String? imagePath;
  
  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    this.imagePath,
  });
}
```

### 3. Generate File Adapter

Pada terminal, jalankan:

```bash
flutter pub run build_runner build
```

Nanti Flutter bakal bikin file `recipe.g.dart` sendiri.

### 4. Inisialisasi Hive di main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Siapkan Hive
  await Hive.initFlutter();
  
  // Daftarkan adapter
  Hive.registerAdapter(RecipeAdapter());
  
  // Buka kotak resep
  await Hive.openBox<Recipe>('recipes');
  
  runApp(const MyApp());
}
```

### 5. Cara CRUD dengan Hive (Create, Read, Update, Delete)

#### Tambah Resep (Create)
```dart
// Bikin resep baru
final newRecipe = Recipe(
  id: 'recipe_${DateTime.now().millisecondsSinceEpoch}',
  title: 'Nasi Goreng',
  ingredients: ['Nasi', 'Telur', 'Kecap'],
  steps: ['Panaskan minyak', 'Tumis bumbu', 'Masukkan nasi']
);

// Simpan ke box
final recipeBox = Hive.box<Recipe>('recipes');
recipeBox.add(newRecipe);
```

#### Lihat Resep (Read)
```dart
// Lihat semua resep
final recipes = recipeBox.values.toList();

// Lihat satu resep
final recipe = recipeBox.getAt(index);
```

#### Update Resep
```dart
// Ubah resep
recipe.title = 'Nasi Goreng Spesial';
recipe.save(); // Simpan perubahan
```

#### Hapus Resep (Delete)
```dart
// Hapus resep
recipe.delete();
```

## Widget yang dipakai

- **Scaffold**: Sebagai frame halaman
- **AppBar**: Bagian atas aplikasi
- **ListView.builder**: Daftar yang bisa di-scroll
- **Form & TextFormField**: Untuk isian form
- **ValueListenableBuilder**: Widget yang secara otomatis memperbarui tampilan ketika ada perubahan data di Hive

## Cara Jalankan Proyek Ini

1. Clone repository ini
2. Jalankan `flutter pub get` untuk install dependencies
3. Jalankan `flutter pub run build_runner build` untuk generate kode adapter
4. Jalankan aplikasi dengan `flutter run`

