import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vetsy_app/core/config/locator.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/review/review_cubit.dart';

class AddReviewDialog extends StatefulWidget {
  final String clinicId;
  final String userId;
  final String username;

  const AddReviewDialog({
    super.key,
    required this.clinicId,
    required this.userId,
    required this.username,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isCommentEmpty = true;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _isCommentEmpty = _commentController.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Pastikan Cubit terdaftar di locator.dart
      create: (context) => sl<ReviewCubit>(),
      child: BlocConsumer<ReviewCubit, ReviewState>(
        listener: (context, state) {
          if (state is ReviewSuccess) {
            context.pop(); 
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Terima kasih! Ulasan berhasil dikirim."),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ReviewError) {
            context.pop(); // Tutup dulu biar user bisa coba lagi
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          bool isLoading = state is ReviewLoading;

          return Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  Text("Beri Penilaian", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Bagaimana pengalamanmu di klinik ini?", style: GoogleFonts.poppins(color: Colors.grey[600])),
                  const SizedBox(height: 32),

                  _buildAnimatedRatingBar(isLoading),
                  const SizedBox(height: 8),
                  
                  AnimatedSwitcher(
                    duration: 300.ms,
                    child: Text(
                      _getRatingLabel(_rating),
                      key: ValueKey(_rating),
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: _getRatingColor(_rating)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  TextField(
                    controller: _commentController,
                    enabled: !isLoading,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText: "Ceritakan pengalamanmu...",
                      filled: true, fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: (isLoading || _isCommentEmpty) ? null : () {
                        // [PERBAIKAN] Memanggil Cubit dengan parameter yang sesuai
                        context.read<ReviewCubit>().submitReview(
                              clinicId: widget.clinicId,
                              userId: widget.userId,
                              username: widget.username,
                              rating: _rating,
                              comment: _commentController.text,
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : Text("Kirim Ulasan", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : () => context.pop(),
                    child: Text("Nanti Saja", style: GoogleFonts.poppins(color: Colors.grey)),
                  )
                ],
              ),
            ),
          ).animate().slideY(begin: 1.0, duration: 400.ms, curve: Curves.easeOutBack);
        },
      ),
    );
  }

  Widget _buildAnimatedRatingBar(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        double starValue = index + 1.0;
        bool isSelected = starValue <= _rating;
        return GestureDetector(
          onTap: isLoading ? null : () => setState(() => _rating = starValue),
          child: Icon(
            isSelected ? EvaIcons.star : EvaIcons.starOutline,
            color: isSelected ? _getRatingColor(_rating) : Colors.grey[300],
            size: 40,
          ),
        );
      }),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating <= 2) return Colors.orange;
    if (rating <= 4) return Colors.amber;
    return const Color(0xFFFFB300);
  }

  String _getRatingLabel(double rating) {
    if (rating <= 2) return "Kurang Memuaskan 🙁";
    if (rating <= 4) return "Bagus! 😊";
    return "Luar Biasa! 😍";
  }
}