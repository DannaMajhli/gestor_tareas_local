import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/app_database.dart';

void main() {
  test('SQLite guarda y recupera una tarea', () async {
    // Crear una base de datos temporal.
    final db = AppDatabase(NativeDatabase.memory());

    try {
      // Guardar una tarea en SQLite.
      await db.agregarTarea('Estudiar Flutter');

      // Consultar las tareas guardadas.
      final tareas = await db.obtenerTareas();

      // Comprobar que la tarea se guardó correctamente.
      expect(tareas.length, 1);
      expect(tareas.first.titulo, 'Estudiar Flutter');
      expect(tareas.first.completada, false);
    } finally {
      // Cerrar la conexión.
      await db.close();
    }
  });
}
