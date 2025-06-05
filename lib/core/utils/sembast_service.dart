import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class SembastService {
 static final SembastService _instance =
      SembastService._internal();

  factory SembastService() {
    return _instance;
  }

  SembastService._internal();

  late final Database db;

  final journalStore = stringMapStoreFactory.store('journals');

  Future<void> init() async {
    try {
      if (kIsWeb) {
        //  _db = await databaseFactoryWeb.openDatabase('/assets/db');
        throw UnimplementedError();
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        final dbPath = join(appDir.path, 'chat.db');
        db = await databaseFactoryIo.openDatabase(dbPath);
      }
    } catch (e, s) {
      debugPrint('>> DB INITIALIZATION ERROR: $e, $s');
    }
  }

  Future<void> close() async {
    await db.close();
  }
}