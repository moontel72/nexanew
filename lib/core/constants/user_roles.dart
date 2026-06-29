// User roles constants for NexaTrace System
// This file defines all user roles in the system

class UserRoles {
  // Platform roles
  static const String superAdmin = 'super_admin';
  static const String subAdmin = 'sub_admin';

  // Factory roles
  static const String factoryAdmin = 'factory_admin';
  static const String storeKeeper = 'store_keeper';
  static const String driver = 'driver';

  // Universal app roles
  static const String reseller = 'reseller';
  static const String shop = 'shop';
  static const String customer = 'customer';

  // Role groups
  static const List<String> platformRoles = [superAdmin, subAdmin];
  static const List<String> factoryRoles = [factoryAdmin, storeKeeper, driver];
  static const List<String> universalRoles = [reseller, shop, customer];

  /// Fleet roles that can appear in fleet_assignments (bus or truck).
  static const List<String> fleetAssignmentRoles = [
    'owner',
    'driver',
    'conductor',
    'store_keeper',
  ];

  // Check if role is valid
  static bool isValidRole(String role) {
    return allRoles.contains(role);
  }

  // Get all roles
  static List<String> get allRoles => [
    superAdmin,
    subAdmin,
    factoryAdmin,
    storeKeeper,
    driver,
    reseller,
    shop,
    customer,
  ];

  // Get role display name
  static String getDisplayName(String role) {
    switch (role) {
      case superAdmin:
        return 'Super Admin';
      case subAdmin:
        return 'Sub Admin';
      case factoryAdmin:
        return 'Factory Admin';
      case storeKeeper:
        return 'Store Keeper';
      case driver:
        return 'Driver';
      case reseller:
        return 'Reseller';
      case shop:
        return 'Shop';
      case customer:
        return 'Customer';
      default:
        return 'Unknown Role';
    }
  }

  // Check if role has factory access
  static bool hasFactoryAccess(String role) {
    return factoryRoles.contains(role) || role == superAdmin || role == subAdmin;
  }

  // Check if role has platform admin access
  static bool hasPlatformAdminAccess(String role) {
    return platformRoles.contains(role);
  }

  /// Check if a fleet_assignment role is a storekeeper (bus fleet inventory).
  static bool isFleetStorekeeper(String fleetRole) {
    return fleetRole == 'store_keeper';
  }
}
