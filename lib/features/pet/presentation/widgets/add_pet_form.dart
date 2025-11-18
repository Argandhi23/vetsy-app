// lib/features/pet/presentation/widgets/add_pet_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/presentation/cubit/my_pets_cubit.dart';

class AddPetForm extends StatefulWidget {
  final PetEntity? petToEdit;

  const AddPetForm({
    super.key,
    this.petToEdit,
  });

  @override
  State<AddPetForm> createState() => _AddPetFormState();
}

class _AddPetFormState extends State<AddPetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _breedController = TextEditingController();
  
  bool get _isEditing => widget.petToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.petToEdit!.name;
      _typeController.text = widget.petToEdit!.type;
      _breedController.text = widget.petToEdit!.breed;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
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
        left: 5.w,
        right: 5.w,
        top: 3.h,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Edit Hewan Peliharaan' : 'Tambah Hewan Peliharaan',
              style:
                  TextStyle(
                    // Ganti .sp menjadi statis
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Hewan (cth: Mochi)'),
              validator: (value) =>
                  value!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Jenis (cth: Kucing)'),
              validator: (value) =>
                  value!.isEmpty ? 'Jenis tidak boleh kosong' : null,
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _breedController,
              decoration: const InputDecoration(labelText: 'Ras (cth: Persia)'),
              validator: (value) =>
                  value!.isEmpty ? 'Ras tidak boleh kosong' : null,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Hewan'),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}