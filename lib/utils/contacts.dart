import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Contact> getDeviceContact() async {
  try {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      return await ContactsService.openDeviceContactPicker();
    }
  } catch (e) {
    print('Error: failed to get contact: $e');
  }

  return null;
}

Future<PermissionStatus> _getPermission() async {
  final PermissionStatus permission = await Permission.contacts.status;
  if (permission != PermissionStatus.granted &&
      permission != PermissionStatus.denied) {
    final Map<Permission, PermissionStatus> permissionStatus =
        await [Permission.contacts].request();
    return permissionStatus[Permission.contacts] ??
        PermissionStatus.undetermined;
  } else {
    return permission;
  }
}
