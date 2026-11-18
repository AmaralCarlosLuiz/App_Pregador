/// Armazenamento síncrono complementar para ambientes não-web (stub).
/// Em Android/iOS nativo e Desktop, `SharedPreferences` já persiste em disco nativamente.
String? readWebLocal(String key) => null;

bool writeWebLocal(String key, String value) => true;

void removeWebLocal(String key) {}

