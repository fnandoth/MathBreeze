extends Node

### UI Elements ###
@onready var Ui = $UI
@onready var ScoreLabel = $UI/TopBar/Score/ScoreLabel
@onready var ProblemLabel = $UI/ProblemArea/Problem
@onready var History = $UI/Control/BoxHistory
@onready var Charger = $Charge
@onready var StreakLabel = $UI/TopBar/Streak/StreakLabel

# Options (buttons)
@onready var Option1Label = $UI/GridContainer/Option1/Base/Topbb/Label
@onready var Option2Label = $UI/GridContainer/Option2/Base/Topbb/Label
@onready var Option3Label = $UI/GridContainer/Option3/Base/Topbb/Label
@onready var Option4Label = $UI/GridContainer/Option4/Base/Topbb/Label
@onready var CorrectSound = $Correct
@onready var IncorrectSound = $Incorrect

### Game State ###
var MathProblem = preload("res://scripts/MathProblem.gd").new()
var CurrentProblem: Dictionary
#var Score: int = 0
var TimeLeft: float = 30.0
var LineHeight := 48 
#var StrakeCount: int = 0

# Animation states
var IsAnswerProcessing: bool = false
var FeedbackTween: Tween
var NextProblemReady: bool = true

# Pre-generation variables
var NextProblemData: Dictionary
var NextOptionsData: Array


func _ready():
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
	
	Charger.EstablecerTiempoTotal(30.0)
	Charger.ReiniciarTiempo()


func PreGenerateNextProblem() -> void:
	NextProblemData = MathProblem.GenerateProblem(CalculateDifficulty())
	var CorrectAnswer = NextProblemData["answer"]
	NextOptionsData = MathProblem.GenerateOptions(CorrectAnswer)
	NextProblemReady = true


func DisplayCurrentProblem() -> void:
	if not NextProblemReady:
		return
	
	CurrentProblem = NextProblemData
	ScoreLabel.text = " Score:%d" % Global.Score
	StreakLabel.text = "%d" % Global.Streak
	ProblemLabel.text = MathProblem.GetProblemText(CurrentProblem)
	
	Option1Label.text = str(NextOptionsData[0])
	Option2Label.text = str(NextOptionsData[1])
	Option3Label.text = str(NextOptionsData[2])
	Option4Label.text = str(NextOptionsData[3])
	
	NextProblemReady = false
	call_deferred("PreGenerateNextProblem")


func CalculateDifficulty() -> int:
	return min(Global.Score / 5 + 1, 5)


func IsEqualApprox(a: float, b: float) -> bool:
	return abs(a - b) < 0.0001


func GameOver():
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func OnOptionSelected(SelectedValue: String):
	if IsAnswerProcessing:
		return
	
	IsAnswerProcessing = true
	
	var PlayerNum = SelectedValue.to_float()
	var CorrectNum = CurrentProblem["answer"]
	var IsCorrect = IsEqualApprox(PlayerNum, CorrectNum)
	
	var HistoryText = MathProblem.GetProblemText(CurrentProblem) + SelectedValue
	
	ShowInstantFeedback(HistoryText, IsCorrect)
	
	if IsCorrect:
		Global.Score += 1
		Global.Streak += 1
		CorrectSound.play()
		Charger.AgregarTiempoExtra(0.5)
	else:
		if Global.Streak > Global.HighestScore:
			Global.HighestStreak = Global.Streak
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
	
	var PlayerNum = SelectedValue.to_float()
	var CorrectNum = CurrentProblem["answer"]
	var IsCorrect = IsEqualApprox(PlayerNum, CorrectNum)
	
	var HistoryText = MathProblem.GetProblemText(CurrentProblem) + SelectedValue
	
	if IsCorrect:
		Global.Score += 1
		CorrectSound.play()
	else:
		IncorrectSound.play()
	
	History.AddMessage(HistoryText, IsCorrect)
	ProblemLabel.modulate = Color.GREEN if IsCorrect else Color.RED
	call_deferred("InstantNextProblem")


func InstantNextProblem():
	ProblemLabel.modulate = Color.WHITE
	IsAnswerProcessing = false
	DisplayCurrentProblem()
