import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

const _tunnelCheckUrl = 'http://neuroscope.atwebpages.com/eeg/';

class PredictorPage extends StatefulWidget {
  const PredictorPage({super.key});
  @override
  _PredictorPageState createState() => _PredictorPageState();
}

class _PredictorPageState extends State<PredictorPage> {
  bool _busy = false;
  String? _fileName;
  String? _predictedClass;
  Uint8List? _spectrogramPng;
  String? _serverBase;

  @override
  void initState() {
    super.initState();
    _loadDynamicServerBase();
  }

  Future<void> _loadDynamicServerBase() async {
    try {
      final response = await http.get(Uri.parse(_tunnelCheckUrl));
      if (response.statusCode == 200) {
        setState(() => _serverBase = response.body.trim());
      }
    } catch (_) {
      setState(() => _predictedClass = '⚠️ Cannot fetch server URL');
    }
  }

  Future<void> _pickAndPredict() async {
    if (_serverBase == null) return;
    setState(() {
      _busy = true;
      _predictedClass = null;
      _spectrogramPng = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (result == null) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) throw Exception('Could not read file');

      if (!file.name.toLowerCase().endsWith('.parquet')) {
        setState(() => _predictedClass = '⚠️ Must pick a .parquet file');
        return;
      }

      setState(() => _fileName = file.name);

      final pr = await http.post(
        Uri.parse('$_serverBase/predict_bytes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'file_name': file.name,
          'file_b64': base64Encode(bytes),
        }),
      );
      if (pr.statusCode != 200) {
        throw Exception('Prediction failed');
      }
      final pd = jsonDecode(pr.body);
      final cls = pd['class_'] as String?;
      final png = base64Decode(pd['image_b64'] as String);

      setState(() {
        _predictedClass = cls;
        _spectrogramPng = png;
      });

      final user = FirebaseAuth.instance.currentUser;
      final username = user?.email?.split('@').first ?? 'unknown';

      final ur = http.MultipartRequest(
        'POST',
        Uri.parse('$_serverBase/upload'),
      )
        ..fields['patientid'] = file.name
        ..fields['username'] = username
        ..fields['prediction'] = cls ?? ''
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          png,
          filename: '${file.name}_$cls.png',
        ));

      final urRes = await ur.send();
      if (urRes.statusCode != 201 && urRes.statusCode != 200) {
        throw Exception('Upload error ${urRes.statusCode}');
      }
    } catch (e) {
      setState(() => _predictedClass = '⚠️ $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'EEG Predictor',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/brain.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _busy ? null : _pickAndPredict,
                        icon: const Icon(Icons.upload_rounded, color: Colors.white),
                        label: const Text(
                          "Upload .parquet File",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                          backgroundColor: Colors.indigoAccent.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_busy) const CircularProgressIndicator(),
                      if (_fileName != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          '📄 File: $_fileName',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                      if (_predictedClass != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          '🧠 Prediction: $_predictedClass',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      if (_spectrogramPng != null) ...[
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _spectrogramPng!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
