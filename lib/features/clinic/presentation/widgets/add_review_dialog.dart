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
  double _rating = 5.0; // Default rating
  final TextEditingController _commentController = TextEditingController();
  bool _isCommentEmpty = true;

  @override
  void initState() {
    super.initState();
    // Listener untuk mengaktifkan/menonaktifkan tombol kirim
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
      create: (context) => sl<ReviewCubit>(),
      child: BlocConsumer<ReviewCubit, ReviewState>(
        listener: (context, state) {
          if (state is ReviewSuccess) {
            context.pop(); // Tutup dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Terima kasih! Ulasan berhasil dikirim."),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ReviewError) {
            context.pop();
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

          // --- 1. DESAIN DIALOG (Bottom Sheet Modern) ---
          return Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Garis pegangan kecil di atas
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 24),
                  
                  // Judul
                  Text(
                    "Beri Penilaian",
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bagaimana pengalamanmu di klinik ini?",
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // --- 2. RATING BINTANG INTERAKTIF ---
                  _buildAnimatedRatingBar(isLoading),
                  
                  const SizedBox(height: 8),
                  // Label Rating Dinamis (Misal: "Luar Biasa!", "Buruk")
                  AnimatedSwitcher(
                    duration: 300.ms,
                    child: Text(
                      _getRatingLabel(_rating),
                      key: ValueKey(_rating),
                      style: GoogleFonts.poppins(
                        fontSize: 16, 
                        fontWeight: FontWeight.w600, 
                        color: _getRatingColor(_rating)
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- 3. INPUT KOMENTAR ---
                  TextField(
                    controller: _commentController,
                    enabled: !isLoading,
                    maxLines: 4,
                    maxLength: 300,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: "Ceritakan pengalamanmu (pelayanan, fasilitas, dll)...",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 4. TOMBOL KIRIM MODERN ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (isLoading || _isCommentEmpty) ? null : () {
                        // Panggil Cubit
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
                        // Warna saat disabled (abu-abu)
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[500],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: (_isCommentEmpty || isLoading) ? 0 : 4,
                        shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : Text(
                              "Kirim Ulasan",
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                   // Tombol Batal (Optional)
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

  // --- WIDGET BINTANG BERANIMASI ---
  Widget _buildAnimatedRatingBar(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        double starValue = index + 1.0;
        bool isSelected = starValue <= _rating;
        
        return GestureDetector(
          onTap: isLoading ? null : () {
            setState(() => _rating = starValue);
          },
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isSelected ? EvaIcons.star : EvaIcons.starOutline,
              color: isSelected ? _getRatingColor(_rating) : Colors.grey[300],
              size: 40,
            ),
          ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1), duration: 150.ms).then().scale(begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0), duration: 100.ms),
        );
      }),
    );
  }

  // --- Helper: Warna Bintang Dinamis ---
  Color _getRatingColor(double rating) {
    if (rating <= 1) return Colors.red;
    if (rating <= 2) return Colors.orange;
    if (rating <= 3) return Colors.amber;
    if (rating <= 4) return Colors.yellow[700]!;
    return const Color(0xFFFFB300); // Emas Tua untuk bintang 5
  }

  // --- Helper: Label Text Dinamis ---
  String _getRatingLabel(double rating) {
    if (rating <= 1) return "Sangat Buruk 😞";
    if (rating <= 2) return "Buruk 🙁";
    if (rating <= 3) return "Biasa Saja 😐";
    if (rating <= 4) return "Bagus! 😊";
    return "Luar Biasa! 😍";
  }
}