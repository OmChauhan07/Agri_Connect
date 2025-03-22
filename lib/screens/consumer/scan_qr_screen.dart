import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({Key? key}) : super(key: key);

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _isScanning = false;
  bool _flashOn = false;
  bool _isFront = false;
  String? _scannedCode;
  bool _isProcessing = false;
  String? _errorMessage;
  bool _productFound = false;
  
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    } else if (Platform.isIOS) {
      _controller?.resumeCamera();
    }
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
      _isScanning = true;
    });
    
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && scanData.code != null) {
        _processCode(scanData.code!);
      }
    });
  }
  
  Future<void> _processCode(String code) async {
    setState(() {
      _isProcessing = true;
      _scannedCode = code;
      _controller?.pauseCamera();
    });
    
    try {
      // Check if code is a valid product ID
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final product = await productProvider.getProductById(code);
      
      if (product != null) {
        setState(() {
          _productFound = true;
          _errorMessage = null;
        });
        
        // Wait a moment to show the success message
        await Future.delayed(const Duration(seconds: 1));
        
        if (!mounted) return;
        
        // Navigate to product detail
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: code,
        ).then((_) {
          _resetScanner();
        });
      } else {
        setState(() {
          _productFound = false;
          _errorMessage = 'Invalid QR code. This does not match any product.';
        });
        
        // Wait a moment to show the error message
        await Future.delayed(const Duration(seconds: 2));
        _resetScanner();
      }
    } catch (e) {
      setState(() {
        _productFound = false;
        _errorMessage = 'Error processing QR code: ${e.toString()}';
      });
      
      // Wait a moment to show the error message
      await Future.delayed(const Duration(seconds: 2));
      _resetScanner();
    }
  }
  
  void _resetScanner() {
    if (!mounted) return;
    
    setState(() {
      _isProcessing = false;
      _scannedCode = null;
      _errorMessage = null;
      _productFound = false;
      _controller?.resumeCamera();
    });
  }
  
  void _toggleFlash() {
    if (_controller != null) {
      _controller!.toggleFlash();
      setState(() {
        _flashOn = !_flashOn;
      });
    }
  }
  
  void _flipCamera() {
    if (_controller != null) {
      _controller!.flipCamera();
      setState(() {
        _isFront = !_isFront;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // QR Scanner
          QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: AppColors.primary,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          
          // Scanning UI
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Scan Product QR Code',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // For centering the title
                    ],
                  ),
                ),
                
                // Spacer
                const Spacer(),
                
                // Status Message
                if (_isProcessing)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _productFound
                          ? Colors.green.withOpacity(0.8)
                          : _errorMessage != null
                              ? Colors.red.withOpacity(0.8)
                              : Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _productFound
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 32,
                              )
                            : _errorMessage != null
                                ? const Icon(
                                    Icons.error,
                                    color: Colors.white,
                                    size: 32,
                                  )
                                : const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                        const SizedBox(height: 8),
                        Text(
                          _productFound
                              ? 'Product found! Redirecting...'
                              : _errorMessage ?? 'Processing QR code...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Position the QR code within the frame to scan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Camera Controls
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withOpacity(0.6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Flash Toggle
                      IconButton(
                        icon: Icon(
                          _flashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                        ),
                        onPressed: _toggleFlash,
                      ),
                      // Camera Flip
                      IconButton(
                        icon: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                        ),
                        onPressed: _flipCamera,
                      ),
                      // Gallery Picker
                      IconButton(
                        icon: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Implement QR code scanning from gallery
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Image scanning coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
