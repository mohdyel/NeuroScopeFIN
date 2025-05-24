// lib/history_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // for WidgetsBinding
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view.dart' show PhotoViewComputedScale;
import 'package:cached_network_image/cached_network_image.dart';

// global RouteObserver (registered in your MaterialApp)
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

// your PHP backend
const String _serverBase = 'http://neuroscope.atwebpages.com/php';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with RouteAware {
  List<String> _history = [];
  bool _isLoading = true;
  bool _hasLoaded = false;
  String _userName = 'unknown';

  @override
  void initState() {
    super.initState();
    // Whenever the signed-in user changes, update _userName and force a refresh
    FirebaseAuth.instance.authStateChanges().listen((user) {
      final newName = user?.email?.split('@')[0] ?? 'unknown';
      if (newName != _userName) {
        setState(() {
          _userName = newName;
          _hasLoaded = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() => _hasLoaded = false;
  @override
  void didPopNext() => _hasLoaded = false;

  Future<void> _refreshAll() async {
    setState(() {
      _isLoading = true;
      _history.clear();
    });
    try {
      final uri = Uri.parse('$_serverBase/history.php')
          .replace(queryParameters: {'username': _userName});
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _history = List<String>.from(data['history'] ?? []);
      }
    } catch (e) {
      debugPrint('History load error: $e');
    }
    setState(() {
      _isLoading = false;
      _hasLoaded = true;
    });
  }

  void _showImageDetails(BuildContext context, String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _HistoryDetailPage(fileName: fileName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modal = ModalRoute.of(context);
    if (!_hasLoaded && modal != null && modal.isCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refreshAll();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                letterSpacing: 0.5)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history,
                  size: 80, color: Colors.blue.shade300),
            ),
            const SizedBox(height: 24),
            Text('No History Available',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800)),
            const SizedBox(height: 12),
            Text('Your medical scan history will appear here',
                style: TextStyle(
                    fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      );

  Widget _buildHistoryList() => ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: _history.length,
        itemBuilder: (context, i) {
          final file = _history[i];
          final thumbUrl =
              '$_serverBase/serve.php?file=${Uri.encodeComponent(file)}';

          // strip trailing "parquet" from the ID
          final rawId = file.split('_').first;
          final patientId =
              rawId.replaceAll(RegExp(r'parquet$', caseSensitive: false), '');

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Card(
              elevation: 3,
              shadowColor: Colors.blue.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                onTap: () => _showImageDetails(context, file),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'image_$file',
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: thumbUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                      child: CircularProgressIndicator())),
                              errorWidget: (ctx, url, err) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                      child:
                                          Icon(Icons.broken_image, size: 40))),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Patient $patientId',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  DateTime.now()
                                      .toString()
                                      .split(' ')[0],
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility,
                                      size: 16, color: Colors.blue.shade700),
                                  const SizedBox(width: 6),
                                  Text('View Details',
                                      style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _HistoryDetailPage extends StatelessWidget {
  final String fileName;
  const _HistoryDetailPage({required this.fileName});

  @override
  Widget build(BuildContext context) {
    final parts = fileName.split('_');
    final rawId = parts.isNotEmpty ? parts[0] : 'Unknown';
    final patientId =
        rawId.replaceAll(RegExp(r'parquet$', caseSensitive: false), '');
    final predictedClass =
        parts.length > 2 ? parts[2].split('.').first : 'Unknown';
    final imageUrl =
        '$_serverBase/serve.php?file=${Uri.encodeComponent(fileName)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Details'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Text('Patient ID: $patientId',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('Prediction: $predictedClass',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.blue)),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (ctx, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (ctx, url, err) =>
                    const Center(child: Icon(Icons.broken_image, size: 100)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.black,
                        leading: IconButton(
                          icon:
                              const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      body: PhotoView(
                        imageProvider: NetworkImage(imageUrl),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale:
                            PhotoViewComputedScale.covered * 2,
                      ),
                    ),
                  ),
                ),
                icon: const Icon(Icons.zoom_in),
                label: const Text('Zoom Image'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
