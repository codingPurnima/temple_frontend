import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_theme.dart';
import '../../models/content_model.dart';
import '../../services/content_service.dart';
import '../../widgets/state_widgets/app_error.dart';
import '../../widgets/state_widgets/app_loading.dart';

class ManageAppContentScreen extends StatefulWidget {
  const ManageAppContentScreen({super.key});

  @override
  State<ManageAppContentScreen> createState() => _ManageAppContentScreenState();
}

// Typedef to ensure existing references to DashboardContent resolve seamlessly
typedef DashboardContent = ManageAppContentScreen;

class _ManageAppContentScreenState extends State<ManageAppContentScreen> {
  final ContentService _contentService = ContentService();
  final ImagePicker _imagePicker = ImagePicker();

  // App defaults
  static const String _defaultHomeContent = "";
  static const String _defaultHomeTitle = "स्वागतम्‌";
  static const String _defaultHomeSubtitle = "";
  static const String _defaultQuoteText = "";
  static const String _defaultQuoteAsset = "assets/images/quote.jpg";

  // Controllers
  final TextEditingController _homeTitleController = TextEditingController();
  final TextEditingController _homeSubtitleController = TextEditingController();
  final TextEditingController _homeContentController = TextEditingController();
  final TextEditingController _quoteTextController = TextEditingController();

  // Selected files
  final List<File> _selectedCarouselImages = [];
  File? _selectedQuoteImage;

  // State
  AppContent? _content;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  bool _isSavingHome = false;
  bool _isSavingQuote = false;
  bool _isUploadingCarousel = false;
  int? _deletingImageId;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _homeTitleController.dispose();
    _homeSubtitleController.dispose();
    _homeContentController.dispose();
    _quoteTextController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final content = await _contentService.getContent();

      if (!mounted) return;

