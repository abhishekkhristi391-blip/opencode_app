import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/models.dart';
import 'chat.dart';
import 'markdown.dart';
import 'widgets.dart';

class CommandsPage extends StatelessWidget {
  const CommandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final cmds = store.commands;

    return RefreshIndicator(
      onRefresh: store.refreshCommands,
      child: cmds.isEmpty
          ? ListView(children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              const EmptyHint(
                  icon: Icons.code,
                  title: 'Koi command nahi',
                  message: 'Project me .opencode/command/ ya ~/.config/opencode/command/ me markdown command files daalo.'),
            ])
          : ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Text('${cmds.length} commands', style: TextStyle(fontSize: 12, color: cs.outline)),
                ),
                for (final c in cmds) _CommandTile(cmd: c),
              ],
            ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  final CommandInfo cmd;
  const _CommandTile({required this.cmd});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    return ExpansionTile(
      leading: const Icon(Icons.code, size: 19),
      title: Text(cmd.name, style: const TextStyle(fontSize: 14)),
      subtitle: Text(cmd.description.isEmpty ? cmd.source : cmd.description,
          maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (cmd.template.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 260),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(cmd.template,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, height: 1.45)),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (cmd.agent.isNotEmpty)
                    Expanded(child: InfoRow('agent', cmd.agent)),
                  if (cmd.model.isNotEmpty) Expanded(child: InfoRow('model', cmd.model)),
                ],
              ),
              FilledButton.icon(
                onPressed: () async {
                  final args = await promptText(context,
                      title: '/${cmd.name} ke arguments',
                      hint: cmd.template.contains(r'$ARGUMENTS') ? 'arguments likho' : 'optional');
                  if (args == null) return;
                  Navigator.pop(context);
                  await store.runCommand(cmd.name, args);
                  if (context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
                  }
                },
                icon: const Icon(Icons.play_arrow, size: 17),
                label: Text('/${cmd.name} chalao', style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Skills browser (read-only listing from `GET /skill`).
class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    if (store.skills.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Skills (${store.skills.length})'),
        for (final s in store.skills)
          ExpansionTile(
            dense: true,
            leading: const Icon(Icons.auto_awesome_outlined, size: 18),
            title: Text(s.name, style: const TextStyle(fontSize: 13.5)),
            subtitle: s.path.isEmpty ? null : Text(s.path, style: TextStyle(fontSize: 10.5, color: cs.outline)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Markdown(s.description, base: Theme.of(context).textTheme.bodySmall, onLink: (url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await store.send('Skill "${s.name}" use karke kaam karo.');
                        if (context.mounted) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
                        }
                      },
                      icon: const Icon(Icons.bolt, size: 16),
                      label: Text('${s.name} use karo', style: const TextStyle(fontSize: 12.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
