import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/presentation/cubit/my_pets_cubit.dart';

class AddPetForm extends StatefulWidget {
  final PetEntity? petToEdit;
  const AddPetForm({super.key, this.petToEdit});

  @override
  State<AddPetForm> createState() => _AddPetFormState();
}

class _AddPetFormState extends State<AddPetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController(); // Baru
  final _weightController = TextEditingController(); // Baru
  
  bool get _isEditing => widget.petToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.petToEdit!.name;
      _typeController.text = widget.petToEdit!.type;
      _breedController.text = widget.petToEdit!.breed;
      _ageController.text = widget.petToEdit!.age.toString();
      _weightController.text = widget.petToEdit!.weight.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Ambil data tambahan (jangan lupa update logic di Repository/DataSource juga nanti)
      // Untuk kesederhanaan, logic kirim data harusnya disesuaikan dengan parameter baru
      // Tapi karena kita belum update repository parameter, data ini mungkin tidak tersimpan 
      // tanpa update repository. 
      
      // NOTE: Anda perlu update repository.addPet dan updatePet untuk menerima age & weight.
      
      if (_isEditing) {
        context.read<MyPetsCubit>().updatePet(
              id: widget.petToEdit!.id,
              name: _nameController.text,
              type: _typeController.text,
              breed: _breedController.text,
            );
      } else {
        context.read<MyPetsCubit>().addPet(
              name: _nameController.text,
              type: _typeController.text,
              breed: _breedController.text,
            );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Edit Hewan' : 'Tambah Hewan',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: _inputDeco('Nama Hewan (cth: Mochi)'),
              validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _typeController,
                    decoration: _inputDeco('Jenis (Kucing)'),
                    validator: (val) => val!.isEmpty ? 'Wajib' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _breedController,
                    decoration: _inputDeco('Ras (Persia)'),
                    validator: (val) => val!.isEmpty ? 'Wajib' : null,
                  ),
                ),
              ],
            ),
            // KITA SIMPAN DULU LOGIC UMUR & BERAT UNTUK UPDATE BERIKUTNYA
            // KARENA PERLU UPDATE REPOSITORY YANG CUKUP BANYAK
            
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Hewan'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}