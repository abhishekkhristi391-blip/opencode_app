import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/models.dart';
import 'chat.dart';
import 'markdown.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

class CommandsPage extends StatelessWidget {
  const CommandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final cmds = store.commands;

    return RefreshIndicator(
      onRefresh: store.refreshCommands,
      child: cmds.isEmpty
          ? ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                const EmptyHint(
                  icon: Icons.code,
                  title: 'Koi command nahi',
                  message: 'Project me .opencode/command/ ya ~/.config/opencode/command/ me markdown command files daalo.',
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: OCSpace.xl),
              children: [
                SectionTitle('${cmds.length} commands'),
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
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: OCSpace.screenX,
        vertical: OCSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: OCColors.surface,
        borderRadius: BorderRadius.circular(OCRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        backgroundColor: OCColors.surface,
        collapsedBackgroundColor: OCColors.surface,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const OCIconTile(
          icon: Icons.code,
          accent: OCAccent.purple,
          size: 32,
        ),
        title: Text(cmd.name, style: OCTypography.h3),
        subtitle: Text(
          cmd.description.isEmpty ? cmd.source : cmd.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: OCTypography.caption,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              OCSpace.screenX,
              0,
              OCSpace.screenX,
              OCSpace.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (cmd.template.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 260),
                    padding: const EdgeInsets.all(OCSpace.md),
                    decoration: BoxDecoration(
                      color: OCColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(OCRadius.inner),
                    ),
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          cmd.template,
                          style: OCTypography.mono(size: 11.5),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: OCSpace.md),
                Row(
                  children: [
                    if (cmd.agent.isNotEmpty)
                      Expanded(child: InfoRow('agent', cmd.agent)),
                    if (cmd.model.isNotEmpty)
                      Expanded(child: InfoRow('model', cmd.model)),
                  ],
                ),
                OCButton(
                  onPressed: () async {
                    final args = await promptText(
                      context,
                      title: '/${cmd.name} ke arguments',
                      hint: cmd.template.contains(r'$ARGUMENTS')
                          ? 'arguments likho'
                          : 'optional',
                    );
                    if (args == null) return;
                    Navigator.pop(context);
                    await store.runCommand(cmd.name, args);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatPage()),
                      );
                    }
                  },
                  icon: Icons.play_arrow,
                  label: '/${cmd.name} chalao',
                  variant: OCButtonVariant.primaryOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skills browser (read-only listing from `GET /skill`).
class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    if (store.skills.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Skills (${store.skills.length})'),
        for (final s in store.skills)
          ExpansionTile(
            dense: true,
            leading: const OCIconTile(
              icon: Icons.auto_awesome_outlined,
              accent: OCAccent.yellow,
              size: 30,
              iconSize: 16,
            ),
            title: Text(
              s.name,
              style: OCTypography.caption.copyWith(color: OCColors.textPrimary),
            ),
            subtitle: s.path.isEmpty
                ? null
                : Text(s.path, style: OCTypography.micro),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  OCSpace.screenX,
                  0,
                  OCSpace.screenX,
                  OCSpace.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Markdown(
                      s.description,
                      base: OCTypography.caption.copyWith(
                        color: OCColors.textSecondary,
                      ),
                      onLink: (url) => launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    const SizedBox(height: OCSpace.sm),
                    OCButton(
                      onPressed: () async {
                        await store.send(
                          'Skill "${s.name}" use karke kaam karo.',
                        );
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChatPage()),
                          );
                        }
                      },
                      icon: Icons.bolt,
                      label: '${s.name} use karo',
                      variant: OCButtonVariant.primaryGradient,
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
