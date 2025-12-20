import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VLibrasWidget extends StatefulWidget {
  const VLibrasWidget({super.key});
  static WebViewController? _controller;
  static bool _isWidgetReady = false;
  static String? _pendingText;
  static Future<void> buscarTraducao(String texto) async {
    _pendingText = texto;

    if (_controller == null || !_isWidgetReady) {
      debugPrint("VLibras: ainda não está pronto. Texto ficará pendente.");
      return;
    }

    await _sendTextToWeb(texto);
  }

  static Future<void> _sendTextToWeb(String texto) async {
    if (_controller == null) return;

    final safe = jsonEncode(texto);

    await _controller!.runJavaScript("""
      try {
        window.setTutorialText($safe);
        // Não força abrir o avatar aqui.
        // A tradução só “pega” quando o usuário abrir o VLibras.
        window.translateTutorialText();
      } catch (e) {
        console.log("VLibras translate error:", e);
      }
    """);
  }

  @override
  State<VLibrasWidget> createState() => _VLibrasWidgetState();
}

class _VLibrasWidgetState extends State<VLibrasWidget> {
  bool _isLoading = true;
  late final WebViewController _controller;

  int _reloadAttempts = 0;

  @override
  void initState() {
    super.initState();

    if (VLibrasWidget._controller != null) {
      _controller = VLibrasWidget._controller!;
      _isLoading = false;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final pending = VLibrasWidget._pendingText;
        if (VLibrasWidget._isWidgetReady &&
            pending != null &&
            pending.trim().isNotEmpty) {
          await VLibrasWidget.buscarTraducao(pending);
        }
      });

      return;
    }

    _controller = WebViewController();
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setBackgroundColor(const Color(0x00000000));
    _controller.setOnConsoleMessage((msg) {
      debugPrint("VLibras WebView console: ${msg.message}");
    });

    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) async {
          if (!mounted) return;

          setState(() => _isLoading = false);

          final ok = await _waitUntilReady();
          if (!ok) return;

          VLibrasWidget._isWidgetReady = true;

          final pending = VLibrasWidget._pendingText;
          if (pending != null && pending.trim().isNotEmpty) {
            await VLibrasWidget._sendTextToWeb(pending);
          }
        },

        onWebResourceError: (error) async {
          debugPrint("VLibras WebResourceError: ${error.description}");

          if (_reloadAttempts < 2) {
            _reloadAttempts++;
            debugPrint("VLibras: tentando reload $_reloadAttempts/2 ...");
            await Future.delayed(const Duration(seconds: 1));
            await _controller.reload();
            return;
          }

          debugPrint("VLibras: falhou após retries.");
        },
      ),
    );

    _controller.loadHtmlString(_vlibrasHtml);

    VLibrasWidget._controller = _controller;
    VLibrasWidget._isWidgetReady = false;
  }

  Future<bool> _waitUntilReady() async {
    for (int i = 0; i < 75; i++) {
      final result = await _controller.runJavaScriptReturningResult("""
        (function () {
          const hasBtn = !!document.querySelector('.vw-access-button') || !!document.querySelector('[vw-access-button]');
          const hasVlibras = (typeof window.VLibras !== 'undefined');
          const hasFunctions =
            (typeof window.setTutorialText === 'function') &&
            (typeof window.translateTutorialText === 'function');
          return hasBtn && hasVlibras && hasFunctions;
        })();
      """);

      if (result.toString().contains('true')) return true;
      await Future.delayed(const Duration(milliseconds: 400));
    }

    debugPrint("VLibras: timeout esperando ficar pronto.");
    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 300,
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}


const String _vlibrasHtml = r'''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <style>
      html, body {
        background: transparent !important;
        overflow: hidden;
        margin: 0;
        padding: 0;
      }

      .vpw-controls, .vpw-settings, .vpw-header {
        display: none !important;
      }

      
      #vlibrasText {
        position: fixed;
        left: -10000px;
        top: 0;
        width: 10px;
        height: 10px;
        overflow: hidden;
        opacity: 0.01;
        user-select: text;
        white-space: pre-wrap;
      }

    
      .unity-warning, .unity-error, .unity-dialog, .unityMessage, .webgl-error, .errorDialog {
        display: none !important;
        visibility: hidden !important;
        opacity: 0 !important;
        pointer-events: none !important;
      }
    </style>
  </head>

  <body>
    <div id="vlibrasText">...</div>

    <div vw class="enabled">
      <div vw-access-button class="active"></div>
      <div vw-plugin-wrapper>
        <div class="vw-plugin-top-wrapper"></div>
      </div>
    </div>

    <script>
     
      window.alert = function(msg) { console.log("alert suppressed:", msg); };
      window.confirm = function(msg) { console.log("confirm suppressed:", msg); return true; };
      window.prompt = function(msg) { console.log("prompt suppressed:", msg); return null; };

      
      function tryDismissUnityError() {
        try {
          const all = document.querySelectorAll('button, a, div');
          for (const el of all) {
            const t = (el.innerText || "").trim().toLowerCase();
            if (t === "ok" || t === "okay") {
              const pageText = (document.body.innerText || "").toLowerCase();
              if (pageText.includes("unity") && pageText.includes("error")) {
                el.click();
                console.log("Unity error dialog dismissed automatically.");
                return;
              }
              if (pageText.includes("script error") && pageText.includes("unity")) {
                el.click();
                console.log("Unity script error dialog dismissed automatically.");
                return;
              }
            }
          }
        } catch(e) {
          console.log("dismiss unity error failed:", e);
        }
      }

      setInterval(tryDismissUnityError, 800);

      const obs = new MutationObserver(() => tryDismissUnityError());
      obs.observe(document.documentElement, { childList: true, subtree: true });

      window.onerror = function(message, source, lineno, colno, error) {
        console.log("VLibras window.onerror:", message, source, lineno, colno);
      };
    </script>

    <script src="https://vlibras.gov.br/app/vlibras-plugin.js"></script>

    <script>
      window.widgetInstance = new window.VLibras.Widget('https://vlibras.gov.br/app');

      window.setTutorialText = function(text) {
        const el = document.getElementById('vlibrasText');
        if (!el) return;
        el.textContent = (text || "");
      };

      window.translateTutorialText = function() {
        const el = document.getElementById('vlibrasText');
        if (!el) return;

        try {
          const range = document.createRange();
          range.selectNodeContents(el);

          const sel = window.getSelection();
          sel.removeAllRanges();
          sel.addRange(range);

          document.dispatchEvent(new Event('selectionchange'));
        } catch(e) {
          console.log("VLibras selection error:", e);
        }

        try {
          el.dispatchEvent(new MouseEvent('mouseup', { bubbles: true }));
          el.dispatchEvent(new MouseEvent('click', { bubbles: true }));
        } catch(e) {
          console.log("VLibras event error:", e);
        }
      };

      
      (function () {
        function hookOpenClick() {
          const btn = document.querySelector('.vw-access-button') || document.querySelector('[vw-access-button]');
          if (!btn) return false;

          btn.addEventListener('click', () => {
            setTimeout(() => {
              try {
                window.translateTutorialText && window.translateTutorialText();
              } catch(e) {}
            }, 300);
          });

          return true;
        }

        const timer = setInterval(() => {
          if (hookOpenClick()) clearInterval(timer);
        }, 500);
      })();
    </script>
  </body>
</html>
''';
