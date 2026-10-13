import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sermon_template_model.dart';
import 'sermon_provider.dart';

final templatesProvider = FutureProvider<List<SermonTemplate>>((ref) async {
  final repo = ref.watch(sermonRepositoryProvider);
  return repo.getTemplates();
});
