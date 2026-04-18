import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactResult {
  final String name;
  final String phone;
  ContactResult({required this.name, required this.phone});
}

class ContactsService {
  static Future<bool> requestPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  static Future<ContactResult?> pickContact() async {
    final granted = await requestPermission();
    if (!granted) return null;

    final contact = await FlutterContacts.openExternalPick();
    if (contact == null) return null;

    final full = await FlutterContacts.getContact(contact.id,
        withProperties: true, withPhoto: false);
    if (full == null) return null;

    final name = full.displayName;
    final phone = full.phones.isNotEmpty ? full.phones.first.number : '';

    return ContactResult(name: name, phone: phone);
  }
}
