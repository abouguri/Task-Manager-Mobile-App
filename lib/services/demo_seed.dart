import '../models/organization.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

/// Whether this build should populate itself with sample content on first run.
///
/// Set by `scripts/vercel-build.sh` for the public demo only. Deliberately a
/// compile-time flag rather than `kIsWeb`: running the app locally in a browser
/// should still start empty, and a real install must never see any of this.
const bool kSeedDemoData = bool.fromEnvironment('DEMO_SEED');

/// Fills an empty store with a plausible week of work.
///
/// The demo build keeps everything in memory, so this runs on every page load
/// and a visitor can change anything without consequence. It is a no-op if the
/// store already holds something, so it can never duplicate or overwrite.
Future<void> seedDemoData(TaskProvider provider) async {
  if (provider.allTasks.isNotEmpty ||
      provider.areas.isNotEmpty ||
      provider.projects.isNotEmpty) {
    return;
  }

  final now = DateTime.now();
  DateTime day(int offset, [int hour = 0, int minute = 0]) =>
      DateTime(now.year, now.month, now.day + offset, hour, minute);

  await provider.addArea(const Area(title: 'Family', accentColor: 0xFF007AFF));
  await provider.addArea(const Area(title: 'Work', accentColor: 0xFFFF3B5C));
  final family = provider.areas.firstWhere((a) => a.title == 'Family');
  final work = provider.areas.firstWhere((a) => a.title == 'Work');

  await provider.addProject(Project(
      title: 'Vacation in Rome',
      areaId: family.id,
      headings: const ['Planning', 'Get packed', 'Things to buy']));
  await provider
      .addProject(Project(title: 'Throw Party for Eve', areaId: family.id));
  await provider.addProject(Project(
      title: 'Prepare Presentation',
      areaId: work.id,
      headings: const ['Research', 'Write']));
  await provider.addProject(Project(title: 'Onboard Julia', areaId: work.id));

  final rome = provider.projects.firstWhere((p) => p.title == 'Vacation in Rome');
  final party =
      provider.projects.firstWhere((p) => p.title == 'Throw Party for Eve');
  final deck =
      provider.projects.firstWhere((p) => p.title == 'Prepare Presentation');
  final julia = provider.projects.firstWhere((p) => p.title == 'Onboard Julia');

  final familyId = '${family.id}';
  final workId = '${work.id}';

  // --- Today, including one overdue deadline so the red badge is visible ---
  await provider.addTask(Task(
      title: "Borrow Emma's travel guide",
      when: TaskWhen.today,
      projectId: '${rome.id}',
      areaId: familyId));
  await provider.addTask(Task(
      title: 'Finish expense report',
      when: TaskWhen.today,
      areaId: workId,
      deadline: day(0)));
  await provider.addTask(Task(
      title: 'Confirm conference call',
      when: TaskWhen.today,
      areaId: workId,
      scheduledFor: day(0, 11)));
  await provider.addTask(Task(
      title: 'Organize team lunch',
      when: TaskWhen.today,
      projectId: '${julia.id}'));
  await provider.addTask(Task(
      title: 'Review milestones from last quarter',
      when: TaskWhen.today,
      projectId: '${deck.id}'));

  await provider.addTask(Task(
      title: 'Make dinner reservation',
      when: TaskWhen.evening,
      projectId: '${party.id}'));
  await provider.addTask(Task(
      title: "Pack bag for Olivia's field trip",
      when: TaskWhen.evening,
      areaId: familyId));

  // --- Upcoming, spread over the next few days ---
  await provider.addTask(Task(
      title: 'Prepare interview questions',
      when: TaskWhen.date,
      scheduledFor: day(1),
      areaId: workId));
  await provider.addTask(Task(
      title: 'Make reservation for dinner',
      when: TaskWhen.date,
      scheduledFor: day(1),
      projectId: '${party.id}'));
  await provider.addTask(Task(
      title: 'Buy movie tickets', when: TaskWhen.date, scheduledFor: day(2)));
  await provider.addTask(Task(
      title: 'Get copy of signed contract',
      when: TaskWhen.date,
      scheduledFor: day(2),
      projectId: '${julia.id}'));
  await provider.addTask(Task(
      title: 'Send invitations',
      when: TaskWhen.date,
      scheduledFor: day(3),
      projectId: '${party.id}',
      deadline: day(6),
      checklist: const [
        ChecklistItem(title: 'Draft the guest list', isCompleted: true),
        ChecklistItem(title: 'Design the card', isCompleted: true),
        ChecklistItem(title: 'Send them'),
        ChecklistItem(title: 'Chase replies'),
        ChecklistItem(title: 'Final head count'),
      ]));
  await provider.addTask(Task(
      title: 'Order a cake',
      when: TaskWhen.date,
      scheduledFor: day(3),
      projectId: '${party.id}'));
  await provider.addTask(Task(
      title: 'Call Mom and Dad',
      when: TaskWhen.date,
      scheduledFor: day(4),
      areaId: familyId,
      checklist: const [
        ChecklistItem(title: 'Ask about the garden'),
        ChecklistItem(title: 'Confirm Easter'),
      ]));

  // --- Inbox ---
  await provider.addTask(Task(title: 'Research writing workshops'));
  await provider.addTask(Task(title: 'Look into the bike service'));

  // --- Vacation in Rome, filled out so headings have something to show ---
  Future<void> rome_(String title,
      {required String heading,
      String? notes,
      List<String> tags = const [],
      List<ChecklistItem> checklist = const []}) {
    return provider.addTask(Task(
        title: title,
        when: TaskWhen.anytime,
        projectId: '${rome.id}',
        areaId: familyId,
        heading: heading,
        description: notes,
        tags: tags,
        checklist: checklist));
  }

  await rome_('Book flights',
      heading: 'Planning',
      notes: 'Aim for the early flight so we land before lunch.');
  await rome_("Borrow Sarah's travel guide", heading: 'Planning');
  await rome_('Book a hotel room',
      heading: 'Planning', notes: 'Somewhere near Trastevere.');
  await rome_('Pack carry-on',
      heading: 'Get packed',
      notes: 'Take the small gray messenger bag. The seat has a USB port, so '
          "there's no need to pack a charger.",
      tags: const ['packing', 'travel'],
      checklist: const [
        ChecklistItem(title: 'Passport'),
        ChecklistItem(title: 'iPad'),
        ChecklistItem(title: 'Sleep mask'),
      ]);
  await rome_('Pack suitcase',
      heading: 'Get packed',
      checklist: const [
        ChecklistItem(title: 'Shoes'),
        ChecklistItem(title: 'Jacket'),
      ]);
  await rome_('Extra camera battery', heading: 'Things to buy');
  await rome_('Power adapter',
      heading: 'Things to buy', tags: const ['travel']);

  // --- A couple parked for Someday, so the list is not empty ---
  await provider
      .addTask(Task(title: 'Learn to make pasta', when: TaskWhen.someday));
  await provider.addTask(
      Task(title: 'Look at that photography course', when: TaskWhen.someday));
}
