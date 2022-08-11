import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_list/models/db.dart';

final dbProvider = ChangeNotifierProvider((_) => TodoDatabase.instance);

final todosProvider = FutureProvider((ref) {
  final db = ref.watch(dbProvider);
  return db.queryall();
});

final todoProvider = FutureProvider.family<Map, int>((ref, id) {
  final db = ref.read(dbProvider);
  return db.queryone(id);
});
