extends Control

signal message_added(text: String, is_correct: bool)
signal message_removed(message_id: int)
signal history_cleared()


@export_group("Comportamiento")
@export var max_visible_messages: int = 3
@export var use_animations: bool = true

@export_group("Timing")
@export_range(0.05, 1.0, 0.05) var animation_duration: float = 0.12
@export_range(0.05, 0.5, 0.05) var fade_duration: float = 0.15

@export_group("Apariencia")
@export var correct_color: Color = Color.GREEN
@export var incorrect_color: Color = Color.RED
@export_range(12, 32) var min_font_size: int = 12
@export_range(12, 32) var max_font_size: int = 22

@export_group("Pool")
@export_range(3, 10) var pool_size: int = 5

const STAGE_POSITIONS: Array[float] = [500.0, 100.0, 0.0, -100.0]

enum Stage {
	HIDDEN_BOTTOM = 0,
	NEWEST = 1,
	MIDDLE = 2,
	OLDEST = 3
}


var _label_pool: Array[Label] = []
var _active_messages: Array[MessageEntry] = []
var _next_message_id: int = 0


class MessageEntry:
	var label: Label
	var id: int
	var current_stage: Stage
	var target_stage: Stage
	var is_animating: bool = false
	
	func _init(p_label: Label, p_id: int, p_stage: Stage) -> void:
		label = p_label
		id = p_id
		current_stage = p_stage
		target_stage = p_stage
	
	func is_valid() -> bool:
		return is_instance_valid(label) and label.visible

func _ready() -> void:
	clip_contents = true
	_initialize_pool()

func add_message(text: String, is_correct: bool) -> void:
	if use_animations:
		_add_message_animated(text, is_correct)
	else:
		_add_message_instant(text, is_correct)
	
	message_added.emit(text, is_correct)


func clear_history() -> void:
	for entry in _active_messages:
		if entry.is_valid():
			_return_label_to_pool(entry.label)
	
	_active_messages.clear()
	_next_message_id = 0
	history_cleared.emit()


func get_message_count() -> int:
	return _active_messages.filter(func(e: MessageEntry) -> bool: return e.is_valid()).size()


func set_animation_mode(enabled: bool) -> void:
	use_animations = enabled


func _initialize_pool() -> void:
	for i in pool_size:
		var label := _create_label()
		label.visible = false
		_label_pool.append(label)

func _create_label() -> Label:
	var label := Label.new()
	
	label.add_theme_font_size_override("font_size", max_font_size)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(PRESET_HCENTER_WIDE)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	add_child(label)
	return label


func _get_label_from_pool() -> Label:
	for label in _label_pool:
		if not label.visible:
			return label
	
	var new_label := _create_label()
	_label_pool.append(new_label)
	return new_label

func _return_label_to_pool(label: Label) -> void:
	label.visible = false
	label.modulate = Color.WHITE
	label.modulate.a = 1.0
	label.text = ""
	label.position.y = STAGE_POSITIONS[Stage.HIDDEN_BOTTOM]


func _add_message_animated(text: String, is_correct: bool) -> void:
	var label := _prepare_label(text, is_correct)
	label.position.y = STAGE_POSITIONS[Stage.HIDDEN_BOTTOM]
	
	var entry := MessageEntry.new(label, _next_message_id, Stage.HIDDEN_BOTTOM)
	entry.target_stage = Stage.NEWEST
	_next_message_id += 1
	
	_active_messages.append(entry)
	_remove_excess_messages()
	_recalculate_positions()
	_animate_all_messages()

func _animate_all_messages() -> void:
	for entry in _active_messages:
		if entry.is_valid():
			_animate_single_message(entry)

func _animate_single_message(entry: MessageEntry) -> void:
	if entry.is_animating or not entry.is_valid():
		return
	
	var current_y := entry.label.position.y
	var target_y := STAGE_POSITIONS[entry.target_stage]
	
	if abs(current_y - target_y) < 1.0:
		entry.current_stage = entry.target_stage
		return
	
	entry.is_animating = true
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(entry.label, "position:y", target_y, animation_duration)
	tween.tween_callback(_on_animation_complete.bind(entry))

