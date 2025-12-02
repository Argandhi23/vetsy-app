import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
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
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  // Ganti Text Controller dengan Choice Chip untuk Type
  String _selectedType = 'Kucing';

  bool get _isEditing => widget.petToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.petToEdit!.name;
      _breedController.text = widget.petToEdit!.breed;
      _selectedType = widget.petToEdit!.type;
      _ageController.text = widget.petToEdit!.age.toString();
      _weightController.text = widget.petToEdit!.weight.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final int age = int.tryParse(_ageController.text) ?? 0;
      final double weight = double.tryParse(_weightController.text) ?? 0.0;

      if (_isEditing) {
        context.read<MyPetsCubit>().updatePet(
          id: widget.petToEdit!.id,
          name: _nameController.text,
          type: _selectedType,
          breed: _breedController.text,
          age: age,
          weight: weight,
        );
      } else {
        context.read<MyPetsCubit>().addPet(
          name: _nameController.text,
          type: _selectedType,
          breed: _breedController.text,
          age: age,
          weight: weight,
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
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                _isEditing ? 'Edit Data Hewan' : 'Tambah Hewan Baru',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Avatar Mockup tanpa tombol kamera
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Icon(Icons.pets, size: 50, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 24),

              // Input Fields
              TextFormField(
                controller: _nameController,
                decoration: _inputDeco('Nama Hewan', EvaIcons.heartOutline),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Type Selector (Chips)
              Text(
                "Jenis Hewan",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeChip('Kucing'),
                  const SizedBox(width: 12),
                  _buildTypeChip('Anjing'),
                  const SizedBox(width: 12),
                  _buildTypeChip('Lainnya'),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _breedController,
                decoration: _inputDeco(
                  'Ras (cth: Persia)',
                  EvaIcons.pricetagsOutline,
                ),
                validator: (val) => val!.isEmpty ? 'Wajib' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDeco(
                        'Umur (Bln)',
                        EvaIcons.calendarOutline,
                      ),
                      validator: (val) => val!.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDeco(
                        'Berat (Kg)',
                        EvaIcons.barChart2Outline,
                      ),
                      validator: (val) => val!.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text(
                    _isEditing ? 'Simpan Perubahan' : 'Simpan Hewan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label) {
    final isSelected = _selectedType == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedType = label;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}
