extends Node


@onready var StreakLabel = $Bg/Streak/Streak2
@onready var ScoreLabel = $Bg/Score/Score2


func _ready():
	ScoreLabel.text = " %d" % Global.GHighestScore
	StreakLabel.text = "%d" % Global.GHighestStreak