      if (content != null) {
        _content = content;

        // Populate Home Title (backend or default)
        if (content.home.title != null &&
            content.home.title!.trim().isNotEmpty) {
          _homeTitleController.text = content.home.title!;
        } else {
          _homeTitleController.text = _defaultHomeTitle;
        }

        // Populate Home Subtitle (backend or default)
        if (content.home.subtitle != null &&
            content.home.subtitle!.trim().isNotEmpty) {
          _homeSubtitleController.text = content.home.subtitle!;
        } else {
          _homeSubtitleController.text = _defaultHomeSubtitle;
        }

        // Populate Home Content (backend or bundled default)
        if (content.home.content != null &&
            content.home.content!.trim().isNotEmpty) {
          _homeContentController.text = content.home.content!;
        } else {
          _homeContentController.text = _defaultHomeContent;
        }

        // Populate Quote Text (backend or default)
        if (content.quote.text != null &&
            content.quote.text!.trim().isNotEmpty) {
          _quoteTextController.text = content.quote.text!;
        } else {
          _quoteTextController.text = _defaultQuoteText;
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage =
              "सामग्री लोड करने में असमर्थ। कृपया पुनः प्रयास करें।";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  // -------------------------------------------------------------
  // Section 1: Carousel Handlers
  // -------------------------------------------------------------

  Future<void> _pickCarouselImages() async {
    try {
      final pickedList = await _imagePicker.pickMultiImage();
      if (pickedList.isNotEmpty) {
        setState(() {
          _selectedCarouselImages.addAll(pickedList.map((x) => File(x.path)));
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("चित्र चयन विफल: $e", isError: true);
    }
  }

  Future<void> _uploadSelectedCarouselImages() async {
    if (_selectedCarouselImages.isEmpty || _isUploadingCarousel) return;

    setState(() => _isUploadingCarousel = true);

    final result = await _contentService.uploadDashboardImages(
      _selectedCarouselImages,
    );

    if (!mounted) return;
    setState(() => _isUploadingCarousel = false);

    if (result != null) {
      setState(() => _selectedCarouselImages.clear());
      _showSnackBar("बैनर चित्र सफलतापूर्वक अपलोड किए गए!", isError: false);
      _loadContent();
    } else {
      _showSnackBar(
        "चित्र अपलोड विफल रहा। कृपया पुनः प्रयास करें।",
        isError: true,
      );
    }
  }

  Future<void> _confirmDeleteCarouselImage(DashboardImage image) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("चित्र हटाएं / Delete Image"),
        content: const Text(
          "क्या आप इस बैनर चित्र को निश्चित रूप से हटाना चाहते हैं?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("रद्द करें / Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("हटाएं / Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    setState(() => _deletingImageId = image.id);

    final success = await _contentService.deleteDashboardImage(image.id);

    if (!mounted) return;
    setState(() => _deletingImageId = null);

    if (success) {
      _showSnackBar("चित्र सफलतापूर्वक हटा दिया गया।", isError: false);
      _loadContent();
    } else {
      _showSnackBar("चित्र हटाने में त्रुटि हुई।", isError: true);
    }
  }

  // -------------------------------------------------------------
  // Section 2: Home Content Handler
  // -------------------------------------------------------------

  Future<void> _updateHomeContent() async {
    if (_isSavingHome) return;

    setState(() => _isSavingHome = true);

    final result = await _contentService.updateContent(
      homeTitle: _homeTitleController.text.trim(),
      homeSubtitle: _homeSubtitleController.text.trim(),
      homeContent: _homeContentController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSavingHome = false);

    if (result != null) {
      setState(() => _content = result);
      _showSnackBar(
        "मुख्य पृष्ठ सामग्री सफलतापूर्वक सहेजी गई!",
        isError: false,
      );
    } else {
      _showSnackBar("अपडेट विफल रहा। कृपया नेटवर्क जांचें।", isError: true);
    }
  }

  // -------------------------------------------------------------
  // Section 3: Quote Handlers
  // -------------------------------------------------------------

  Future<void> _pickQuoteImage() async {
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _selectedQuoteImage = File(picked.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("चित्र चयन विफल: $e", isError: true);
    }
  }

  Future<void> _resetQuoteImageToDefault() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("चित्र रीसेट करें / Reset Image"),
        content: const Text(
          "क्या आप कस्टम चित्र हटाकर डिफ़ॉल्ट सुविचार चित्र लगाना चाहते हैं?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("रद्द करें / Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("रीसेट करें / Reset"),
          ),
        ],
      ),
    );

    if (shouldReset != true || !mounted) return;

    if (_selectedQuoteImage != null && _content?.quote.imageUrl == null) {
      setState(() => _selectedQuoteImage = null);
      _showSnackBar("चयनित चित्र हटा दिया गया।", isError: false);
      return;
    }

    setState(() => _isSavingQuote = true);

    final result = await _contentService.updateContent(clearQuoteImage: true);

    if (!mounted) return;
    setState(() {
      _isSavingQuote = false;
      _selectedQuoteImage = null;
    });

    if (result != null) {
      setState(() => _content = result);
      _showSnackBar(
        "डिफ़ॉल्ट सुविचार चित्र पुनर्स्थापित किया गया।",
        isError: false,
      );
    } else {
      _showSnackBar("चित्र रीसेट करने में त्रुटि हुई।", isError: true);
    }
  }

  Future<void> _updateQuote() async {
    if (_isSavingQuote) return;

    setState(() => _isSavingQuote = true);

    final result = await _contentService.updateContent(
      quoteText: _quoteTextController.text.trim(),
      quoteImage: _selectedQuoteImage,
    );

    if (!mounted) return;
    setState(() => _isSavingQuote = false);

    if (result != null) {
      setState(() {
        _content = result;
        _selectedQuoteImage = null;
      });
      _showSnackBar("सुविचार विवरण सफलतापूर्वक सहेजा गया!", isError: false);
    } else {
      _showSnackBar("सुविचार अपडेट विफल रहा।", isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
      ),
    );
  }

  // -------------------------------------------------------------
  // Build Methods
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: const Text("सामग्री प्रबंधन / App Content"),
        actions: [
          IconButton(
            tooltip: "रिफ्रेश करें / Refresh",
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _isLoading ? null : _loadContent,
          ),
        ],
      ),
      body: _isLoading && _content == null
          ? const Center(child: AppLoadingView())
          : _hasError && _content == null
          ? Center(
              child: AppErrorView(
                message: _errorMessage ?? "सामग्री लोड नहीं हो सकी",
                onRetry: _loadContent,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadContent,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCarouselSection(),
                        const SizedBox(height: 20),
                        _buildHomeContentSection(),
                        const SizedBox(height: 20),
                        _buildQuoteSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // -------------------------------------------------------------
  // Section 1 UI: Carousel
  // -------------------------------------------------------------

  Widget _buildCarouselSection() {
    final images = _content?.dashboardImages ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            icon: Icons.view_carousel_rounded,
            title: "होम बैनर चित्र / Dashboard Carousel",
            subtitle:
                "मुख्य स्क्रीन पर प्रदर्शित होने वाले चित्रों का प्रबंधन करें",
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.cardBorder, height: 1),
          const SizedBox(height: 16),

          // Existing Images
          if (images.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.saffronLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.warmGold.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.saffronAccent,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "वर्तमान में ऐप में शामिल डिफ़ॉल्ट बैनर चित्र प्रदर्शित हो रहे हैं। नए चित्र जोड़ने के लिए नीचे दिए गए बटन का उपयोग करें।",
                      style: TextStyle(
                        fontFamily: 'TiroDevanagariHindi',
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              "सक्रिय चित्र (${images.length})",
              style: const TextStyle(
                fontFamily: 'TiroDevanagariHindi',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final img = images[index];
                  final isDeleting = _deletingImageId == img.id;

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 150,
                          height: 110,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.cardBorder),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.network(
                            img.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isDeleting
                                ? null
                                : () => _confirmDeleteCarouselImage(img),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: isDeleting
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],

          // Selected pending images preview
          if (_selectedCarouselImages.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              "अपलोड हेतु चयनित चित्र (${_selectedCarouselImages.length})",
              style: const TextStyle(
                fontFamily: 'TiroDevanagariHindi',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.saffronAccent,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedCarouselImages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final file = _selectedCarouselImages[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          file,
                          width: 120,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCarouselImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploadingCarousel
                        ? null
                        : _uploadSelectedCarouselImages,
                    icon: _isUploadingCarousel
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.cloud_upload_rounded, size: 18),
                    label: Text(
                      _isUploadingCarousel
                          ? "अपलोड हो रहा है..."
                          : "अपलोड करें (${_selectedCarouselImages.length})",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _isUploadingCarousel
                      ? null
                      : () => setState(() => _selectedCarouselImages.clear()),
                  child: const Text("रद्द करें"),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isUploadingCarousel ? null : _pickCarouselImages,
            icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
            label: const Text("गैलरी से चित्र जोड़ें / Select Images"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppTheme.saffronAccent, width: 1.2),
              foregroundColor: AppTheme.saffronAccent,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Section 2 UI: Home Content
  // -------------------------------------------------------------

  Widget _buildHomeContentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            icon: Icons.article_rounded,
            title: "मुख्य पृष्ठ विवरण / Home Content",
            subtitle: "होम स्क्रीन पर प्रदर्शित शीर्षक, उप-शीर्षक एवं सन्देश",
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.cardBorder, height: 1),
          const SizedBox(height: 18),

          // Title
          TextFormField(
            controller: _homeTitleController,
            decoration: const InputDecoration(
              labelText: "शीर्षक / Title",
              prefixIcon: Icon(
                Icons.title_rounded,
                color: AppTheme.saffronAccent,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Subtitle
          TextFormField(
            controller: _homeSubtitleController,
            decoration: const InputDecoration(
              labelText: "उप-शीर्षक / Subtitle",
              prefixIcon: Icon(
                Icons.subtitles_rounded,
                color: AppTheme.saffronAccent,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Content
          TextFormField(
            controller: _homeContentController,
            maxLines: 7,
            minLines: 4,
            decoration: const InputDecoration(
              labelText: "सन्देश / Message Content",
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 18),

          // Submit Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSavingHome ? null : _updateHomeContent,
              child: _isSavingHome
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("विवरण अपडेट करें / Update Home Content"),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Section 3 UI: Quote
  // -------------------------------------------------------------

  Widget _buildQuoteSection() {
    final customImageUrl = _content?.quote.imageUrl;
    final hasCustomImage =
        _selectedQuoteImage != null ||
        (customImageUrl != null && customImageUrl.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            icon: Icons.format_quote_rounded,
            title: "नित्य सुविचार / Sacred Quote",
            subtitle: "दैनिक सुविचार एवं पृष्ठभूमि चित्र का संपादन करें",
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.cardBorder, height: 1),
          const SizedBox(height: 18),

          // Quote Text
          TextFormField(
            controller: _quoteTextController,
            maxLines: 4,
            minLines: 2,
            decoration: const InputDecoration(
              labelText: "सुविचार / Quote Text",
              prefixIcon: Icon(
                Icons.edit_note_rounded,
                color: AppTheme.saffronAccent,
                size: 22,
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 18),

          // Image Preview Container
          const Text(
            "पृष्ठभूमि चित्र / Background Image",
            style: TextStyle(
              fontFamily: 'TiroDevanagariHindi',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_selectedQuoteImage != null)
                    Image.file(_selectedQuoteImage!, fit: BoxFit.cover)
                  else if (customImageUrl != null && customImageUrl.isNotEmpty)
                    Image.network(
                      customImageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (_, _, _) =>
                          Image.asset(_defaultQuoteAsset, fit: BoxFit.cover),
                    )
                  else
                    Image.asset(_defaultQuoteAsset, fit: BoxFit.cover),

                  // Badge overlay
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedQuoteImage != null
                            ? "नया चयनित चित्र (Pending)"
                            : (customImageUrl != null &&
                                  customImageUrl.isNotEmpty)
                            ? "कस्टम चित्र (Custom Upload)"
                            : "डिफ़ॉल्ट चित्र (Bundled Asset)",
                        style: const TextStyle(
                          fontFamily: 'TiroDevanagariHindi',
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Image Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSavingQuote ? null : _pickQuoteImage,
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text("चित्र बदलें / Pick Image"),
                ),
              ),
              if (hasCustomImage) ...[
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _isSavingQuote ? null : _resetQuoteImageToDefault,
                  icon: const Icon(Icons.restore_rounded, size: 18),
                  label: const Text("डिफ़ॉल्ट पर रीसेट"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // Submit Quote Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSavingQuote ? null : _updateQuote,
              child: _isSavingQuote
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("सुविचार अपडेट करें / Update Quote"),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Reusable Section Header
  // -------------------------------------------------------------

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.saffronLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.saffronAccent, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'TiroDevanagariHindi',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'TiroDevanagariHindi',
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