func _on_animation_complete(entry: MessageEntry) -> void:
	entry.is_animating = false
	entry.current_stage = entry.target_stage
	
	if entry.current_stage == Stage.OLDEST:
		_fade_and_remove_message(entry)

func _fade_and_remove_message(entry: MessageEntry) -> void:
	if not entry.is_valid():
		_remove_entry(entry)
		return
	
	var tween := create_tween()
	tween.tween_property(entry.label, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(_remove_message.bind(entry))

func _remove_message(entry: MessageEntry) -> void:
	if entry.is_valid():
		_return_label_to_pool(entry.label)
	
	message_removed.emit(entry.id)
	_remove_entry(entry)


func _add_message_instant(text: String, is_correct: bool) -> void:
	_shift_messages_instant()
	
	var label := _prepare_label(text, is_correct)
	label.position.y = STAGE_POSITIONS[Stage.NEWEST]
	
	var entry := MessageEntry.new(label, _next_message_id, Stage.NEWEST)
	_next_message_id += 1
	
	_active_messages.append(entry)
	_remove_excess_messages_instant()

func _shift_messages_instant() -> void:
	var valid_messages := _get_valid_messages()
	
	for entry in valid_messages:
		var new_stage: Stage = entry.current_stage + 1
		
		if new_stage < Stage.OLDEST:
			entry.current_stage = new_stage
			entry.label.position.y = STAGE_POSITIONS[new_stage]
		else:
			_return_label_to_pool(entry.label)
			_remove_entry(entry)

func _remove_excess_messages_instant() -> void:
	var valid_count := get_message_count()
	
	while valid_count > max_visible_messages:
		var oldest := _find_oldest_message()
		if oldest:
			_return_label_to_pool(oldest.label)
			_remove_entry(oldest)
			valid_count -= 1
		else:
			break


func _prepare_label(text: String, is_correct: bool) -> Label:
	var label := _get_label_from_pool()
	
	label.text = text
	label.modulate = correct_color if is_correct else incorrect_color
	label.modulate.a = 1.0
	label.visible = true
	
	_auto_adjust_font_size(label)
	
	return label

func _recalculate_positions() -> void:
	var valid_messages := _get_valid_messages()
	var count := valid_messages.size()
	
	for i in count:
		var entry := valid_messages[count - 1 - i]
		var stage_index: int = mini(i + 1, STAGE_POSITIONS.size() - 1)
		entry.target_stage = stage_index as Stage

func _remove_excess_messages() -> void:
	var valid_count := get_message_count()
	
	if valid_count > max_visible_messages:
		var oldest := _find_oldest_message()
		if oldest:
			_fade_and_remove_message(oldest)

func _find_oldest_message() -> MessageEntry:
	var oldest: MessageEntry = null
	
	for entry in _active_messages:
		if entry.is_valid():
			if oldest == null or entry.id < oldest.id:
				oldest = entry
	
	return oldest

func _get_valid_messages() -> Array[MessageEntry]:
	var valid: Array[MessageEntry] = []
	for entry in _active_messages:
		if entry.is_valid():
			valid.append(entry)
	return valid

func _remove_entry(entry: MessageEntry) -> void:
	var index := _active_messages.find(entry)
	if index != -1:
		_active_messages.remove_at(index)

func _auto_adjust_font_size(label: Label) -> void:
	var base_font := label.get_theme_font("font")
	var width_limit := label.size.x
	var height_limit := label.size.y
	
	var low := min_font_size
	var high := max_font_size
	var best_size := min_font_size
	
	
	while low <= high:
		var mid := (low + high) / 2
		var text_size := base_font.get_multiline_string_size(
			label.text,
			label.horizontal_alignment,
			width_limit,
			mid
		)
		
		if text_size.x <= width_limit and text_size.y <= height_limit:
			best_size = mid
			low = mid + 1
		else:
			high = mid - 1
	
	label.add_theme_font_size_override("font_size", best_size)
