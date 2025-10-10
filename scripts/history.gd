extends Control
## Contenedor para historial de mensajes con animación automática "push-up" OPTIMIZADA.

# ==== CONFIGURACIÓN OPTIMIZADA ====
@export var anim_duration := 0.12     # Duración más rápida (era 0.2)
@export var max_messages := 3         # Máximo de mensajes visibles
@export var fade_out_duration := 0.15 # Fade out más rápido (era 0.3)

# Posiciones fijas optimizadas
const pos = [500, 100.0, 0.0, -100.0]

# Fuente personalizada
const PIXEL_FONT = preload("res://font/VCR_OSD_MONO_1.001.ttf")

# ==== ESTADO OPTIMIZADO ====
var message_entries := []
var message_counter := 0

# Pool de Labels reutilizables para mejor rendimiento
var label_pool := []
const POOL_SIZE := 5

func _ready() -> void:
	clip_contents = true
	_initialize_label_pool()

# Inicializar pool de labels reutilizables
func _initialize_label_pool():
	for i in POOL_SIZE:
		var label = _create_optimized_label()
		label.visible = false
		add_child(label)
		label_pool.append(label)

func _create_optimized_label() -> Label:
	var label := Label.new()
	label.add_theme_font_override("font", PIXEL_FONT)
	label.add_theme_font_size_override("font_size", 56)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(PRESET_HCENTER_WIDE)
	return label

# Obtener label del pool o crear nuevo si es necesario
func _get_label_from_pool() -> Label:
	for label in label_pool:
		if not label.visible:
			return label
	
	# Si no hay disponibles, crear uno nuevo
	var new_label = _create_optimized_label()
	add_child(new_label)
	label_pool.append(new_label)
	return new_label

# Devolver label al pool
func _return_label_to_pool(label: Label):
	label.visible = false
	label.modulate.a = 1.0  # Resetear alpha
	label.text = ""

## API OPTIMIZADA - Versión con menos animación para máxima velocidad
func add_message(text: String, is_correct: bool) -> void:
	# Obtener label del pool
	var label = _get_label_from_pool()
	
	# Configurar label
	label.text = text
	label.modulate = Color.GREEN if is_correct else Color.RED
	label.modulate.a = 1.0
	label.visible = true
	
	# Posicionar inicialmente
	label.position.y = pos[0]
	
	# Crear entrada de tracking
	message_counter += 1
	var entry_data = {
		"node": label,
		"id": message_counter,
		"current_stage": 0,
		"target_stage": 1,
		"is_animating": false
	}
	
	message_entries.append(entry_data)
	
	# Verificar si necesitamos eliminar el más antiguo
	_check_and_remove_oldest()
	
	# Animación más rápida
	_animate_all_messages_fast()

## Versión de animación más rápida
func _animate_all_messages_fast():
	_calculate_target_positions()
	
	for entry in message_entries:
		if is_instance_valid(entry.node) and entry.node.visible:
			_animate_message_fast(entry)

func _animate_message_fast(entry: Dictionary):
	if not is_instance_valid(entry.node) or entry.is_animating or not entry.node.visible:
		return
	
	var current_pos = entry.node.position.y
	var target_pos = pos[entry.target_stage]
	
	if abs(current_pos - target_pos) < 1.0:
		return
	
	entry.is_animating = true
	
	# Tween más rápido y suave
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(entry.node, "position:y", target_pos, anim_duration)
	tween.tween_callback(_on_message_animation_complete_fast.bind(entry))

func _on_message_animation_complete_fast(entry: Dictionary):
	entry.is_animating = false
	entry.current_stage = entry.target_stage
	
	if entry.current_stage == pos.size() - 1:
		_fade_out_and_remove_message_fast(entry)

func _calculate_target_positions():
	var visible_messages = message_entries.filter(func(e): return is_instance_valid(e.node) and e.node.visible)
	
	for i in range(visible_messages.size()):
		var entry = visible_messages[visible_messages.size() - 1 - i]
		var target_pos_index = i + 1
		
		if target_pos_index < pos.size() - 1:
			entry.target_stage = target_pos_index
		else:
			entry.target_stage = pos.size() - 1

func _check_and_remove_oldest():
	var visible_count = message_entries.filter(func(e): return is_instance_valid(e.node) and e.node.visible).size()
	
	if visible_count > max_messages:
		var oldest_entry = null
		for entry in message_entries:
			if is_instance_valid(entry.node) and entry.node.visible:
				if oldest_entry == null or entry.id < oldest_entry.id:
					oldest_entry = entry
		
		if oldest_entry:
			_fade_out_and_remove_message_fast(oldest_entry)

func _fade_out_and_remove_message_fast(entry: Dictionary):
	if not is_instance_valid(entry.node) or not entry.node.visible:
		_remove_entry_from_list(entry)
		return
	
	# Fade out más rápido
	var fade_tween = create_tween()
	fade_tween.tween_property(entry.node, "modulate:a", 0.0, fade_out_duration)
	fade_tween.tween_callback(_remove_message_fast.bind(entry))

func _remove_message_fast(entry: Dictionary):
	if is_instance_valid(entry.node):
		_return_label_to_pool(entry.node)
	
	_remove_entry_from_list(entry)

func _remove_entry_from_list(entry: Dictionary):
	var index = message_entries.find(entry)
	if index != -1:
		message_entries.remove_at(index)

## VERSIÓN INSTANTÁNEA - Sin animaciones para máxima velocidad
func add_message_instant(text: String, is_correct: bool) -> void:
	# Mover mensajes existentes instantáneamente
	_shift_existing_messages_instant()
	
	# Crear nuevo mensaje
	var label = _get_label_from_pool()
	label.text = text
	label.modulate = Color.GREEN if is_correct else Color.RED
	label.modulate.a = 1.0
	label.visible = true
	label.position.y = pos[1]  # Posición superior directamente
	
	message_counter += 1
	var entry_data = {
		"node": label,
		"id": message_counter,
		"current_stage": 1,
		"is_animating": false
	}
	
	message_entries.append(entry_data)
	_check_and_remove_oldest_instant()

func _shift_existing_messages_instant():
	var visible_messages = message_entries.filter(func(e): return is_instance_valid(e.node) and e.node.visible)
	
	for i in range(visible_messages.size()):
		var entry = visible_messages[i]
		var new_stage = entry.current_stage + 1
		
		if new_stage < pos.size() - 1:
			entry.current_stage = new_stage
			entry.node.position.y = pos[new_stage]
		else:
			# Eliminar instantáneamente
			_return_label_to_pool(entry.node)
			_remove_entry_from_list(entry)

func _check_and_remove_oldest_instant():
	var visible_count = message_entries.filter(func(e): return is_instance_valid(e.node) and e.node.visible).size()
	
	if visible_count > max_messages:
		var oldest_entry = null
		for entry in message_entries:
			if is_instance_valid(entry.node) and entry.node.visible:
				if oldest_entry == null or entry.id < oldest_entry.id:
					oldest_entry = entry
		
		if oldest_entry:
			_return_label_to_pool(oldest_entry.node)
			_remove_entry_from_list(oldest_entry)

## Función de utilidad
func clear_all_messages():
	for entry in message_entries:
		if is_instance_valid(entry.node):
			_return_label_to_pool(entry.node)
	
	message_entries.clear()
	message_counter = 0

func get_active_message_count() -> int:
	return message_entries.filter(func(e): return is_instance_valid(e.node) and e.node.visible).size()
