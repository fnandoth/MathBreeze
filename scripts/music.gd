extends Node2D

@onready var animation = $Base/press

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
	animation.play("press")
	var GameNode = get_parent().StopMusic()
	
	start_minimal_cooldown()



func start_minimal_cooldown():
	IsButtonLocked = true
	CooldownTimer.start(MinimalCooldownTime)


func _on_cooldown_end():
	IsButtonLocked = false


func _on_button_pressed_instant():
	var GameNode = get_parent().get_parent().get_parent()
	if GameNode.IsAnswerProcessing:
		return
	animation.play("press")
