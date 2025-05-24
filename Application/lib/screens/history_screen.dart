import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HistoryOnlyPage extends StatefulWidget {
  const HistoryOnlyPage({super.key});

  @override
  State<HistoryOnlyPage> createState() => _HistoryOnlyPageState();
}

class _HistoryOnlyPageState extends State<HistoryOnlyPage> {
  static const String _serverBase = 'http://localhost:8000';
  static const String _user       = 'admin';

  List<String> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final resp = await http.get(
        Uri.parse('$_serverBase/history/$_user'),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _history = List<String>.from(data['history'] ?? []);
          _isLoading = false;
        });
        return;
      }
      throw Exception('Status ${resp.statusCode}');
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load history: $e')),
      );
    }
  }

  Future<Uint8List?> _fetchImageBytes(String fileName) async {
    final url = '$_serverBase/uploads/${Uri.encodeComponent(fileName)}';
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) return resp.bodyBytes;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: const Color(0xff132137),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text('No history yet'))
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (ctx, i) {
                    final file = _history[i];
                    // filename format: patientid_username_prediction_index.png
                    final parts = file.split('_');
                    final patientId = parts.isNotEmpty ? parts[0] : file;
                    final prediction =
                        (parts.length >= 3) ? parts[2] : 'Unknown';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: FutureBuilder<Uint8List?>(
                          future: _fetchImageBytes(file),
                          builder: (ctx, snap) {
                            if (snap.connectionState !=
                                ConnectionState.done) {
                              return const SizedBox(
                                width: 50,
                                height: 50,
                                child: Center(
                                    child:
                                        CircularProgressIndicator()),
                              );
                            }
                            if (snap.data == null) {
                              return const Icon(Icons.broken_image,
                                  size: 50);
                            }
                            return Image.memory(
                              snap.data!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        title: Text('Patient ID: $patientId'),
                        subtitle: Text('Prediction: $prediction'),
                        onTap: () async {
                          final img = await _fetchImageBytes(file);
                          if (img != null && mounted) {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Patient ID: $patientId\n'
                                        'Prediction: $prediction',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Image.memory(img),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
