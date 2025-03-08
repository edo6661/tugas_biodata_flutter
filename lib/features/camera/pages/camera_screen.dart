import 'dart:async';
import 'package:biodata/features/camera/pages/camera_result_screen.dart';
import 'package:biodata/features/camera/widgets/filter_selector.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const CameraScreen());
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  String? _errorMessage;
  Color _currentFilter = Colors.white;
  bool _isCapturing = false;

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = "No camera available";
        });
        return;
      }
      _cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    } on CameraException catch (e) {
      _handleCameraError(e);
    } catch (e) {
      _handleGenericError(e);
    }
  }

  void _handleCameraError(CameraException e) {
    setState(() {
      _errorMessage = 'Error kamera: ${e.description}';
    });
    debugPrint(_errorMessage);
  }

  void _handleGenericError(dynamic e) {
    setState(() {
      _errorMessage = 'Error: ${e.toString()}';
    });
    debugPrint(_errorMessage);
  }

  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized || _isCapturing) return;
    setState(() {
      _isCapturing = true;
    });
    try {
      final XFile picture = await _cameraController!.takePicture();
      _navigateToImageResultScreen(picture);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _navigateToImageResultScreen(XFile image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraResultScreen(
          imagePath: image.path,
          initialFilter: _currentFilter,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.paused) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Camera',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black45,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildCameraContent(),
    );
  }

  Widget _buildCameraContent() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Mempersiapkan kamera...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        _buildCameraPreviewWithFilter(),
        _buildFilterSelectorWithCapture(),
        if (_isCapturing)
          AnimatedOpacity(
            opacity: _isCapturing ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 4,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCameraPreviewWithFilter() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        _currentFilter.withOpacity(0.5),
        BlendMode.hardLight,
      ),
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildFilterSelectorWithCapture() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCaptureButton(),
            const SizedBox(height: 24),
            FilterSelector(
              filters: _getAvailableFilters(),
              onFilterChanged: (color) =>
                  setState(() => _currentFilter = color),
              onFilterTap: _takePicture,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.black12,
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getAvailableFilters() => [
        Colors.white,
        ...Colors.primaries.map((color) => color.withOpacity(0.7)),
      ];
}
