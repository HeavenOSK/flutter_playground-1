import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mono_kit/mono_kit.dart';
import 'package:state_notifier/state_notifier.dart';

void main() => runApp(
      const ProviderScope(
        child: App(),
      ),
    );

class App extends HookWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: useProvider(navigatorKeyProvider),
      home: const _HomePage(),
      theme: lightTheme(),
      darkTheme: darkTheme(),
    );
  }
}

class _HomePage extends HookWidget {
  const _HomePage({
    Key key,
    this.index = 0,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = useProvider(_homePageProvider);
    final canPop = useProvider(navigatorKeyProvider).currentState.canPop();
    return Scaffold(
      appBar: AppBar(title: Text('index: $index')),
      body: SnackBarPresenter(
        messageProvider: snackBarMessageNotifierProvider.state,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RaisedButton(
                child: const Text('Show SnackBar'),
                onPressed: () => controller.showSnackBarMessage('Hey(　´･‿･｀)'),
              ),
              RaisedButton(
                child: const Text('👉 Navigate to next page'),
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => _HomePage(
                        index: index + 1,
                      ),
                    ),
                  );
                },
              ),
              if (canPop)
                RaisedButton(
                  child: const Text('👈 Pop and show SnackBar'),
                  onPressed: controller.popAndShowSnackBar,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}

final navigatorKeyProvider = Provider((_) => GlobalKey<NavigatorState>());

final _homePageProvider = Provider<_HomePageController>(
  (ref) => _HomePageController(ref),
);

class _HomePageController {
  _HomePageController(this._ref);

  final ProviderReference _ref;

  void popAndShowSnackBar() {
    _ref.read(navigatorKeyProvider).currentState.pop();
    showSnackBarMessage('Came back(　´･‿･｀)');
  }

  void showSnackBarMessage(String message) {
    _ref.read(snackBarMessageNotifierProvider).showSnackBarMessage(message);
  }
}

final snackBarMessageNotifierProvider = StateNotifierProvider(
  (_) => SnackBarMessageNotifier(),
);

class SnackBarMessageNotifier extends StateNotifier<String> {
  SnackBarMessageNotifier() : super(null);

  void showSnackBarMessage(String message) {
    if (message != null) {
      state = message;
    }
  }
}

class SnackBarPresenter extends StatelessWidget {
  const SnackBarPresenter({
    @required this.child,
    @required this.messageProvider,
    Key key,
  }) : super(key: key);

  final Widget child;
  final ProviderBase<Object, String> messageProvider;

  @override
  Widget build(BuildContext context) {
    return ProviderListener<String>(
      provider: messageProvider,
      onChange: (context, value) {
        if (value != null) {
          if (ModalRoute.of(context).isCurrent) {
            _showMessage(context, value);
          }
        }
      },
      child: child,
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showMessage(
    BuildContext context,
    String message,
  ) {
    return _show(
      context,
      SnackBar(
        content: Text(message),
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _show(
    BuildContext context,
    SnackBar snackBar,
  ) {
    return Scaffold.of(context).showSnackBar(snackBar);
  }
}
