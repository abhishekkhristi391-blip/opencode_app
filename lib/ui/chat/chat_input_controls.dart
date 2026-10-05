part of '../chat.dart';

/// TextField with inline autocomplete for `/commands` and `@files`.
class SlashTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final OcStore store;
  final VoidCallback onSubmit;
  final String placeholder;
  const SlashTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.store,
    required this.onSubmit,
    required this.placeholder,
  });

  @override
  State<SlashTextField> createState() => _SlashTextFieldState();
}

class _SlashTextFieldState extends State<SlashTextField> {
  List<String> _suggestions = [];
  String _mode = '';
  List<String> _files = [];
  late final VoidCallback _focusListener;
  Timer? _fileSearchTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _focusListener = () {
      if (widget.focusNode.hasFocus) _onChanged();
    };
    widget.focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    widget.focusNode.removeListener(_focusListener);
    _fileSearchTimer?.cancel();
    super.dispose();
  }

  void _onChanged() {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    if (!sel.isValid || !sel.isCollapsed) return _set([]);

    final upto = text.substring(0, sel.baseOffset);
    final slash = RegExp(r'(?:^|\s)/([\w-]*)$').firstMatch(upto);
    if (slash != null) {
      final q = slash.group(1)!.toLowerCase();
      final names = widget.store.commands.map((c) => c.name).toSet()
        ..addAll(const ['init', 'compact', 'undo', 'redo', 'share', 'clear']);
      return _set(
        names.where((n) => n.startsWith(q)).take(8).toList(),
        mode: '/',
      );
    }
    final at = RegExp(r'(?:^|\s)@([\w./-]*)$').firstMatch(upto);
    if (at != null) {
      final q = at.group(1)!.toLowerCase();
      _mode = '@';
      _debouncedSearchFiles(q);
      return;
    }
    _set([]);
  }

  void _debouncedSearchFiles(String q) {
    _fileSearchTimer?.cancel();
    _fileSearchTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _searchFiles(q);
    });
  }

  void _searchFiles(String q) async {
    try {
      final list = await widget.store.api.findFiles(
        q.isEmpty ? ' ' : q,
        limit: 8,
      );
      if (!mounted || _mode != '@') return;
      setState(() => _files = list);
    } catch (e) {
      debugPrint('File search failed: $e');
    }
  }

  void _set(List<String> s, {String mode = ''}) {
    if (!mounted) return;
    if (s.length == _suggestions.length &&
        mode == _mode &&
        s.join() == _suggestions.join())
      return;
    setState(() {
      _suggestions = s;
      _mode = mode;
    });
  }

  void _apply(String token) {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    if (!sel.isValid) return;
    final upto = text.substring(0, sel.baseOffset);
    final pattern = _mode == '@'
        ? RegExp(r'(?:^|\s)@[\w./-]*$')
        : RegExp(r'(?:^|\s)/[\w-]*$');
    final m = pattern.firstMatch(upto);
    if (m == null) return;
    final start = sel.baseOffset - m.group(0)!.length;
    final prefix = _mode == '@' ? '' : (m.group(0)!.startsWith(' ') ? '' : '');
    final insert = '$_mode$token ';
    final next = text.replaceRange(start, sel.baseOffset, '$prefix$insert');
    widget.controller.text = next;
    widget.controller.selection = TextSelection.collapsed(
      offset: start + insert.length,
    );
    _set([]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final showList =
        _suggestions.isNotEmpty || (_mode == '@' && _files.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          minLines: 1,
          maxLines: 6,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          onSubmitted: (_) => widget.onSubmit(),
          style: OCTypography.body.copyWith(color: t.ink, height: 1.4),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: OCTypography.body.copyWith(color: t.mute),
            // Borderless: the enclosing composer container already draws the
            // 24px rounded box and its focus ring.
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
        // Rendered above the tools row rather than below it, so accepting a
        // completion never resizes the composer's bottom edge.
        if (showList)
          Container(
            constraints: const BoxConstraints(maxHeight: 190),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                for (final s in _suggestions)
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: LIcon(LI.terminal, size: 15, color: t.mute),
                    title: Text(
                      s,
                      style: OCTypography.caption.copyWith(color: t.ink),
                    ),
                    subtitle: widget.store.commands
                        .where((c) => c.name == s)
                        .map(
                          (c) => Text(
                            c.description,
                            style: OCTypography.micro.copyWith(color: t.mute),
                          ),
                        )
                        .firstOrNull,
                    onTap: () => _apply(s),
                  ),
                for (final f in _files)
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: LIcon(LI.folder, size: 15, color: t.mute),
                    title: Text(
                      baseName(f),
                      style: OCTypography.caption.copyWith(color: t.ink),
                    ),
                    subtitle: Text(
                      f,
                      style: OCTypography.micro.copyWith(color: t.mute),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _apply(f),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
