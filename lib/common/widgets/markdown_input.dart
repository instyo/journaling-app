import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextSelection.collapsed
import 'package:flutter_markdown/flutter_markdown.dart'; // Import for MarkdownBody
// import 'package:url_launcher/url_launcher.dart'; // Uncomment if you want clickable links in preview

/// A simple, reusable Markdown input widget with a toolbar and preview.
///
/// It uses a [TextEditingController] to manage the text content
/// and applies Markdown formatting directly to the text.
class MarkdownInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final int? maxLines;

  const MarkdownInput({
    Key? key,
    required this.controller,
    this.hintText,
    this.maxLines = null, // Allows multiline by default
  }) : super(key: key);

  @override
  State<MarkdownInput> createState() => _MarkdownInputState();
}

class _MarkdownInputState extends State<MarkdownInput> {
  bool _showPreview = false; // State to toggle between editor and preview

  // --- Basic Markdown Formatting (Bold, Italic, Underline) ---
  /// Applies a symmetric prefix/suffix format (e.g., `**text**`).
  /// Handles selection and toggling existing format.
  void _applyFormat(String prefix, String suffix) {
    final TextEditingController controller = widget.controller;
    TextSelection selection = controller.selection;
    String text = controller.text;

    // Normalize selection (ensure baseOffset <= extentOffset)
    if (selection.baseOffset > selection.extentOffset) {
      selection = TextSelection(
        baseOffset: selection.extentOffset,
        extentOffset: selection.baseOffset,
      );
    }

    String selectedText = selection.textInside(text);
    String newText;
    TextSelection newSelection;

    // Check if the selected text (if any) is already wrapped exactly by the format
    bool isAlreadyFormatted =
        selectedText.startsWith(prefix) &&
        selectedText.endsWith(suffix) &&
        selectedText.length >= prefix.length + suffix.length;

    if (isAlreadyFormatted) {
      // Unformat: Remove prefix and suffix
      String unformattedText = selectedText.substring(
        prefix.length,
        selectedText.length - suffix.length,
      );
      newText = text.replaceRange(
        selection.start,
        selection.end,
        unformattedText,
      );
      newSelection = TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.start + unformattedText.length,
      );
    } else if (selectedText.isNotEmpty) {
      // Format: Wrap selected text
      String formattedText = prefix + selectedText + suffix;
      newText = text.replaceRange(
        selection.start,
        selection.end,
        formattedText,
      );
      newSelection = TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.start + prefix.length + selectedText.length,
      );
    } else {
      // Insert: Put format markers and position cursor in between
      newText = text.replaceRange(
        selection.start,
        selection.end,
        prefix + suffix,
      );
      newSelection = TextSelection.collapsed(
        offset: selection.start + prefix.length,
      );
    }

    // Update the controller's value, which will rebuild the TextField
    controller.value = TextEditingValue(
      text: newText,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }

  // --- Line-based Markdown Formatting (Heading, Bullet) ---
  /// Toggles a line prefix (e.g., `# `, `* `).
  /// Works based on the current line containing the cursor.
  void _toggleLinePrefix(String prefix) {
    final TextEditingController controller = widget.controller;
    String text = controller.text;
    int cursorPosition = controller.selection.start;

    // Find the start and end of the current line
    int lineStart = text.lastIndexOf('\n', cursorPosition - 1) + 1;
    int lineEnd = text.indexOf('\n', cursorPosition);
    if (lineEnd == -1) lineEnd = text.length;

    String line = text.substring(lineStart, lineEnd);
    String newText;
    TextSelection newSelection;

    // Check if the line already starts with the prefix
    if (line.startsWith(prefix)) {
      // Remove prefix
      newText = text.replaceRange(
        lineStart,
        lineEnd,
        line.substring(prefix.length),
      );
      newSelection = TextSelection.collapsed(
        offset: (cursorPosition - prefix.length).clamp(0, newText.length),
      ); // Clamp to prevent out of bounds
    } else {
      // Add prefix
      newText = text.replaceRange(lineStart, lineEnd, prefix + line);
      newSelection = TextSelection.collapsed(
        offset: cursorPosition + prefix.length,
      );
    }

    controller.value = TextEditingValue(
      text: newText,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }

  // --- Complex Insertion (Link, Image) ---
  /// Inserts a markdown template like `[text](url)` or `![alt](url)`.
  /// Places the cursor inside the `()` for the URL.
  void _insertComplexFormat(String formatTemplate, {String? textPlaceholder}) {
    final TextEditingController controller = widget.controller;
    TextSelection selection = controller.selection;
    String text = controller.text;

    String currentSelection = selection.textInside(text);
    String newText;
    TextSelection newSelection;

    String finalInsertText;
    if (currentSelection.isNotEmpty && textPlaceholder != null) {
      // Replace the placeholder with the selected text
      finalInsertText = formatTemplate.replaceFirst(
        textPlaceholder,
        currentSelection,
      );
    } else {
      finalInsertText = formatTemplate;
    }

    newText = text.replaceRange(
      selection.start,
      selection.end,
      finalInsertText,
    );

    // Calculate cursor position for the URL part
    int parenIndex = finalInsertText.lastIndexOf(')');
    int cursorPosition =
        selection.start + parenIndex; // Position just before ')'

    newSelection = TextSelection.collapsed(offset: cursorPosition);

    controller.value = TextEditingValue(
      text: newText,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _showPreview
            ? MarkdownBody(
              data: widget.controller.text,
              // Configure markdown styling or link handling here
              // styleSheet: MarkdownStyleSheet(...)
              // onTapLink: (text, href, title) {
              //   if (href != null) launchUrl(Uri.parse(href));
              // },
              // padding: const EdgeInsets.all(12.0),
            )
            : TextField(
              controller: widget.controller,
              maxLines: widget.maxLines,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none, // Hides the default TextField border
                contentPadding: const EdgeInsets.all(
                  12.0,
                ), // Adds internal padding
              ),
            ),
        // Markdown Toolbar
        Container(
          // Use Container instead of Card
          // color: Theme.of(context).cardColor, // A neutral background color
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor, // Subtle divider
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.format_bold),
                tooltip: 'Bold (**text**)',
                onPressed: () => _applyFormat('**', '**'),
              ),
              IconButton(
                icon: const Icon(Icons.format_italic),
                tooltip: 'Italic (*text*)',
                // Markdown for italic is * or _
                onPressed: () => _applyFormat('*', '*'),
              ),
              IconButton(
                icon: const Icon(Icons.format_underline),
                tooltip: 'Underline (__text__)',
                // Not standard Markdown, but common custom convention
                onPressed: () => _applyFormat('__', '__'),
              ),
              const VerticalDivider(width: 1), // Separator
              IconButton(
                icon: const Icon(Icons.title), // Heading icon (uses H1)
                tooltip: 'Heading (# text)',
                onPressed: () => _toggleLinePrefix('# '),
              ),
              IconButton(
                icon: const Icon(
                  Icons.format_list_bulleted,
                ), // Bullet list icon
                tooltip: 'Bullet List (* item)',
                onPressed: () => _toggleLinePrefix('* '),
              ),
              const VerticalDivider(width: 1),
              IconButton(
                icon: const Icon(Icons.link), // Link icon
                tooltip: 'Link ([text](url))',
                onPressed:
                    () => _insertComplexFormat(
                      '[text](url)',
                      textPlaceholder: 'text',
                    ),
              ),
              const VerticalDivider(width: 1),
              IconButton(
                icon:
                    _showPreview
                        ? const Icon(
                          Icons.visibility_off_outlined,
                        ) // Eye slashed icon for hide preview
                        : const Icon(
                          Icons.remove_red_eye,
                        ), // Eye icon for show preview
                tooltip: _showPreview ? 'Hide Preview' : 'Show Preview',
                onPressed: () {
                  setState(() {
                    _showPreview = !_showPreview;
                  });
                },
              ),
            ],
          ),
        ),

        // Content Area: TextField or Markdown Preview
      ],
    );
  }
}
