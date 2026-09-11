import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:map_to_poster/data/models/project_entry.dart';
import 'package:map_to_poster/screens/layout_selection.dart';

class ProjectStorageService {
  static const _projectsKey = 'poster_projects';

  Future<List<ProjectEntry>> getProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_projectsKey) ?? [];

    return raw
        .map(
          (entry) =>
              ProjectEntry.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> addProject(ProjectEntry project) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_projectsKey) ?? [];

    raw.removeWhere((entry) {
      final decoded = jsonDecode(entry) as Map<String, dynamic>;
      return decoded['map_id'] == project.mapId;
    });

    raw.insert(0, jsonEncode(project.toJson()));

    await prefs.setStringList(_projectsKey, raw);
  }

  Future<void> updateProjectStyle({
    required String mapId,
    required String themeSlug,
    required PosterLayout posterLayout,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_projectsKey) ?? [];

    final updated = raw.map((entry) {
      final decoded = ProjectEntry.fromJson(
        jsonDecode(entry) as Map<String, dynamic>,
      );

      if (decoded.mapId != mapId) return entry;

      final merged = decoded.copyWith(
        themeSlug: themeSlug,
        posterLayout: posterLayout,
      );

      return jsonEncode(merged.toJson());
    }).toList();

    await prefs.setStringList(_projectsKey, updated);
  }
}
