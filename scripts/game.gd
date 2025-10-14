extends Node

### UI Elements ###
@onready var Ui = $UI
@onready var ScoreLabel = $UI/TopBar/Score/ScoreLabel
@onready var ProblemLabel: Label = $UI/ProblemArea/Problem
@onready var History = $UI/Control
@onready var Charger = $Charge
@onready var StreakLabel = $UI/TopBar/Streak/StreakLabel
@onready var Music = $BgMusic
@onready var MusicIcon: TextureRect = $MusicBtn/Base/Topbb/MusicIcon

# Options (buttons)
@onready var Option1Label = $UI/GridContainer/Option1/Base/Topbb/Label
@onready var Option2Label = $UI/GridContainer/Option2/Base/Topbb/Label
@onready var Option3Label = $UI/GridContainer/Option3/Base/Topbb/Label
@onready var Option4Label = $UI/GridContainer/Option4/Base/Topbb/Label
@onready var CorrectSound = $Correct
@onready var IncorrectSound = $Incorrect

### Game State ###
#var MathProblem = preload("res://scripts/MathProblem.gd").new()
var MathProblem = preload("res://scripts/M1Problem.gd").new()
var pixel_font = preload("res://font/VCR_OSD_MONO_1.001.ttf")
var CurrentProblem: Dictionary
#var Score: int = 0
var TimeLeft: float = 30.0
var LineHeight := 48 
#var StrakeCount: int = 0
var MusicState: bool = true

# Animation states
var IsAnswerProcessing: bool = false
var FeedbackTween: Tween
var NextProblemReady: bool = true

var NextProblemData: Dictionary
var NextOptionsData: Array


func _ready():
	MusicIcon.modulate = Color(0, 1, 0)
	StartNewGame()
	Charger.TiempoAgotado.connect(OnTiempoAgotado)


func OnTiempoAgotado():
	GameOver()


func OnTiempoActualizado(NuevoTiempo: float):
	TimeLeft = NuevoTiempo


func StartNewGame():
	#Score = 0
	#StrakeCount = 0
	Global.Score = 0
	Global.Streak = 0
	
	TimeLeft = 30.0
	NextProblemReady = true
	
	PreGenerateNextProblem()
	DisplayCurrentProblem()
	
	Charger.EstablecerTiempoTotal(TimeLeft)
	Charger.ReiniciarTiempo()


func PreGenerateNextProblem() -> void:
	NextProblemData = MathProblem.GenerateProblem(3)
	#var CorrectAnswer = NextProblemData["answer"]
	NextOptionsData = MathProblem.GenerateOptions(NextProblemData, 4)
	NextProblemReady = true


func DisplayCurrentProblem() -> void:
	if not NextProblemReady:
		return
	
	CurrentProblem = NextProblemData
	ScoreLabel.text = " Score:%d" % Global.Score
	StreakLabel.text = "%d" % Global.Streak
	var ProblemText = MathProblem.GetProblemText(CurrentProblem)
	#ProblemLabel.set_auto_text(ProblemText)
	ProblemLabel.text = ProblemText
	_get_autosize_font_size(ProblemLabel)

	Option1Label.text = str(NextOptionsData[0])
	Option2Label.text = str(NextOptionsData[1])
	Option3Label.text = str(NextOptionsData[2])
	Option4Label.text = str(NextOptionsData[3])
	
	NextProblemReady = false
	call_deferred("PreGenerateNextProblem")


func _get_autosize_font_size(label: Label, min_font_size: int = 8, max_font_size: int = 48) -> int:
	var aux_text := label.text
	var base_font := label.get_theme_font("font")
	
	var width_limit := label.size.x # will use control data for more accurate behavior
	var height_limit := label.size.y # will use control data for more accurate behavior
	var best_font_size := min_font_size
	# Will do a binary search for faster results
	var low := min_font_size
	var high := max_font_size
	while low <= high:
		var mid := int((low + high) * 0.5) # Test font size
		var text_size := base_font.get_multiline_string_size(aux_text, label.horizontal_alignment,\
			width_limit, mid, 3)
		# WARNING for some reason is returning a wrong height while setting max line count
		# thus making max_lines != INFINITE_MAX_LINES unusable.
		var text_width := text_size.x
		var text_height := text_size.y
		# Will test size withouth waiting a frame draw.
		if text_width <= width_limit and text_height <= height_limit:
			best_font_size = mid
			low = mid + 1  # Try bigger
		else:
			high = mid - 1  # Try smaller
	
	label.add_theme_font_size_override("font_size", best_font_size)
	return best_font_size

