extends Node2D

@onready var animation = $Base/press
@onready var PressSound = $Base/Click

var SceneName: Label

var scenes := {
	"Main": "res://scenes/main.tscn",
	"M1": "res://scenes/game.tscn",
	"M2": "res://scenes/game_over.tscn"
}


var IsButtonLocked: bool = false
const MinimalCooldownTime: float = 0.05
var CooldownTimer: Timer


func _ready():
	SceneName = get_parent().find_child("SceneName")
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
	ChangeScene()

func ChangeScene():
	var textName = SceneName.text
	if textName in scenes:
		get_tree().change_scene_to_file(scenes[textName])
	else:
		push_warning("Unknown scene: %s" % textName)

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
