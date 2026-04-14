import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';

class StorageService {
  static const String _fileName = 'technogm_data.json';
  static const String _prefKey = 'technogm_data';

  // ─── Local file path (native platforms) ────────────────────────────────────

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // ─── Load ──────────────────────────────────────────────────────────────────

  Future<AppData> load() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final jsonStr = prefs.getString(_prefKey);
        if (jsonStr == null) return AppData();
        return AppData.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      }

      final file = await _getFile();
      if (!await file.exists()) return AppData();
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return AppData.fromJson(json);
    } catch (e) {
      debugPrint('StorageService.load error: $e');
      return AppData();
    }
  }

  // ─── Save ──────────────────────────────────────────────────────────────────

  Future<void> save(AppData data) async {
    try {
      final jsonStr = jsonEncode(data.toJson());
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, jsonStr);
        return;
      }
      final file = await _getFile();
      await file.writeAsString(jsonStr);
    } catch (e) {
      debugPrint('StorageService.save error: $e');
    }
  }

  // ─── Export (share JSON file) ──────────────────────────────────────────────

  Future<bool> export(AppData data) async {
    try {
      data.lastExported = DateTime.now();
      final jsonStr =
          const JsonEncoder.withIndent('  ').convert(data.toJson());

      if (kIsWeb) {
        // Web: not fully supported
        return false;
      }

      final dir = await getTemporaryDirectory();
      final exportFile = File('${dir.path}/TechnoGM_backup.json');
      await exportFile.writeAsString(jsonStr);

      final result = await Share.shareXFiles(
        [XFile(exportFile.path, mimeType: 'application/json')],
        subject: 'TechnoGM Workout Data Backup',
        text:
            'My TechnoGM workout data — save this to Google Drive or OneDrive to restore later.',
      );

      return result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed;
    } catch (e) {
      debugPrint('StorageService.export error: $e');
      return false;
    }
  }

  // ─── Import ────────────────────────────────────────────────────────────────

  Future<AppData?> import() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      String content;

      if (result.files.single.bytes != null) {
        content = utf8.decode(result.files.single.bytes!);
      } else if (result.files.single.path != null) {
        content = await File(result.files.single.path!).readAsString();
      } else {
        return null;
      }

      final json = jsonDecode(content) as Map<String, dynamic>;
      return AppData.fromJson(json);
    } catch (e) {
      debugPrint('StorageService.import error: $e');
      return null;
    }
  }

  // ─── Clear all data ────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_prefKey);
        return;
      }
      final file = await _getFile();
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('StorageService.clearAll error: $e');
    }
  }
}
