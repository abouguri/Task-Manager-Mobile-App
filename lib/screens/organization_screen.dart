import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../design/taskflow_tokens.dart';
import '../models/organization.dart';
import '../providers/task_provider.dart';
import '../widgets/tf_widgets.dart';
import 'project_detail_screen.dart';

/// Areas and projects, in the redesign's language.
///
/// In project mode each area becomes a blue section header over a hairline —
/// the same device Project detail uses for its headings — so the hierarchy
/// reads without any card chrome.
class OrganizationScreen extends StatelessWidget {
  const OrganizationScreen({super.key, required this.projects});

  final bool projects;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final state = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: palette.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                TfNavBar(onBack: () => Navigator.pop(context)),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(TaskFlowTokens.gutter,
                        14, TaskFlowTokens.gutter, 100),
                    children: [
                      TfScreenTitle(
                        title: projects ? 'Projects' : 'Areas',
                        icon: projects
                            ? Icons.folder_rounded
                            : Icons.layers_rounded,
                        color: projects
                            ? TaskFlowTokens.primary
                            : TaskFlowTokens.anytimeAccent,
                      ),
                      const SizedBox(height: 6),
                      if (projects)
                        ..._projectSections(context, state)
                      else
                        ..._areaRows(context, state),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 24,
              bottom: 30,
              child: TfFab(onTap: () => _create(context)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _projectSections(BuildContext context, TaskProvider state) {
    final palette = context.palette;
    final unassigned =
        state.projects.where((project) => project.areaId == null).toList();

    return [
      for (final area in state.areas) ...[
        TfSectionHeader(
          title: area.title,
          onAdd: () => _create(context, areaId: area.id),
        ),
        ..._rowsFor(
          context,
          state,
          state.projects
              .where((project) => project.areaId == area.id)
              .toList(),
        ),
      ],
      if (unassigned.isNotEmpty) ...[
        const TfSectionHeader(title: 'No area'),
        ..._rowsFor(context, state, unassigned),
      ],
      if (state.areas.isEmpty && unassigned.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text('No projects yet.',
              style: TaskFlowText.meta(palette.textQuaternary)),
        ),
    ];
  }

  List<Widget> _rowsFor(
      BuildContext context, TaskProvider state, List<Project> items) {
    if (items.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 2),
          child: Text('No projects yet.',
              style: TaskFlowText.meta(context.palette.textQuaternary)),
        ),
      ];
    }
    return [for (final project in items) _ProjectRow(project: project)];
  }

  List<Widget> _areaRows(BuildContext context, TaskProvider state) {
    final palette = context.palette;
    if (state.areas.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text('No areas yet.',
              style: TaskFlowText.meta(palette.textQuaternary)),
        ),
      ];
    }

    return [
      const SizedBox(height: 10),
      for (final area in state.areas)
        _AreaRow(
          area: area,
          projectCount: state.projects
              .where((project) => project.areaId == area.id)
              .length,
        ),
    ];
  }

  Future<void> _create(BuildContext context, {int? areaId}) async {
    final provider = context.read<TaskProvider>();
    final title = TextEditingController();
    var selectedArea = areaId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: Text(projects ? 'New project' : 'New area'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: projects
                      ? 'What outcome are you working toward?'
                      : 'e.g. Health, Home, Work',
                ),
                onSubmitted: (_) => Navigator.pop(dialog, true),
              ),
              if (projects) ...[
                const SizedBox(height: 20),
                DropdownButtonFormField<int?>(
                  // Stays on `value` rather than the newer `initialValue`:
                  // scripts/vercel-build.sh pins an SDK that predates it.
                  // ignore: deprecated_member_use
                  value: selectedArea,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Area (optional)'),
                  items: [
                    const DropdownMenuItem<int?>(
                        value: null, child: Text('No area')),
                    ...provider.areas.map((area) => DropdownMenuItem<int?>(
                        value: area.id, child: Text(area.title))),
                  ],
                  onChanged: (value) => setState(() => selectedArea = value),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialog, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(dialog, true),
                child: const Text('Create')),
          ],
        ),
      ),
    );

    final value = title.text.trim();
    title.dispose();
    if (confirmed != true || value.isEmpty) return;

    if (projects) {
      await provider
          .addProject(Project(title: value, areaId: selectedArea));
    } else {
      await provider.addArea(Area(title: value));
    }
  }
}

class _AreaRow extends StatelessWidget {
  const _AreaRow({required this.area, required this.projectCount});

  final Area area;
  final int projectCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(Icons.layers_outlined, size: 18, color: palette.textTertiary),
          const SizedBox(width: 13),
          Expanded(
            child: Text(area.title,
                style: TaskFlowText.areaTitle(palette.textPrimary)),
          ),
          if (projectCount > 0)
            Text('$projectCount',
                style: TextStyle(
                    color: palette.textTertiary, fontSize: 16, height: 1)),
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final provider = context.watch<TaskProvider>();
    final tasks = provider.allTasks
        .where((task) => int.tryParse(task.projectId ?? '') == project.id);
    final total = tasks.length;
    final done = tasks.where((task) => task.isCompleted).length;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            TfProjectRing(progress: total == 0 ? 0 : done / total),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                project.title,
                style: TaskFlowText.projectTitle(project.isCompleted
                    ? palette.textTertiary
                    : palette.textPrimary),
              ),
            ),
            if (project.isCompleted)
              Icon(Icons.check_rounded, size: 16, color: palette.success),
          ],
        ),
      ),
    );
  }
}
