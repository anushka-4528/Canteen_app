import 'package:hive/hive.dart';
import '../models/menu_item.dart';

class LocalStorageService {
  static const String _boxName = 'translated_menu_items';

  Future<void> saveTranslatedItem(MenuItem item) async {
    final box = await Hive.openBox<MenuItem>(_boxName);
    await box.put(item.id, item);
  }

  Future<MenuItem?> getTranslatedItem(String id) async {
    final box = await Hive.openBox<MenuItem>(_boxName);
    return box.get(id);
  }

  Future<List<MenuItem>> getAllTranslatedItems() async {
    final box = await Hive.openBox<MenuItem>(_boxName);
    return box.values.toList();
  }
}
