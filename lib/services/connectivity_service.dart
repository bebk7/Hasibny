import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  final RxBool isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen((dynamic event) {
      _handleEvent(event);
    });
  }

  Future<void> _checkInitialConnection() async {
    try {
      final dynamic res = await _connectivity.checkConnectivity();
      _handleEvent(res);
    } catch (_) {
      isOnline.value = true;
    }
  }

  void _handleEvent(dynamic event) {
    if (event is List<ConnectivityResult>) {
      isOnline.value = !event.contains(ConnectivityResult.none) && event.isNotEmpty;
    } else if (event is ConnectivityResult) {
      isOnline.value = event != ConnectivityResult.none;
    } else {
      isOnline.value = true;
    }
  }
}
