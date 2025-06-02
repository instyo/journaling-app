import 'package:flutter/material.dart';

class CustomTextEditingController extends TextEditingController {
  final Map<String, TextStyle> map;
  final Pattern pattern;

  CustomTextEditingController(this.map)
    : pattern = RegExp(
        map.keys
            .map((key) {
              return key;
            })
            .join('|'),
        multiLine: true,
      );

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final List<InlineSpan> children = [];
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        String? patternMatched;
        String? formatText;
        TextStyle? myStyle =
            map[map.keys.firstWhere((e) {
              bool ret = false;
              RegExp(e).allMatches(text).forEach((element) {
                if (element.group(0) == match[0]) {
                  patternMatched = e;
                  ret = true;
                }
              });
              return ret;
            })];

        if (patternMatched == r"_(.*?)\_") {
          formatText = match[0]!.replaceAll("_", " ");
        } else if (patternMatched == r'\*(.*?)\*') {
          formatText = match[0]!.replaceAll("*", " ");
        } else if (patternMatched == "~(.*?)~") {
          formatText = match[0]!.replaceAll("~", " ");
        } else if (patternMatched == r'```(.*?)```') {
          formatText = match[0]!.replaceAll("```", "   ");
        } else {
          formatText = match[0];
        }

        children.add(TextSpan(text: formatText, style: style!.merge(myStyle)));
        return "";
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return "";
      },
    );

    return TextSpan(style: style, children: children);
  }
}

class MarkdownInputV2 extends StatefulWidget {
  final void Function(String)? onChanged;
  final String? initialValue;

  const MarkdownInputV2({super.key, this.onChanged, this.initialValue});

  @override
  State<MarkdownInputV2> createState() => _MarkdownInputV2State();
}

class _MarkdownInputV2State extends State<MarkdownInputV2> {
  final CustomTextEditingController _editTextController =
      CustomTextEditingController({
        r"@.\w+": TextStyle(
          color: Colors.blue.shade700, //For mentions
        ),
        r"#.\w+": TextStyle(
          color: Colors.blue.shade700, //for hashtags
        ),
        r'_(.*?)\_': const TextStyle(
          fontStyle: FontStyle.italic, //italic text
        ),
        '~(.*?)~': const TextStyle(
          decoration: TextDecoration.lineThrough, //strikethrough text
        ),
        r'\*(.*?)\*': const TextStyle(
          fontWeight: FontWeight.bold, //bold text
        ),
      });

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null) {
      _editTextController.text = widget.initialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: _editTextController,
        onChanged: widget.onChanged,
        keyboardType: TextInputType.multiline,
        scrollPadding: EdgeInsets.all(8),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8),
        ),
        minLines: 5,
        maxLines: 10,
        autofocus: true,
      ),
    );
  }
}
