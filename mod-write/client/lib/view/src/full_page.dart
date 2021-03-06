import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mod_write/stub_data.dart';
import 'package:mod_write/view/list_document.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';

import 'package:mod_write/view/src/zefyr_image_delegate.dart'
    if (dart.library.js) 'package:mod_write/view/src/zefyr_image_delegate_web.dart';

class FullPageEditorScreen extends StatefulWidget {
  final int id;
  final bool showBackButton;

  const FullPageEditorScreen(
      {Key key, @required this.id, this.showBackButton = false})
      : super(key: key);

  @override
  _FullPageEditorScreenState createState() => _FullPageEditorScreenState();
}

final doc =
    r'[{"insert":"Zefyr"},{"insert":"\n","attributes":{"heading":1}},{"insert":"Soft and gentle rich text editing for Flutter applications.","attributes":{"i":true}},{"insert":"\n"},{"insert":"​","attributes":{"embed":{"type":"image","source":"asset://images/breeze.jpg"}}},{"insert":"\n"},{"insert":"Photo by Hiroyuki Takeda.","attributes":{"i":true}},{"insert":"\nZefyr is currently in "},{"insert":"early preview","attributes":{"b":true}},{"insert":". If you have a feature request or found a bug, please file it at the "},{"insert":"issue tracker","attributes":{"a":"https://github.com/memspace/zefyr/issues"}},{"insert":'
    r'".\nDocumentation"},{"insert":"\n","attributes":{"heading":3}},{"insert":"Quick Start","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/quick_start.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Data Format and Document Model","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/data_and_document.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Style Attributes","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/attr'
    r'ibutes.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Heuristic Rules","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/heuristics.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"FAQ","attributes":{"a":"https://github.com/memspace/zefyr/blob/master/doc/faq.md"}},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"Clean and modern look"},{"insert":"\n","attributes":{"heading":2}},{"insert":"Zefyr’s rich text editor is built with simplicity and fle'
    r'xibility in mind. It provides clean interface for distraction-free editing. Think Medium.com-like experience.\nMarkdown inspired semantics"},{"insert":"\n","attributes":{"heading":2}},{"insert":"Ever needed to have a heading line inside of a quote block, like this:\nI’m a Markdown heading"},{"insert":"\n","attributes":{"block":"quote","heading":3}},{"insert":"And I’m a regular paragraph"},{"insert":"\n","attributes":{"block":"quote"}},{"insert":"Code blocks"},{"insert":"\n","attributes":{"headin'
    r'g":2}},{"insert":"Of course:\nimport ‘package:flutter/material.dart’;"},{"insert":"\n","attributes":{"block":"code"}},{"insert":"import ‘package:zefyr/zefyr.dart’;"},{"insert":"\n\n","attributes":{"block":"code"}},{"insert":"void main() {"},{"insert":"\n","attributes":{"block":"code"}},{"insert":" runApp(MyZefyrApp());"},{"insert":"\n","attributes":{"block":"code"}},{"insert":"}"},{"insert":"\n","attributes":{"block":"code"}},{"insert":"\n\n\n"}]';

enum _Options { darkTheme }

class _FullPageEditorScreenState extends State<FullPageEditorScreen> {
  ZefyrController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _editing = false;
  StreamSubscription<NotusChange> _sub;
  bool _darkTheme = false;

  @override
  void initState() {
    super.initState();
    _controller = ZefyrController(NotusDocument.fromDelta(getDelta()));
    _sub = _controller.document.changes.listen((change) {
      print('${change.source}: ${change.change}');
    });
  }

  Delta getDelta() {
    return Delta.fromJson(
        json.decode(StubData.documents[widget.id].content) as List);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = _editing
        ? IconButton(onPressed: _stopEditing, icon: Icon(Icons.save))
        : IconButton(onPressed: _startEditing, icon: Icon(Icons.edit));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        actions: <Widget>[done],
      ),
      resizeToAvoidBottomPadding: true,
      body: ZefyrScaffold(
        child: ZefyrEditor(
          controller: _controller,
          focusNode: _focusNode,
          mode: _editing ? ZefyrMode.edit : ZefyrMode.select,
          imageDelegate: CustomImageDelegate(),
          keyboardAppearance: _darkTheme ? Brightness.dark : Brightness.light,
        ),
      ),
    );
  }

  void handlePopupItemSelected(value) {
    if (!mounted) return;
    setState(() {
      if (value == _Options.darkTheme) {
        _darkTheme = !_darkTheme;
      }
    });
  }

  List<PopupMenuEntry<_Options>> buildPopupMenu(BuildContext context) {
    return [
      CheckedPopupMenuItem(
        value: _Options.darkTheme,
        child: Text("Dark theme"),
        checked: _darkTheme,
      ),
    ];
  }

  void _startEditing() {
    setState(() {
      _editing = true;
    });
  }

  void _stopEditing() {
    setState(() {
      _editing = false;
    });
    print("zefyr json: ${jsonEncode(_controller.document.toDelta())}");
    var _doc = StubData.documents
        .firstWhere((Document element) => widget.id == element.id);
    StubData.documents.remove(_doc);
    StubData.documents.add(Document(
        _doc.id, _doc.name, jsonEncode(_controller.document.toDelta())));
  }
}
