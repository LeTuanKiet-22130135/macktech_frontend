import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';

/// A full-screen WebView for online payment (VNPAY, MoMo, etc.).
/// The backend redirects to macktech://payment-result after processing.
/// The app_links listener in main.dart handles the final navigation.
/// This WebView handles intent:// URIs to launch banking apps on Android.
class PaymentWebviewScreen extends StatefulWidget {
  final String paymentUrl;
  final String title;

  const PaymentWebviewScreen({
    super.key,
    required this.paymentUrl,
    this.title = 'Payment',
  });

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            // Also check the finished URL for callback params
            _checkUrlForCallback(url);
          },
          onNavigationRequest: (request) {
            final url = request.url;

            // Intercept the VNPAY callback URL
            if (url.contains('/api/payment/vnpay-callback')) {
              _handleVnpayCallback(Uri.parse(url));
              return NavigationDecision.prevent;
            }

            // Intercept the MoMo callback URL (redirect variant)
            if (url.contains('/api/payment/momo-callback')) {
              _handleMomoCallback(Uri.parse(url));
              return NavigationDecision.prevent;
            }

            // Handle intent:// URIs (Android app deep links from banking apps)
            if (url.startsWith('intent://')) {
              _handleIntentUrl(url);
              return NavigationDecision.prevent;
            }

            // Handle macktech:// deep link — launch it so the Android
            // intent system delivers it to app_links, then close WebView
            if (url.startsWith('macktech://')) {
              _launchAndClose(url);
              return NavigationDecision.prevent;
            }

            // Handle other custom schemes (e.g. momo://, zalopay://)
            if (!url.startsWith('http://') && !url.startsWith('https://') && !url.startsWith('about:')) {
              _launchExternalUrl(url);
              // Pop the WebView immediately so the CheckoutScreen underneath 
              // is ready to receive the macktech:// deep link from app_links.
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// Check if a loaded page URL contains callback parameters.
  /// Some payment providers redirect to the callback URL and load it
  /// rather than triggering a new navigation request.
  void _checkUrlForCallback(String url) {
    if (url.contains('/api/payment/vnpay-callback')) {
      _handleVnpayCallback(Uri.parse(url));
    } else if (url.contains('/api/payment/momo-callback')) {
      _handleMomoCallback(Uri.parse(url));
    }
  }

  void _handleVnpayCallback(Uri uri) {
    final responseCode = uri.queryParameters['vnp_ResponseCode'];
    if (responseCode == '00') {
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context, false);
    }
  }

  void _handleMomoCallback(Uri uri) {
    final resultCode = uri.queryParameters['resultCode'];
    if (resultCode == '0') {
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context, false);
    }
  }

  /// Launch the macktech:// deep link URL externally so the Android intent
  /// system delivers it to the app_links listener, then close this WebView.
  Future<void> _launchAndClose(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching macktech:// link: $e');
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// Parse an intent:// URI, try to launch the app via its scheme,
  /// and fall back to the S.browser_fallback_url if available.
  Future<void> _handleIntentUrl(String url) async {
    try {
      String? scheme;
      String? fallbackUrl;

      final fragmentIndex = url.indexOf('#Intent;');
      if (fragmentIndex != -1) {
        final intentParams = url.substring(fragmentIndex + 8);
        final params = intentParams.split(';');
        for (final param in params) {
          if (param.startsWith('scheme=')) {
            scheme = param.substring(7);
          } else if (param.startsWith('S.browser_fallback_url=')) {
            fallbackUrl = Uri.decodeFull(param.substring(22));
          }
        }
      }

      // Try to launch the native app via its scheme.
      if (scheme != null) {
        final intentPath = url.substring(9, fragmentIndex != -1 ? fragmentIndex : url.length);
        final appUrl = Uri.parse('$scheme://$intentPath');
        try {
          final launched = await launchUrl(appUrl, mode: LaunchMode.externalApplication);
          if (launched) {
            // Pop the WebView immediately so the CheckoutScreen underneath 
            // is ready to receive the macktech:// deep link from app_links.
            if (mounted) Navigator.pop(context);
            return;
          }
        } catch (_) {
          // App not installed or scheme not handled — fall through to fallback
        }
      }

      // Fallback to the browser fallback URL
      if (fallbackUrl != null) {
        final fallback = Uri.parse(fallbackUrl);
        try {
          await launchUrl(fallback, mode: LaunchMode.externalApplication);
        } catch (_) {
          debugPrint('Could not launch fallback URL: $fallbackUrl');
        }
      }
    } catch (e) {
      debugPrint('Error handling intent URL: $e');
    }
  }

  /// Launch any non-http custom scheme URL externally (e.g. momo://, zalopay://)
  Future<void> _launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        debugPrint('Could not launch external URL: $url');
      }
    } catch (e) {
      debugPrint('Error launching external URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.tertiaryDarker,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppColors.tertiaryNormal,
              ),
            ),
        ],
      ),
    );
  }
}
