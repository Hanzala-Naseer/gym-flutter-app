import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../services/api_services.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing) return;

      if (scanData.code != null) {
        setState(() => _isProcessing = true);
        await controller.pauseCamera();

        final result = await _handleCheckin(scanData.code!);

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(result['success'] ? 'Success' : 'Failed'),
              content: Text(result['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (result['success']) {
                      Navigator.pop(context);
                    } else {
                      setState(() => _isProcessing = false);
                      controller.resumeCamera();
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  Future<Map<String, dynamic>> _handleCheckin(String qrToken) async {
    final response = await ApiService.checkin(qrToken: qrToken);

    if (response['success']) {
      return {
        'success': true,
        'message': 'Check-in successful! Welcome to the gym.',
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Check-in failed',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Center(
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Position QR code within the frame',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
