
# Gestor de tareas con SQLite

Práctica de Programación de Dispositivos Móviles.

Aplicación desarrollada en Flutter para administrar tareas mediante una base de datos SQLite local y persistente, sin necesidad de un servidor ni conexión a internet para las operaciones CRUD.

## Funcionalidades

- Agregar tareas con un título válido.
- Consultar las tareas almacenadas.
- Editar el título de una tarea.
- Marcar tareas como completadas o pendientes.
- Eliminar tareas mediante su identificador.
- Conservar los datos al cerrar y volver a abrir la aplicación.
- Mostrar mensajes de validación y errores.

## Tecnologías utilizadas

- Flutter 3.47.0 y Dart 3.13.0.
- SQLite como base de datos local.
- `drift` para definir la tabla y realizar consultas.
- `drift_flutter` para configurar la conexión según la plataforma.
- `drift_dev` y `build_runner` para generar código.
- `sqlite3` y `flutter_test` para las pruebas automatizadas.

Se eligió Drift porque permite trabajar con SQLite desde Flutter utilizando una misma capa de persistencia para distintas plataformas.

## Estructura principal

```text
lib/
  main.dart
  data/
    app_database.dart
    app_database.g.dart
  screens/
    tareas_page.dart

test/
  widget_test.dart
  database_test.dart

web/
  sqlite3.wasm
  drift_worker.dart.js
```

La tabla `Tareas` contiene:

| Campo | Tipo | Descripción |
|---|---|---|
| id | INTEGER | Identificador único autoincremental |
| titulo | TEXT | Nombre de la tarea |
| completada | BOOLEAN | Indica si está completada; por defecto, false |

## Instalación y ejecución

Requisitos:
- Flutter SDK instalado.
- Un editor como Visual Studio Code.
- Chrome para la ejecución web.
- Android SDK y un dispositivo Android para la ejecución móvil.

Clonar el repositorio:

```bash
git clone https://github.com/DannaMajhli/gestor_tareas_local.git
cd gestor_tareas_local
```

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar en Chrome:

```bash
flutter run -d chrome --web-port 8080
```

Se utiliza el puerto 8080 para conservar el mismo origen durante las pruebas de persistencia web.

Ejecutar en Android:

```bash
flutter devices
flutter run -d <ID_DEL_DISPOSITIVO>
```

El dispositivo debe tener habilitada la depuración USB.

## Persistencia local

La aplicación utiliza `AppDatabase`, definida en `lib/data/app_database.dart`.

Las operaciones de agregar, consultar, editar, cambiar el estado y eliminar tareas se ejecutan mediante Drift sobre SQLite.

Después de cada operación de escritura, la pantalla vuelve a consultar las tareas para actualizar la interfaz. No se realizan consultas a la base de datos dentro del método `build()`.

En Android, los datos permanecen en el almacenamiento local de la aplicación. En web, la persistencia depende del origen y del perfil del navegador.

Las bases de datos de Android y Chrome son independientes; las tareas no se sincronizan entre dispositivos.

Para Flutter Web se incluyen los recursos `sqlite3.wasm` y `drift_worker.dart.js` en la carpeta `web/`.

## Plataformas

El proyecto está diseñado con Flutter y Drift para Android, iOS, Windows, Linux, macOS y web.

Plataformas verificadas:

- **Chrome:** ejecución, operaciones CRUD y persistencia.
- **Android:** ejecución en Motorola moto g 7 power con Android 10 y comprobación de persistencia después de cerrar y volver a abrir la aplicación.

Windows, Linux, macOS e iOS no se verificaron mediante ejecución en esta práctica.

## Pruebas manuales

| Prueba | Resultado en Chrome |
|---|---|
| P1. Agregar tres tareas, cerrar y reabrir | Aprobada |
| P2. Marcar una tarea y reiniciar | Aprobada |
| P3. Editar un título y reiniciar | Aprobada |
| P4. Eliminar una tarea y reiniciar | Aprobada |
| P5. Rechazar títulos vacíos o con espacios | Aprobada |
| P6. Recargar y reabrir en el mismo origen | Aprobada |

En Android también se comprobó que dos tareas, incluyendo una marcada como completada, permanecieran después de cerrar y volver a abrir la aplicación.

## Pruebas automatizadas

Ejecutar:

```bash
flutter test
```

Se implementaron tres pruebas:

1. Verificar que la pantalla inicial muestre sus elementos principales.
2. Insertar una tarea en SQLite y comprobar que pueda recuperarse.
3. Comprobar que una tarea con únicamente espacios sea rechazada y no se almacene.

Las pruebas utilizan una base SQLite temporal en memoria para evitar modificar los datos reales.

Resultado obtenido: **3 pruebas aprobadas**.

Para revisar el código:

```bash
flutter analyze
```

Resultado obtenido: **No issues found!**

## Referencias técnicas

- [Documentación oficial de Flutter](https://docs.flutter.dev/)
- [Persistencia SQLite en Flutter](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [Documentación de Drift](https://drift.simonbinder.eu/)
- [Drift en Flutter Web](https://drift.simonbinder.eu/platforms/web/)
- [Pruebas en Flutter](https://docs.flutter.dev/testing/overview)

## Uso de inteligencia artificial

Se utilizó ChatGPT como apoyo para comprender la configuración de Drift, resolver errores de las pruebas automatizadas y revisar alternativas de implementación.

El funcionamiento se verificó mediante ejecución manual en Chrome y Android, `flutter analyze` y `flutter test`.
