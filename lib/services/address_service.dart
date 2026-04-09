import '../config/api_config.dart';
import '../models/saved_address.dart';
import 'api_service.dart';

class AddressService {
  static Future<List<SavedAddress>> getAddresses() async {
    final data = await ApiService.get(ApiConfig.addresses, auth: true);
    return (data as List).map((j) => SavedAddress.fromJson(j)).toList();
  }

  static Future<SavedAddress> createAddress(SavedAddress address) async {
    final data = await ApiService.post(
      ApiConfig.addresses,
      address.toJson(),
      auth: true,
    );
    return SavedAddress.fromJson(data);
  }
}
