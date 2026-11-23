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

  static const Color _morado = Color(0xFF7255B5);
  static const Color _fondo = Color(0xFFF8F6FC);

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
    final completadas = _tareas.where((t) => t.completada).length;
    final pendientes = _tareas.length - completadas;

    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        title: const Text(
          'Gestor de tareas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _morado,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado personalizado
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFECE5FA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mis tareas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _morado,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Organiza tu día, una tarea a la vez.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF655B75)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Campo para agregar tareas
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Nueva tarea',
                  prefixIcon: const Icon(Icons.edit_note, color: _morado),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Botón principal
              FilledButton.icon(
                onPressed: _agregarTarea,
                style: FilledButton.styleFrom(
                  backgroundColor: _morado,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Agregar tarea'),
              ),
              const SizedBox(height: 18),

              // Contadores
              Row(
                children: [
                  Expanded(
                    child: _contador(
                      'Pendientes',
                      pendientes,
                      Icons.schedule,
                      const Color(0xFF9468C9),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _contador(
                      'Completadas',
                      completadas,
                      Icons.check_circle_outline,
                      const Color(0xFF438C77),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              const Text(
                'Lista de tareas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF40364F),
                ),
              ),
              const SizedBox(height: 8),

              // Lista de tareas guardadas
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _tareas.isEmpty
                    ? const Center(
                        child: Text(
                          'Todavía no hay tareas guardadas',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tareas.length,
                        itemBuilder: (context, index) {
                          final tarea = _tareas[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 1,
                            color: tarea.completada
                                ? const Color(0xFFE9F5EF)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              leading: Checkbox(
                                activeColor: _morado,
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
                                  fontWeight: FontWeight.w600,
                                  color: tarea.completada
                                      ? const Color(0xFF56826D)
                                      : const Color(0xFF40364F),
                                  decoration: tarea.completada
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                tarea.completada
                                    ? 'Completada · ID: ${tarea.id}'
                                    : 'Pendiente · ID: ${tarea.id}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Editar',
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: _morado,
                                    ),
                                    onPressed: () => _editarTarea(tarea),
                                  ),
                                  IconButton(
                                    tooltip: 'Eliminar',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Color(0xFFBF6277),
                                    ),
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
      ),
    );
  }

  // Tarjeta pequeña con el número de tareas
  Widget _contador(String titulo, int cantidad, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$cantidad',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(titulo, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
