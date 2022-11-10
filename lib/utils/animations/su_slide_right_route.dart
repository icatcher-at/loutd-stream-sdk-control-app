import 'package:flutter/cupertino.dart';
import 'package:stream_webview_app/main_page/su_webview.dart';

class SlideRightRoute extends PageRouteBuilder<WebViewContainerCover> {
  SlideRightRoute({required this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(3, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
  );

  late Widget page;
}