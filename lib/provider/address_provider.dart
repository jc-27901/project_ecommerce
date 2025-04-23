import 'package:flutter/material.dart';
import '../models/address_dm.dart';
import '../services/firebase_services.dart';

class AddressProvider extends ChangeNotifier {
  final BaseFirebaseService _firebaseService;
  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _error;

  AddressProvider(this._firebaseService);

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Address? get defaultAddress => _addresses.isNotEmpty ?
  _addresses.firstWhere((addr) => addr.isDefault, orElse: () => _addresses.first) : null;

  // Load all addresses for a user
  Future<void> loadUserAddresses(String userId) async {
    _setLoading(true);
    try {
      _addresses = await _firebaseService.getUserAddresses(userId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load addresses: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Add a new address
  Future<void> addAddress(String userId, Address address) async {
    _setLoading(true);
    try {
      // If this is the first address or marked as default, ensure it's set as default
      if (_addresses.isEmpty || address.isDefault) {
        // If this is a default address, make sure no other address is default
        if (address.isDefault) {
          await _updateDefaultAddressStatus(userId);
        }
      }

      final String addressId = await _firebaseService.addUserAddress(userId, address);

      // Update our local list
      final newAddress = address.copyWith(id: addressId);
      _addresses.add(newAddress);
      _error = null;
    } catch (e) {
      _error = 'Failed to add address: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing address
  Future<void> updateAddress(String userId, Address address) async {
    _setLoading(true);
    try {
      // If this is being set as default, update other addresses
      if (address.isDefault) {
        await _updateDefaultAddressStatus(userId);
      }

      await _firebaseService.updateUserAddress(userId, address);

      // Update our local list
      final index = _addresses.indexWhere((addr) => addr.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to update address: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Delete an address
  Future<void> deleteAddress(String userId, String addressId) async {
    _setLoading(true);
    try {
      await _firebaseService.deleteUserAddress(userId, addressId);

      // Update our local list
      _addresses.removeWhere((addr) => addr.id == addressId);
      _error = null;
    } catch (e) {
      _error = 'Failed to delete address: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Set an address as default
  Future<void> setDefaultAddress(String userId, String addressId) async {
    _setLoading(true);
    try {
      // First remove default status from all addresses
      await _updateDefaultAddressStatus(userId);

      // Find the address we want to set as default
      final index = _addresses.indexWhere((addr) => addr.id == addressId);
      if (index != -1) {
        // Update the address with default status
        final updatedAddress = _addresses[index].copyWith(
          isDefault: true,
          updatedAt: DateTime.now(),
        );

        await _firebaseService.updateUserAddress(userId, updatedAddress);

        // Update our local list
        _addresses[index] = updatedAddress;
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to set default address: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to update default status
  Future<void> _updateDefaultAddressStatus(String userId) async {
    // Find all default addresses
    final defaultAddresses = _addresses.where((addr) => addr.isDefault).toList();

    // Remove default status from all addresses that have it
    for (var address in defaultAddresses) {
      final updatedAddress = address.copyWith(
        isDefault: false,
        updatedAt: DateTime.now(),
      );

      await _firebaseService.updateUserAddress(userId, updatedAddress);

      // Update our local list
      final index = _addresses.indexWhere((addr) => addr.id == address.id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
      }
    }
  }

  // Helper method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}