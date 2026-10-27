import 'package:flutter_modular/flutter_modular.dart';
import 'package:provider/provider.dart';
import 'package:petanitech_mobile/modules/main/presentation/ecommerce_screen.dart';
import 'logic/controllers/shopping_cart_controller.dart';

class EcommerceModule extends Module {
  static const String ecommerceRoute = '/';

  @override
  void binds(Injector i) {
    i.addSingleton<ShoppingCartController>(() => ShoppingCartController.instance);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      ecommerceRoute,
      child: (context) => ChangeNotifierProvider.value(
        value: ShoppingCartController.instance,
        child: const EcommerceScreen(),
      ),
    );
  }
}
