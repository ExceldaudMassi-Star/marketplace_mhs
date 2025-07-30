import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace_mhs/models/product_model.dart';
import 'package:marketplace_mhs/services/auth_service.dart';
import 'package:marketplace_mhs/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  File? _imageFile;
  XFile? _webImageFile;
  String? _selectedCategory;
  String? _selectedCondition;
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  // Ganti dengan API key imgbb kamu
  final String imgbbApiKey = '66f58583420703114f702b8547d186bd';

  void _showImageSourceActionSheet(BuildContext context) {
    if (kIsWeb) {
      _pickImage(ImageSource.gallery);
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _webImageFile = pickedFile;
        } else {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadToImgbb(File? file, XFile? webFile) async {
    try {
      List<int> imageBytes;
      if (kIsWeb && webFile != null) {
        imageBytes = await webFile.readAsBytes();
      } else if (file != null) {
        imageBytes = await file.readAsBytes();
      } else {
        return null;
      }
      String base64Image = base64Encode(imageBytes);
      final url = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');
      final response = await http.post(url, body: {'image': base64Image});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'];
      }
    } catch (_) {}
    return null;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        (_imageFile != null || _webImageFile != null) &&
        _selectedCategory != null &&
        _selectedCondition != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final user = authService.currentUser;

        if (user == null) throw Exception("User tidak ditemukan.");

        final imageUrl = await _uploadToImgbb(_imageFile, _webImageFile);
        if (imageUrl == null) throw Exception("Gagal mengunggah gambar.");

        final product = Product(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory!,
          condition: _selectedCondition!,
          location: _locationController.text.trim(),
          imageUrl: imageUrl,
          sellerId: user.uid,
          sellerName: user.displayName ?? "Pelajar",
          timestamp: Timestamp.now(),
        );

        await _firestoreService.addProduct(product);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil diposting!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (_imageFile == null && _webImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silahkan pilih foto produk.')),
      );
    } else if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silahkan pilih kategori produk.')),
      );
    } else if (_selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silahkan pilih kondisi barang.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📦 Jual Barang')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: (kIsWeb && _webImageFile != null)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _webImageFile!.path,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (_imageFile != null)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text("Tap untuk tambah foto"),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Produk',
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                      ),
                      items: [
                        'Fashion',
                        'Elektronik',
                        'Book',
                        'Equipment',
                        'Lainnya',
                      ]
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                      validator: (v) =>
                          v == null ? 'Kategori harus dipilih' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCondition,
                      decoration: const InputDecoration(
                        labelText: 'Kondisi Barang',
                      ),
                      items: [
                        'Seperti Baru',
                        'Baik',
                        'Cukup Baik',
                        'Perlu Perbaikan',
                      ]
                          .map(
                            (cond) => DropdownMenuItem(
                              value: cond,
                              child: Text(cond),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCondition = value),
                      validator: (v) =>
                          v == null ? 'Kondisi harus dipilih' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Harga',
                        prefixText: "Rp ",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.isEmpty ? 'Harga tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                      ),
                      maxLines: 4,
                      validator: (v) =>
                          v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi (Contoh: Jakarta Selatan)',
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFFF6B6B),
                      ),
                      child: const Text(
                        '🚀 Posting Sekarang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
