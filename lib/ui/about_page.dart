import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../main.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

/// Version and connection status. Reached from More.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final accent = store.online ? OCAccent.green : OCAccent.red;

    return ListView(
      padding: const EdgeInsets.only(bottom: OCSpace.xxxl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            OCSpace.screenX,
            OCSpace.lg,
            OCSpace.screenX,
            0,
          ),
          child: OCCard(
            child: Column(
              children: [
                const OCIconTile(
                  icon: Icons.bolt,
                  accent: OCAccent.orange,
                  size: 64,
                  iconSize: 30,
                  solid: true,
                ),
                const SizedBox(height: OCSpace.md),
                Text(
                  S.appName,
                  style: OCTypography.h2.copyWith(color: OCColors.textPrimary),
                ),
                const SizedBox(height: OCSpace.xs),
                Text(
                  '${S.aboutVersion} ${S.appVersion}',
                  style: OCTypography.caption,
                ),
                const SizedBox(height: OCSpace.lg),
                Text(
                  S.aboutDescription,
                  textAlign: TextAlign.center,
                  style: OCTypography.caption.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SectionTitle(S.aboutStatus),
        OCCard(
          margin: const EdgeInsets.symmetric(horizontal: OCSpace.screenX),
          padding: const EdgeInsets.all(OCSpace.lg),
          child: Column(
            children: [
              Row(
                children: [
                  OCIconTile(
                    icon: store.online
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    accent: accent,
                    size: 32,
                    iconSize: 17,
                  ),
                  const SizedBox(width: OCSpace.md),
                  Expanded(
                    child: Text(
                      store.online ? S.serverOnline : S.serverOffline,
                      style: OCTypography.bodyStrong.copyWith(
                        color: OCColors.textPrimary,
                      ),
                    ),
                  ),
                  OCButton(
                    onPressed: store.connect,
                    icon: Icons.refresh,
                    label: S.reconnect,
                    variant: OCButtonVariant.ghostOutline,
                    expand: false,
                    height: OCSpace.tapTarget,
                  ),
                ],
              ),
              const SizedBox(height: OCSpace.md),
              const Divider(height: 1),
              const SizedBox(height: OCSpace.sm),
              InfoRow(S.aboutEndpoint, store.baseUrl, mono: true),
              InfoRow(
                S.aboutServer,
                store.serverVersion.isEmpty ? S.dash : store.serverVersion,
                mono: true,
              ),
              InfoRow(
                S.aboutProject,
                store.paths?.directory ?? S.dash,
                mono: true,
              ),
              InfoRow(
                S.aboutBranch,
                store.vcs?.isRepo == true ? store.vcs!.branch : S.notARepoShort,
                mono: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
