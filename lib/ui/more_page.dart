import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../main.dart';
import 'about_page.dart';
import 'commands_page.dart';
import 'models_page.dart';
import 'primitives.dart';
import 'settings_page.dart';
import 'theme.dart';
import 'widgets.dart';

/// Everything that is not a top-level tab: commands, models, settings and
/// about. Reached from the last NavigationBar destination.
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: OCSpace.xxxl),
      children: [
        SectionTitle(S.navMore),
        _ConnectionCard(online: store.online, version: store.serverVersion),
        OCListRow(
          title: S.navCommands,
          subtitle: Text(S.aboutCommandsHint, style: OCTypography.micro),
          leadingIcon: Icons.code,
          accent: OCAccent.orange,
          onTap: () => pushScreen(
            context,
            title: S.navCommands,
            child: const CommandsPage(),
          ),
        ),
        OCListRow(
          title: S.navModels,
          subtitle: Text(S.aboutModelsHint, style: OCTypography.micro),
          leadingIcon: Icons.psychology_outlined,
          accent: OCAccent.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ModelsPage()),
          ),
        ),
        OCListRow(
          title: S.navSettings,
          subtitle: Text(S.aboutSettingsHint, style: OCTypography.micro),
          leadingIcon: Icons.settings_outlined,
          accent: OCAccent.orange,
          onTap: () => pushScreen(
            context,
            title: S.navSettings,
            child: const SettingsPage(),
          ),
        ),
        OCListRow(
          title: S.navAbout,
          subtitle: Text(
            store.online
                ? S.serverOnlineVersion(store.serverVersion)
                : S.serverOffline,
            style: OCTypography.micro,
          ),
          leadingIcon: Icons.info_outline,
          accent: store.online ? OCAccent.green : OCAccent.red,
          trailing: const Icon(
            Icons.chevron_right,
            color: OCColors.textTertiary,
          ),
          onTap: () =>
              pushScreen(context, title: S.navAbout, child: const AboutPage()),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            OCSpace.screenX,
            OCSpace.lg,
            OCSpace.screenX,
            0,
          ),
          child: Text(
            '${S.appName} ${S.appVersion}',
            textAlign: TextAlign.center,
            style: OCTypography.micro,
          ),
        ),
      ],
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final bool online;
  final String version;
  const _ConnectionCard({required this.online, required this.version});

  @override
  Widget build(BuildContext context) {
    final accent = online ? OCAccent.green : OCAccent.red;
    return OCCard(
      margin: const EdgeInsets.fromLTRB(
        OCSpace.screenX,
        0,
        OCSpace.screenX,
        OCSpace.md,
      ),
      padding: const EdgeInsets.all(OCSpace.lg),
      child: Row(
        children: [
          OCIconTile(
            icon: online ? Icons.cloud_done_outlined : Icons.cloud_off,
            accent: accent,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(width: OCSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  online ? S.serverOnline : S.serverOffline,
                  style: OCTypography.bodyStrong.copyWith(
                    color: OCColors.textPrimary,
                  ),
                ),
                Text(
                  online
                      ? S.serverOnlineVersion(version)
                      : S.connectionFailedHint,
                  style: OCTypography.micro,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
