import 'package:flutter/material.dart';
import 'package:filehive/routes/app_routes.dart';

class SendProgressScreen extends StatefulWidget {
  const SendProgressScreen({Key? key}) : super(key: key);

  @override
  State<SendProgressScreen> createState() => _SendProgressScreenState();
}

class _SendProgressScreenState extends State<SendProgressScreen> {
  double _progressValue = 0.75; // Image ke mutabik 75% progress

  @override
  void initState() {
    super.initState();
    // Aap chahein toh yahan real animation ya timer laga sakte hain
    // jo 100% hone par automatic Transfer Complete screen par bhej de.
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.transferComplete);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // 1. Top File Detail Card
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Color(0xFFEF4444),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Document.pdf",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "1.8 MB",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 2. Phones & Transfer Graphic (Exact image jaisa)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left Phone Outline
                  _buildPhoneOutline(),

                  // Dotted Line and Center Send Icon
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Green Dotted Line look
                        Row(
                          children: List.generate(
                            12,
                                (index) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 2,
                                color: const Color(0xFF22C55E),
                              ),
                            ),
                          ),
                        ),
                        // Center Circular Send Button
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ),

                  // Right Phone Outline
                  _buildPhoneOutline(),
                ],
              ),

              const SizedBox(height: 30),
              const Text(
                "Sending...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),

              const SizedBox(height: 30),

              // 3. Progress Bar with Percentage Text
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progressValue,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "${(_progressValue * 100).toInt()}%",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                ],
              ),

              const Spacer(),

              // 4. Info Message Box
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Please stay on this screen until the transfer is complete.",
                        style: TextStyle(color: Color(0xFF1E40AF), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 5. Cancel Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Phone Border Widget helper
  Widget _buildPhoneOutline() {
    return Container(
      width: 45,
      height: 85,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}