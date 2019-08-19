import 'package:flutter/material.dart';
import 'package:open_graph_parser/open_graph_parser.dart';
import './rich_link_preview.dart';

abstract class RichLinkPreviewModel extends State<RichLinkPreview> {
  String _link;
  double _height;
  Color _borderColor;
  Color _backgroundColor;
  Color _textColor;
  bool _appendToLink;
  bool _isLink;
  bool _launchFromLink;
  Map _ogData;

  void getOGData() async {
    try {
      Map data = await OpenGraphParser.getOpenGraphData(_link);
      if (data != null) {
        if (this.mounted) {
          setState(() {
            _ogData = data;
          });
        }
      } else {
        setState(() {
          _ogData = null;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _ogData = null;
      });
    }
  }

  @override
  void initState() {
    _link = widget.link ?? '';
    _height = widget.height ?? 100.0;
    _borderColor = widget.borderColor ?? Color(0xFFE0E0E0);
    _textColor = widget.textColor ?? Color(0xFF000000);
    _backgroundColor = widget.backgroundColor ?? Color(0xFFE0E0E0);
    _appendToLink = widget.appendToLink ?? false;
    _launchFromLink = widget.launchFromLink ?? true;

    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isValidUrl(link) {
    String regexSource = "^(https?)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]";
    final regex = RegExp(regexSource);
    final matches = regex.allMatches(link);
    for (Match match in matches) {
      if (match.start == 0 && match.end == link.length) {
        return true;
      }
    }
    return false;
  }

  @override
  void didUpdateWidget(RichLinkPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (this.mounted && _appendToLink == false) {
      setState(() {
        _link = oldWidget.link != widget.link ? widget.link : '';
      });
    }

    _fetchData();
  }

  void _fetchData() {
    if (isValidUrl(_link) == true) {
      getOGData();
      _isLink = true;
    } else {
      if (this.mounted) {
        setState(() {
          _ogData = null;
        });
      }
      _isLink = false;
    }
  }

  Widget buildRichLinkPreview(BuildContext context) {
    if (_ogData == null) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Expanded(flex: 8, child: _buildUrl(context)),
      ]);
    } else {
      if (_appendToLink == true) {
        return _buildPreviewRow(context);
      } else {
        return (Container(
            height: _height,
            decoration: new BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(2.0)),
            ),
            child: _buildPreviewRow(context)));
      }
    }
  }

  Widget _buildRichLinkPreviewBody(BuildContext context, Map _ogData) {
    return Container(
//        padding: const EdgeInsets.all(3.0),
//        height: _height,
        decoration: BoxDecoration(
          color: _backgroundColor,
          border: Border(
            top: BorderSide(width: 2.0, color: _borderColor),
            left: BorderSide(width: 0.0, color: _borderColor),
            right: BorderSide(width: 2.0, color: _borderColor),
            bottom: BorderSide(width: 2.0, color: _borderColor),
          ),
        ),
        child: new Column(
//            crossAxisAlignment: CrossAxisAlignment.stretch,
//            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _buildTitle(context),
              _buildDescription(context),
            ]));
  }

  Widget _buildPreviewRow(BuildContext context) {
    if (_ogData['image'] != null) {
      return Column(
        children: <Widget>[
          Row(
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: Align(
                      alignment: Alignment.center,
                      child: AspectRatio(aspectRatio: 4 / 3, child: _getImage(_ogData['image'])))),
              Expanded(flex: 5, child: _buildRichLinkPreviewBody(context, _ogData)),
            ],
          ),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Expanded(flex: 8, child: _buildUrl(context)),
          ])
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: _buildRichLinkPreviewBody(context, _ogData),
          ),
        ],
      );
    }
  }

  Widget _buildTitle(BuildContext context) {
    if (_ogData != null && _ogData['title'] != null) {
      return Padding(
          padding: EdgeInsets.all(1.0),
          child: new Text(
            _ogData['title'] ?? "",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, color: _textColor),
          ));
    } else {
      return Padding(
          padding: EdgeInsets.all(1.0),
          child: new Text(
            _link,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, color: _textColor),
          ));
    }
  }

  Widget _buildDescription(BuildContext context) {
    if (_ogData != null && _ogData['description'] != null) {
      return Padding(
          padding: EdgeInsets.all(2.0),
          child: new Text(_ogData['description'] ?? "",
              overflow: TextOverflow.ellipsis, maxLines: 3, style: TextStyle(color: _textColor)));
    } else {
      return Text(_ogData['title'] ?? "",
          overflow: TextOverflow.ellipsis, maxLines: 2, style: TextStyle(color: _textColor));
    }
  }

  Widget _buildUrl(BuildContext context) {
    if (_link != '' && _appendToLink == true) {
      return Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
          ),
          child: Padding(
              padding: EdgeInsets.all(5.0),
              child:
                  new Text(_link, overflow: TextOverflow.ellipsis, maxLines: 2, style: TextStyle(color: _textColor))));
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }

  Widget _getImage(String url) {
    Image image;
    try {
      image = Image.network(
        _ogData['image'],
        alignment: Alignment.center,
      );
    } catch (e) {
      print(e);
    }
    if (image?.width == null) return Container();
    return image;
  }
}
