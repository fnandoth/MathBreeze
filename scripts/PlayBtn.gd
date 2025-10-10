extends Node2D

@onready var animation = $Base/press
@onready var labelNode = $Base/Topbb/Label
@onready var PressSound = $Base/Click

var IsButtonLocked: bool = false
const MinimalCooldownTime: float = 0.05
var CooldownTimer: Timer


func _ready():
	CooldownTimer = Timer.new()
	add_child(CooldownTimer)
	CooldownTimer.one_shot = true
	CooldownTimer.timeout.connect(_on_cooldown_end)


func _on_button_pressed():
	if IsButtonLocked:
		return
	PressSound.play()
	animation.play("press")
	
	start_minimal_cooldown()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func start_minimal_cooldown():
	IsButtonLocked = true
	CooldownTimer.start(MinimalCooldownTime)


func _on_cooldown_end():
	IsButtonLocked = false


func _on_button_pressed_instant():
	var GameNode = get_parent().get_parent().get_parent()
	if GameNode.IsAnswerProcessing:
		return
	PressSound.play()
	animation.play("press")
