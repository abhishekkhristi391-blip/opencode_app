import 'package:flutter/material.dart';

import '../main.dart';
import '../models/models.dart';
import 'widgets.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
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
                  title: 'Task list khaali',
                  message: store.current == null
                      ? 'Pehle koi chat start karo.'
                      : 'Agent jab todowrite tool use karega, tasks yahan live dikhenge.',
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      Text('$done / ${todos.length} done',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (todos.isNotEmpty)
                        SizedBox(
                          width: 90,
                          child: LinearProgressIndicator(
                            value: todos.isEmpty ? 0 : done / todos.length,
                            minHeight: 5,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
                // Active first, then pending, then completed.
                if (todos.any((t) => t.active)) ...[
                  const SectionTitle('In progress'),
                  for (final t in todos.where((t) => t.active)) _TodoTile(todo: t),
                ],
                if (todos.any((t) => !t.active && !t.done)) ...[
                  const SectionTitle('Pending'),
                  for (final t in todos.where((t) => !t.active && !t.done)) _TodoTile(todo: t),
                ],
                if (todos.any((t) => t.done)) ...[
                  const SectionTitle('Completed'),
                  for (final t in todos.where((t) => t.done)) _TodoTile(todo: t),
                ],
                if (store.current != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text('Session: ${store.current!.label}',
                        style: TextStyle(fontSize: 11, color: cs.outline)),
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
    final cs = Theme.of(context).colorScheme;
    final color = todo.done
        ? cs.outline
        : todo.active
            ? const Color(0xFF3DDC84)
            : cs.onSurfaceVariant;

    return ListTile(
      dense: true,
      leading: Icon(
        todo.done
            ? Icons.check_circle
            : todo.active
                ? Icons.play_circle_fill
                : Icons.radio_button_unchecked,
        size: 19,
        color: color,
      ),
      title: Text(
        todo.content,
        style: TextStyle(
          fontSize: 13.5,
          color: todo.done ? cs.outline : cs.onSurface,
          decoration: todo.done ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: todo.priority.isEmpty
          ? null
          : Text(todo.priority, style: const TextStyle(fontSize: 10.5)),
    );
  }
}
