import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/organization.dart';
import '../providers/task_provider.dart';
import 'project_detail_screen.dart';

class OrganizationScreen extends StatelessWidget {
  final bool projects;
  const OrganizationScreen({super.key, required this.projects});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<TaskProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(projects ? 'Projects' : 'Areas'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
        children: [
          if (projects) ...[
            for (final area in state.areas) ...[
              _AreaLabel(area: area),
              for (final project in state.projects.where((item) => item.areaId == area.id)) _ProjectRow(project: project),
            ],
            if (state.projects.any((item) => item.areaId == null))
              const Padding(
                padding: EdgeInsets.only(top: 18, bottom: 6),
                child: Text('Unassigned'),
              ),
            for (final project in state.projects.where((item) => item.areaId == null)) _ProjectRow(project: project),
          ] else ...[
            for (final area in state.areas)
              _AreaRow(
                area: area,
                projectCount: state.projects.where((item) => item.areaId == area.id).length,
              ),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _create(context),
            icon: const Icon(Icons.add),
            label: Text(projects ? 'New project' : 'New area'),
          ),
        ],
      ),
    );
  }
  void _create(BuildContext context) {
    final title = TextEditingController();
    int? areaId;
    showDialog<void>(context: context, builder: (dialog) => StatefulBuilder(builder: (_, setState) => AlertDialog(title: Text(projects ? 'New project' : 'New area'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, autofocus: true, decoration: InputDecoration(hintText: projects ? 'What outcome are you working toward?' : 'e.g. Health, Home, Work')), if (projects) DropdownButtonFormField<int?>(value: areaId, decoration: const InputDecoration(labelText: 'Area (optional)'), items: [const DropdownMenuItem(value: null, child: Text('No area')), ...context.read<TaskProvider>().areas.map((area) => DropdownMenuItem(value: area.id, child: Text(area.title)))], onChanged: (value) => setState(() => areaId = value))]), actions: [TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('Cancel')), TextButton(onPressed: () async { if (title.text.trim().isEmpty) return; if (projects) { await context.read<TaskProvider>().addProject(Project(title: title.text.trim(), areaId: areaId)); } else { await context.read<TaskProvider>().addArea(Area(title: title.text.trim())); } if (dialog.mounted) Navigator.pop(dialog); }, child: const Text('Create'))])));
  }
}
class _AreaLabel extends StatelessWidget { const _AreaLabel({required this.area}); final Area area; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 18, bottom: 6), child: Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: Color(area.accentColor), shape: BoxShape.circle)), const SizedBox(width: 8), Text(area.title, style: Theme.of(context).textTheme.labelLarge)])); }
class _AreaRow extends StatelessWidget { const _AreaRow({required this.area, required this.projectCount}); final Area area; final int projectCount; @override Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(area.accentColor), shape: BoxShape.circle)), title: Text(area.title), trailing: Text('$projectCount', style: Theme.of(context).textTheme.bodyMedium)); }
class _ProjectRow extends StatelessWidget {
  const _ProjectRow({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Checkbox(
          value: project.isCompleted,
          onChanged: (_) => context.read<TaskProvider>().toggleProject(project),
        ),
        title: Text(
          project.title,
          style: TextStyle(decoration: project.isCompleted ? TextDecoration.lineThrough : null),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
        ),
      );
}
