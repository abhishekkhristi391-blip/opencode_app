import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'app_scope.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  @override
  void initState() {
    super.initState();
    // Opening the page is the one moment the list must not be taken on trust:
    // it may belong to a session that was opened a while ago, and the events
    // that would have kept it honest are gone with the socket that carried them.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.read(context).refreshTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    // A list that has not been re-read for a while while the agent is running is
    // not worth showing as fact, so go and get it again instead of putting a
    // banner over the list. Post-frame, and a no-op unless it is actually stale.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) store.ensureTodosFresh();
    });
    // The store's own notifications cover app-wide state (which session, whether
    // the agent is running); `todoList` covers the list itself, which changes many
    // times per run and must not drag the rest of the app with it.
    return ListenableBuilder(
      listenable: store.todoList,
      builder: (context, _) => _TodosBody(store: store),
    );
  }
}

class _TodosBody extends StatelessWidget {
  final OcStore store;
  const _TodosBody({required this.store});

  @override
  Widget build(BuildContext context) {
    final todos = store.todos;
    // `cancelled` is neither done nor still-to-do, so it stays out of the count
    // and gets a section of its own instead of pretending to be pending.
    final done = todos.where((t) => t.done).length;
    bool pending(Todo t) => !t.active && !t.done && !t.cancelled;
    Widget section(String title, Iterable<Todo> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title),
        for (final t in items) _TodoTile(todo: t, busy: store.busy),
      ],
    );

    return RefreshIndicator(
      onRefresh: store.refreshTodos,
      child: todos.isEmpty
          ? ListView(
              // Always scrollable, or a list that fits on screen cannot be
              // pulled down and the refresh gesture would silently do nothing.
              physics: const AlwaysScrollableScrollPhysics(),
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
              physics: const AlwaysScrollableScrollPhysics(),
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
                        S.todosProgress(done, todos.length),
                        style: OCTypography.bodyStrong,
                      ),
                      const Spacer(),
                      if (todos.isNotEmpty)
                        SizedBox(
                          width: 104,
                          child: OCProgressBar(
                            value: done / todos.length,
                            height: 6,
                            // The bar is a count, not a spinner: it must not
                            // animate from zero every time a todo lands.
                            animate: false,
                            semanticLabel: S.todosProgressSemantics(
                              done,
                              todos.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Active first, then pending, then finished, then dropped.
                if (todos.any((t) => t.active))
                  section(S.todosInProgress, todos.where((t) => t.active)),
                if (todos.any(pending))
                  section(S.todosPending, todos.where(pending)),
                if (todos.any((t) => t.done))
                  section(S.todosCompleted, todos.where((t) => t.done)),
                if (todos.any((t) => t.cancelled))
                  section(S.todosCancelled, todos.where((t) => t.cancelled)),
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

  /// Drives the live indicator on the task being worked on. False means the
  /// agent is not running, and nothing on this page may then look like it is.
  final bool busy;

  const _TodoTile({required this.todo, required this.busy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OCSpace.screenX,
        vertical: OCSpace.xxs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: todo.active && busy
              ? OCColors.greenTint
              : OCColors.surface,
          borderRadius: BorderRadius.circular(OCRadius.inner),
        ),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OCRadius.inner),
          ),
          leading: _leading(),
          title: Text(
            todo.content,
            style: OCTypography.caption.copyWith(
              color: todo.done || todo.cancelled
                  ? OCColors.textTertiary
                  : OCColors.textPrimary,
              decoration: todo.done || todo.cancelled
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: todo.priority.isEmpty
              ? null
              : Text(todo.priority, style: OCTypography.micro),
        ),
      ),
    );
  }

  Widget _leading() {
    final icon = todo.done
        ? Icons.check_circle
        : todo.cancelled
        ? Icons.cancel_outlined
        : todo.active
        ? Icons.play_circle_fill
        : Icons.radio_button_unchecked;
    final tile = OCIconTile(
      icon: icon,
      accent: todo.active ? OCAccent.green : OCAccent.neutral,
      size: 30,
      iconSize: 17,
    );
    // The breath is the only motion on this page, and it exists only while the
    // agent is actually working on this task.
    if (!todo.active || !busy) return tile;
    return _ActivePulse(child: tile);
  }
}

/// Slow breath on the task in progress. Mounted only while the agent is busy,
/// so a list nobody is working on is completely still.
class _ActivePulse extends StatefulWidget {
  final Widget child;
  const _ActivePulse({required this.child});

  @override
  State<_ActivePulse> createState() => _ActivePulseState();
}

class _ActivePulseState extends State<_ActivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: OCMotion.pulse,
  );

  @override
  void initState() {
    super.initState();
    if (!ocReduceMotion(context)) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(CurvedAnimation(parent: _c, curve: OCMotion.curve)),
    child: widget.child,
  );
}