func CalculateDifficulty() -> int:
	return min(Global.Score / 5 + 1, 5)


func is_equal_flexible(a, b) -> bool:
	if a == null and b == null:
		return true

	if typeof(a) == typeof(b):
		if a is float or a is int:
			return is_equal_approx(float(a), float(b))
		return a == b

	var a_num = null
	var b_num = null
	var a_is_num = false
	var b_is_num = false

	if a is float or a is int:
		a_num = float(a)
		a_is_num = true
	elif a is String and a.is_valid_float():
		a_num = float(a)
		a_is_num = true

	if b is float or b is int:
		b_num = float(b)
		b_is_num = true
	elif b is String and b.is_valid_float():
		b_num = float(b)
		b_is_num = true

	if a_is_num and b_is_num:
		return is_equal_approx(a_num, b_num)

	if str(a) == str(b):
		return true

	return false



func GameOver():
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func StopMusic():
	if MusicState:
		Music.stop()
		MusicIcon.modulate = Color.BLACK
	else:
		Music.play()
		MusicIcon.modulate = Color.GREEN
	MusicState = !MusicState

func OnOptionSelected(SelectedValue: String):
	if IsAnswerProcessing:
		return
	
	IsAnswerProcessing = true
	
	#var PlayerNum = SelectedValue.to_float()
	var CorrectNum = CurrentProblem["answer"]
	var IsCorrect = is_equal_flexible(SelectedValue, CorrectNum)
	
	var HistoryText = MathProblem.GetProblemText(CurrentProblem) + SelectedValue
	
	ShowInstantFeedback(HistoryText, IsCorrect)
	
	if IsCorrect:
		Global.Score += 1
		Global.Streak += 1
		CorrectSound.play()
		Charger.AgregarTiempoExtra(0.5)
		if Global.Streak > Global.HighestStreak:
			Global.HighestStreak = Global.Streak
	else:
		Global.Streak = 0
		IncorrectSound.play()
	
	
	History.add_message(HistoryText, IsCorrect)
	ShowRapidTransition()


func ShowInstantFeedback(HistoryText: String, IsCorrect: bool):
	ProblemLabel.text = HistoryText
	ProblemLabel.modulate = Color.GREEN if IsCorrect else Color.RED
	
	if FeedbackTween:
		FeedbackTween.kill()
	
	FeedbackTween = create_tween()
	FeedbackTween.tween_property(ProblemLabel, "modulate", Color.WHITE, 0.15)


func ShowRapidTransition():
	await get_tree().create_timer(0.08).timeout
	
	IsAnswerProcessing = false
	DisplayCurrentProblem()


func OnOptionSelectedInstant(SelectedValue: String):
	if IsAnswerProcessing:
		return
	
	IsAnswerProcessing = true
	
	var CorrectNum = CurrentProblem["answer"]
	var IsCorrect = is_equal_flexible(SelectedValue, CorrectNum)
	
	var HistoryText = MathProblem.GetProblemText(CurrentProblem) + SelectedValue
	
	if IsCorrect:
		Global.Score += 1
		CorrectSound.play()
	else:
		IncorrectSound.play()
	
	History.add_message(HistoryText, IsCorrect)
	ProblemLabel.modulate = Color.GREEN if IsCorrect else Color.RED
	call_deferred("InstantNextProblem")


func InstantNextProblem():
	ProblemLabel.modulate = Color.WHITE
	IsAnswerProcessing = false
	DisplayCurrentProblem()
