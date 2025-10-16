extends Node2D

@onready var BtnAnimation = $Base/press
@onready var BtnLabel = $Base/Topbb/Label
@onready var BtnSound = $Base/Click

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
	
	BtnAnimation.play("press")
	BtnSound.play()
	
	var SelectedValue = BtnLabel.text
	get_parent().get_parent().get_parent().OnOptionSelected(SelectedValue)
	
	start_minimal_cooldown()

func start_minimal_cooldown():
	IsButtonLocked = true
	CooldownTimer.start(MinimalCooldownTime)

func _on_cooldown_end():
	IsButtonLocked = false

func _on_button_pressed_instant():
	var GameNode = get_parent().get_parent().get_parent()
	if GameNode.is_answer_processing:
		return
	
	BtnAnimation.play("press")
	BtnSound.play()
	
	var SelectedValue = BtnLabel.text
	GameNode.on_option_selected(SelectedValue)
