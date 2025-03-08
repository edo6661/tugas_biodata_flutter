import 'dart:io';
import 'package:biodata/features/camera/widgets/filter_selector.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class CameraResultScreen extends StatefulWidget {
  final String imagePath;
  final Color initialFilter;

  const CameraResultScreen({
    super.key,
    required this.imagePath,
    this.initialFilter = Colors.white,
  });

  @override
  State<CameraResultScreen> createState() => _CameraResultScreenState();
}

class _CameraResultScreenState extends State<CameraResultScreen>
    with SingleTickerProviderStateMixin {
  late Color _selectedFilter;
  late img.Image _originalImage;
  bool _isProcessing = false;
  bool _isLoading = true;
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _loadOriginalImage();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadOriginalImage() async {
    setState(() => _isLoading = true);
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      _originalImage = img.decodeImage(bytes)!;
    } catch (e) {
      // Handle error
      debugPrint('Error loading image: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.crop_rotate),
            color: Colors.white,
            onPressed: () {
              // Implementasi rotate bisa ditambahkan di sini
            },
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildImagePreview(),
      floatingActionButton: _buildSaveButton(),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Memuat gambar...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image preview with filter
        FadeTransition(
          opacity: _animation,
          child: Hero(
            tag: 'preview_image',
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                _selectedFilter.withOpacity(0.5),
                BlendMode.hardLight,
              ),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Top and bottom gradient overlays
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),

        // Filter selector at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterInfo(),
                const SizedBox(height: 8),
                _buildFilterSelector(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterInfo() {
    // Get filter name
    String filterName = "Normal";
    if (_selectedFilter != Colors.white) {
      // Find closest color name
      final colorNames = {
        Colors.red: "Merah",
        Colors.pink: "Pink",
        Colors.purple: "Ungu",
        Colors.deepPurple: "Ungu Tua",
        Colors.indigo: "Indigo",
        Colors.blue: "Biru",
        Colors.lightBlue: "Biru Muda",
        Colors.cyan: "Cyan",
        Colors.teal: "Teal",
        Colors.green: "Hijau",
        Colors.lightGreen: "Hijau Muda",
        Colors.lime: "Lime",
        Colors.yellow: "Kuning",
        Colors.amber: "Amber",
        Colors.orange: "Oranye",
        Colors.deepOrange: "Oranye Tua",
        Colors.brown: "Coklat",
        Colors.grey: "Abu-abu",
        Colors.blueGrey: "Biru Abu-abu",
      };

      filterName = colorNames.entries
          .firstWhere(
            (entry) =>
                entry.key.value == _selectedFilter.withOpacity(1.0).value,
            orElse: () => MapEntry(
              MaterialColor(_selectedFilter.value, {}),
              "Custom",
            ),
          )
          .value;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _selectedFilter,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            filterName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSelector() {
    return FilterSelector(
      filters: _getAvailableFilters(),
      onFilterChanged: (color) => setState(() => _selectedFilter = color),
      padding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  FloatingActionButton? _buildSaveButton() {
    return _isLoading
        ? null
        : FloatingActionButton.extended(
            onPressed: _isProcessing ? null : _saveFilteredImage,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 4,
            icon: _isProcessing
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade800,
                    ),
                  )
                : const Icon(Icons.save_alt),
            label: Text(_isProcessing ? 'Menyimpan...' : 'Simpan ke Galeri'),
          );
  }

  Future<void> _saveFilteredImage() async {
    setState(() => _isProcessing = true);

    try {
      final filteredImage = _applyFilter(_selectedFilter);
      final appDir = await getExternalStorageDirectory();
      final fileName = 'FILTERED_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '${appDir!.path}/$fileName';

      await File(path).writeAsBytes(img.encodeJpg(filteredImage));

      if (!mounted) return;

      // Show success dialog instead of snackbar
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Berhasil Disimpan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text('Foto berhasil disimpan ke:\n$path'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  img.Image _applyFilter(Color filterColor) {
    final overlay = img.Image.from(_originalImage);
    img.fillRect(overlay,
        x1: 0,
        y1: 0,
        x2: overlay.width,
        y2: overlay.height,
        color: img.ColorRgba8(
          filterColor.red,
          filterColor.green,
          filterColor.blue,
          (filterColor.alpha * 255).toInt(),
        ));

    return img.compositeImage(
      _originalImage,
      overlay,
      blend: img.BlendMode.hardLight,
    );
  }

  List<Color> _getAvailableFilters() => [
        Colors.white,
        ...Colors.primaries.map((color) => color.withOpacity(0.7)),
      ];
}
