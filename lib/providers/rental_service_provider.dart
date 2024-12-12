import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/providers/rental_provider.dart';

final rentalServiceProvider = Provider<RentalService>((ref) {
  return RentalService();
}); 