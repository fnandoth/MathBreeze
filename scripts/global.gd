extends Node

var Score: int = 0
var HighestScore: int = 0
var Streak: int = 0
var HighestStreak: int = 0
var Difficulty: int = 1
var GHighestScore: int = 0
var GHighestStreak: int = 0

func _ready() -> void:
	load_data()

func save_data() -> void:
	var data := {
		"HighestScore": GHighestScore,
		"HighestStreak": GHighestStreak
	}
	var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if file == null:
		push_error("Failed to open user://savegame.json for writing.")
		return
	file.store_string(JSON.stringify(data))
	file.close()

func load_data() -> void:
	if not FileAccess.file_exists("user://savegame.json"):
		return
	var file := FileAccess.open("user://savegame.json", FileAccess.READ)
	if file == null:
		push_error("Failed to open user://savegame.json for reading.")
		return
	var content := file.get_as_text().strip_edges()
	file.close()
	if content == "":
		return
	var parsed = JSON.parse_string(content)
	if parsed == null:
		push_error("Failed to parse user://savegame.json.")
		return
	if parsed is Dictionary:
		var data: Dictionary = parsed
		if data.has("HighestScore"):
			GHighestScore = int(data.get("HighestScore", 0))
			HighestScore = GHighestScore
		if data.has("HighestStreak"):
			GHighestStreak = int(data.get("HighestStreak", 0))
			HighestStreak = GHighestStreak
	else:
		push_error("Parsed JSON is not a Dictionary.")
