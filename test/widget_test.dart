import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/app_database.dart';
import 'package:gestor_tareas_local/screens/tareas_page.dart';

void main() {
  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    // Base de datos temporal, independiente de los datos reales.
    final db = AppDatabase(NativeDatabase.memory());

    // Abrimos la pantalla utilizando la base temporal.
    await tester.pumpWidget(MaterialApp(home: TareasPage(database: db)));

    // Esperamos a que termine la carga inicial.
    await tester.pumpAndSettle();

    // Verificamos los elementos de la interfaz.
    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Retiramos la pantalla antes de terminar la prueba.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('No permite agregar tareas con espacios vacíos', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(MaterialApp(home: TareasPage(database: db)));

    await tester.pumpAndSettle();

    // Escribir solamente espacios.
    await tester.enterText(find.byType(TextField), '   ');

    // Intentar agregar la tarea.
    await tester.tap(find.text('Agregar tarea'));
    await tester.pump();

    // Verificar que se muestre el mensaje de validación.
    expect(find.text('Escribe un título válido'), findsOneWidget);

    // Verificar que SQLite no guardó ninguna tarea.
    final tareas = await db.obtenerTareas();
    expect(tareas, isEmpty);

    // Retirar la pantalla.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
