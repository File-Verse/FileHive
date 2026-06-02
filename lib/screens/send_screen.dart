import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:filehive/services/transfer/send_service.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final SendService _sendService = SendService();

  bool isSending = false;
  double progress = 0;

  Future<void> _handleFileSelection() async {
    try {
      setState(() {
        isSending = true;
        progress = 0;
      });

      const uuid = Uuid();
      final token = uuid.v4();

      await _sendService.pickAndSendFile(
        token: token,

        onProgress: (value) {
          if (!mounted) return;

          setState(() {
            progress = value;
          });
        },

        onError: (error) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
            ),
          );

          setState(() {
            isSending = false;
          });
        },
      );

      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ File process completed"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Send failed: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: isSending
              ? null
              : () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Column(
            children: [

              const SizedBox(height: 20),

              Center(
                child: Container(
                  width: 120,
                  height: 120,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF22C55E),
                        Color(0xFF16A34A)
                      ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Color(0x5522C55E),
                        blurRadius: 25,
                        offset: Offset(0,10),
                      ),
                    ],
                  ),

                  child: Icon(
                    isSending
                        ? Icons.wifi_tethering
                        : Icons.upload_rounded,

                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                isSending
                    ? "Sending Files"
                    : "Send Files",

                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                isSending
                    ? "Please wait while FileHive sends\nyour file."
                    : "Share files quickly and securely\nwith nearby devices.",

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 65,

                child: ElevatedButton(
                  onPressed: isSending
                      ? null
                      : _handleFileSelection,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF22C55E),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),

                  child: Text(
                    isSending
                        ? "Sending..."
                        : "Select & Send File",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if(isSending)...[
                const SizedBox(height:25),

                LinearProgressIndicator(
                  value: progress,
                ),

                const SizedBox(height:10),

                Text(
                  "$percentage%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height:40),

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),

                  borderRadius:
                  BorderRadius.circular(15),
                ),

                child: const Row(
                  children: [

                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF3B82F6),
                    ),

                    SizedBox(width:15),

                    Expanded(
                      child: Text(
                        "Make sure receiver tapped Start Receiving and both devices are on same WiFi.",
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}