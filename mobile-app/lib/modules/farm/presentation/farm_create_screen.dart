import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/data/repositories/farm_repository.dart';
import 'package:petanitech_mobile/modules/farm/logic/blocs/farm/farm_bloc.dart';
import 'package:petanitech_mobile/modules/farm/logic/blocs/farm/farm_event.dart';
import 'package:petanitech_mobile/presentation/components/button.dart';
import 'package:petanitech_mobile/presentation/components/textfield.dart';

class FarmCreateScreen extends StatefulWidget {
  const FarmCreateScreen({super.key});

  @override
  State<FarmCreateScreen> createState() => _FarmCreateScreenState();
}

class _FarmCreateScreenState extends State<FarmCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaSizeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _areaUnit = 'm2';
  String _ownershipType = 'Pribadi';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _areaSizeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final areaSize = _areaSizeController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lahan tidak boleh kosong')),
      );
      return;
    }

    if (areaSize.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Luas lahan tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = Modular.get<FarmRepository>();
      final result = await repository.createFarm(
        name: name,
        areaSize: areaSize,
        areaUnit: _areaUnit,
        address: address,
        ownershipType: _ownershipType,
      );

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $error')),
          );
        },
        (farm) {
          Modular.get<FarmBloc>().add(RefreshFarms());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lahan berhasil ditambahkan!')),
          );
          Navigator.pop(context);
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Lahan Baru', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.accentColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Lahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Masukkan data lahan pertanian Anda untuk mempermudah monitoring',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            PTTextField(
              hintText: 'Nama Lahan (mis: Lahan Padi Blok A)',
              icon: Icons.landscape,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            PTTextField(
              hintText: 'Luas Lahan (mis: 1500 atau 1.5)',
              icon: Icons.square_foot,
              keyboardType: TextInputType.number,
              controller: _areaSizeController,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _areaUnit,
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.straighten, color: AppTheme.accentColor),
                ),
                labelText: 'Satuan Luas',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: const [
                DropdownMenuItem(value: 'm2', child: Text('Meter Persegi (m²)')),
                DropdownMenuItem(value: 'ha', child: Text('Hektar (ha)')),
                DropdownMenuItem(value: 'bata', child: Text('Bata / Tumbak')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _areaUnit = val);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _ownershipType,
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.verified_user, color: AppTheme.accentColor),
                ),
                labelText: 'Kepemilikan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: const [
                DropdownMenuItem(value: 'Pribadi', child: Text('Milik Pribadi')),
                DropdownMenuItem(value: 'Sewa', child: Text('Sewa')),
                DropdownMenuItem(value: 'Bagi Hasil', child: Text('Bagi Hasil')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _ownershipType = val);
              },
            ),
            const SizedBox(height: 16),
            PTTextField(
              hintText: 'Alamat / Lokasi Lahan (Desa, Kecamatan)',
              icon: Icons.location_on,
              controller: _addressController,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PTButton(
                    label: 'Simpan Lahan',
                    onPressed: _submit,
                    styleBuilder: PrimaryButtonStyleBuilder(),
                  ),
          ],
        ),
      ),
    );
  }
}
