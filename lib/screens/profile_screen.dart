// PERBAIKAN UNTUK: lib/screens/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_mhs/models/user_profile_model.dart';
import 'package:marketplace_mhs/services/auth_service.dart';
import 'package:marketplace_mhs/services/firestore_service.dart';
import 'package:marketplace_mhs/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _campusController;
  late TextEditingController _bioController;

  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  String? _selectedGender;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _campusController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Peringatan kerapian kode diperbaiki dengan menambahkan kurung kurawal
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final uid = authService.currentUser?.uid;
    if (uid != null) {
      final profile = await _firestoreService.getUserProfile(uid);
      if (mounted) {
        setState(() {
          if (profile != null) {
            _userProfile = profile;
            _nameController.text = profile.fullName;
            _phoneController.text = profile.phoneNumber;
            _addressController.text = profile.address ?? '';
            _campusController.text = profile.campus ?? '';
            _bioController.text = profile.bio ?? '';
            _selectedGender = profile.gender;
          }
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    if (_userProfile != null) {
      if (_imageFile != null) {
        final photoURL = await _storageService.uploadProfilePicture(
            _userProfile!.uid, _imageFile!);
        if (photoURL != null) {
          _userProfile!.photoURL = photoURL;
        }
      }

      _userProfile!.fullName = _nameController.text.trim();
      _userProfile!.phoneNumber = _phoneController.text.trim();
      _userProfile!.address = _addressController.text.trim();
      _userProfile!.campus = _campusController.text.trim();
      _userProfile!.bio = _bioController.text.trim();
      _userProfile!.gender = _selectedGender;

      await _firestoreService.updateUserProfile(_userProfile!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profil berhasil diperbarui!'),
              backgroundColor: Colors.green),
        );
      }
    }

    await _loadProfileData();
    if (mounted) {
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _campusController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Profil" : "Profil Saya"),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () async {
                await authService.signOut();
              },
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? const Center(child: Text("Gagal memuat profil. Coba lagi."))
              : ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 32),
                    _isEditing ? _buildEditForm() : _buildDisplayInfo(),
                  ],
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : _userProfile?.photoURL != null
                      ? NetworkImage(_userProfile!.photoURL!)
                      : null as ImageProvider?,
              child: _imageFile == null && _userProfile?.photoURL == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 20),
                    onPressed: _pickImage,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _userProfile!.fullName.isEmpty
              ? "Nama Belum Diatur"
              : _userProfile!.fullName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          _userProfile!.email,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            if (_isEditing) {
              _saveProfile();
            } else {
              setState(() {
                _isEditing = true;
              });
            }
          },
          icon: Icon(_isEditing ? Icons.save : Icons.edit),
          label: Text(_isEditing ? 'Simpan Perubahan' : 'Edit Profil'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isEditing ? Colors.green : Colors.indigo,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayInfo() {
    return Column(
      children: [
        _buildInfoTile(
            Icons.phone,
            "Nomor HP",
            _userProfile!.phoneNumber.isEmpty
                ? "Belum diatur"
                : _userProfile!.phoneNumber),
        _buildInfoTile(
            Icons.wc, "Jenis Kelamin", _userProfile!.gender ?? "Belum diatur"),
        _buildInfoTile(
            Icons.location_on,
            "Alamat",
            _userProfile!.address!.isEmpty
                ? "Belum diatur"
                : _userProfile!.address!),
        _buildInfoTile(
            Icons.school,
            "Institusi/Kampus",
            _userProfile!.campus!.isEmpty
                ? "Belum diatur"
                : _userProfile!.campus!),
        _buildInfoTile(Icons.info_outline, "Bio",
            _userProfile!.bio!.isEmpty ? "Belum diatur" : _userProfile!.bio!),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outline)),
            validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
                labelText: 'Nomor HP', prefixIcon: Icon(Icons.phone_outlined)),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
                labelText: 'Jenis Kelamin',
                prefixIcon: Icon(Icons.wc_outlined)),
            items: ['Pria', 'Wanita']
                .map((gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)))
                .toList(),
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
                labelText: 'Alamat',
                prefixIcon: Icon(Icons.location_on_outlined)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _campusController,
            decoration: const InputDecoration(
                labelText: 'Institusi/Kampus',
                prefixIcon: Icon(Icons.school_outlined)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
                labelText: 'Bio Singkat', prefixIcon: Icon(Icons.info_outline)),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
