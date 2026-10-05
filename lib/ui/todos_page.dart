import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import 'app_scope.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final todos = store.todos;
    final done = todos.where((t) => t.done).length;

    return RefreshIndicator(
      onRefresh: store.refreshTodos,
      child: todos.isEmpty
          ? ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                EmptyHint(
                  icon: Icons.checklist,
                  title: S.todosEmptyTitle,
                  message: store.current == null
                      ? S.todosEmptyNoChat
                      : S.todosEmptyHint,
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: OCSpace.xl),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OCSpace.screenX,
                    OCSpace.md,
                    OCSpace.screenX,
                    OCSpace.sm,
                  ),
                  child: Row(
                    children: [
                      Text(
                        S.tasksProgress(done, todos.length),
                        style: OCTypography.bodyStrong,
                      ),
                      const Spacer(),
                      if (todos.isNotEmpty)
                        SizedBox(
                          width: 104,
                          child: OCProgressBar(
                            value: todos.isEmpty ? 0 : done / todos.length,
                            height: 6,
                            animate: false,
                            semanticLabel: S.tasksProgressSemantics(
                              done,
                              todos.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Active first, then pending, then completed.
                if (todos.any((t) => t.active)) ...[
                  const SectionTitle('In progress'),
                  for (final t in todos.where((t) => t.active))
                    _TodoTile(todo: t),
                ],
                if (todos.any((t) => !t.active && !t.done)) ...[
                  const SectionTitle('Pending'),
                  for (final t in todos.where((t) => !t.active && !t.done))
                    _TodoTile(todo: t),
                ],
                if (todos.any((t) => t.done)) ...[
                  const SectionTitle('Completed'),
                  for (final t in todos.where((t) => t.done))
                    _TodoTile(todo: t),
                ],
                if (store.current != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OCSpace.screenX,
                      OCSpace.sm,
                      OCSpace.screenX,
                      0,
                    ),
                    child: Text(
                      S.todosSession(store.current!.label),
                      style: OCTypography.micro,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final Todo todo;
  const _TodoTile({required this.todo});

  @override
  Widget build(BuildContext context) {
    final accent = todo.done
        ? OCAccent.neutral
        : todo.active
        ? OCAccent.green
        : OCAccent.neutral;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OCSpace.screenX,
        vertical: OCSpace.xxs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: todo.active ? OCColors.greenTint : OCColors.surface,
          borderRadius: BorderRadius.circular(OCRadius.inner),
        ),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OCRadius.inner),
          ),
          leading: OCIconTile(
            icon: todo.done
                ? Icons.check_circle
                : todo.active
                ? Icons.play_circle_fill
                : Icons.radio_button_unchecked,
            accent: accent,
            size: 30,
            iconSize: 17,
          ),
          title: Text(
            todo.content,
            style: OCTypography.caption.copyWith(
              color: todo.done ? OCColors.textTertiary : OCColors.textPrimary,
              decoration: todo.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: todo.priority.isEmpty
              ? null
              : Text(todo.priority, style: OCTypography.micro),
        ),
      ),
    );
  }
}
