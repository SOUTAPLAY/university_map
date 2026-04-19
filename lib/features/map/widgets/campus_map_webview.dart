import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/models/building.dart';

class CampusMapWebView extends StatefulWidget {
  final List<Building> buildings;
  final String? highlightedBuildingId;
  final void Function(String buildingId)? onBuildingTapped;

  const CampusMapWebView({
    super.key,
    required this.buildings,
    this.highlightedBuildingId,
    this.onBuildingTapped,
  });

  @override
  State<CampusMapWebView> createState() => _CampusMapWebViewState();
}

class _CampusMapWebViewState extends State<CampusMapWebView> {
  late final WebViewController _controller;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    final htmlContent =
        await rootBundle.loadString('assets/html/campus_map.html');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterMapReady',
        onMessageReceived: (_) {
          setState(() => _mapReady = true);
          _sendInit();
          _applyHighlight();
        },
      )
      ..addJavaScriptChannel(
        'FlutterBuildingTapped',
        onMessageReceived: (msg) {
          widget.onBuildingTapped?.call(msg.message);
        },
      )
      ..loadHtmlString(htmlContent);
  }

  void _sendInit() {
    if (!_mapReady) return;
    final msg = jsonEncode({
      'type': 'init',
      'buildings': widget.buildings.map((b) => b.toJson()).toList(),
    });
    _controller.runJavaScript('handleFlutterMessage(${jsonEncode(msg)})');
  }

  void _applyHighlight() {
    if (!_mapReady) return;
    final msg = jsonEncode({
      'type': widget.highlightedBuildingId != null ? 'highlight' : 'reset',
      if (widget.highlightedBuildingId != null)
        'buildingId': widget.highlightedBuildingId,
    });
    _controller.runJavaScript('handleFlutterMessage(${jsonEncode(msg)})');
  }

  @override
  void didUpdateWidget(CampusMapWebView old) {
    super.didUpdateWidget(old);
    if (old.highlightedBuildingId != widget.highlightedBuildingId) {
      _applyHighlight();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (!_mapReady)
          Container(
            color: const Color(0xFF1a1a2e),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.lightBlue),
                  SizedBox(height: 16),
                  Text('3Dマップを読み込み中...',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
