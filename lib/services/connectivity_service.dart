import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  
  final RxBool isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkInitialConnection() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      isOnline.value = false;
    } else {
      isOnline.value = true;
    }
  }
}
