import 'package:flutter/material.dart';

import '../data/app_database.dart';

class TareasPage extends StatefulWidget {
  const TareasPage({super.key, this.database});

  final AppDatabase? database;

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();
  late final AppDatabase _db;

  List<Tarea> _tareas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _db = widget.database ?? AppDatabase();
    _cargarTareas();
  }

  // Consultar tareas guardadas en SQLite
  Future<void> _cargarTareas() async {
    try {
      final tareas = await _db.obtenerTareas();

      if (!mounted) return;

      setState(() {
        _tareas = tareas;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      _mostrarMensaje('Error al cargar las tareas: $e');
    }
  }

  // Agregar una tarea
  Future<void> _agregarTarea() async {
    final titulo = _tituloController.text.trim();

    if (titulo.isEmpty) {
      _mostrarMensaje('Escribe un título válido');
      return;
    }

    try {
      await _db.agregarTarea(titulo);
      _tituloController.clear();
      await _cargarTareas();
    } catch (e) {
      _mostrarMensaje('Error al guardar la tarea: $e');
    }
  }

  // Marcar como completada o pendiente
  Future<void> _alternarCompletada(Tarea tarea, bool completada) async {
    try {
      await _db.cambiarEstado(tarea.id, completada);
      await _cargarTareas();
    } catch (e) {
      _mostrarMensaje('Error al actualizar la tarea: $e');
    }
  }

  // Editar el título
  Future<void> _editarTarea(Tarea tarea) async {
    final controller = TextEditingController(text: tarea.titulo);

    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar tarea'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nuevo título'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (!mounted || nuevoTitulo == null) return;

    if (nuevoTitulo.trim().isEmpty) {
      _mostrarMensaje('El título no puede estar vacío');
      return;
    }

    try {
      await _db.editarTarea(tarea.id, nuevoTitulo);
      await _cargarTareas();
    } catch (e) {
      _mostrarMensaje('Error al editar la tarea: $e');
    }
  }

  // Eliminar una tarea por su ID
  Future<void> _eliminarTarea(Tarea tarea) async {
    try {
      await _db.eliminarTarea(tarea.id);
      await _cargarTareas();
    } catch (e) {
      _mostrarMensaje('Error al eliminar la tarea: $e');
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _tareas.isEmpty
                  ? const Center(child: Text('Todavía no hay tareas guardadas'))
                  : ListView.builder(
                      itemCount: _tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = _tareas[index];

                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: tarea.completada,
                              onChanged: (valor) {
                                if (valor != null) {
                                  _alternarCompletada(tarea, valor);
                                }
                              },
                            ),
                            title: Text(
                              tarea.titulo,
                              style: TextStyle(
                                decoration: tarea.completada
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text('ID: ${tarea.id}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editarTarea(tarea),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _eliminarTarea(tarea),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
