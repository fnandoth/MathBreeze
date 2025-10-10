extends Node

@onready var StreakLabel = $Bg/Streak/Streak2
@onready var ScoreLabel = $Bg/Score/Score2


func _ready():
	ScoreLabel.text = " %d" % Global.Score
	StreakLabel.text = "%d" % Global.HighestStreak
	SaveData()


func SaveData():
	if Global.Score > Global.GHighestScore:
		Global.GHighestScore = Global.Score
	
	if Global.HighestStreak > Global.GHighestStreak:
		Global.GHighestStreak = Global.HighestStreak 
	Global.save_data()
