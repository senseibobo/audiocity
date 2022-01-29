extends Node


var selected_song: String

const main_scene: PackedScene = preload("res://Menu/Main.tscn")
const game_scene: PackedScene = preload("res://Game/Game.tscn")
const editor_scene: PackedScene = preload("res://Editor/Editor.tscn")
const finish_screen_scene: PackedScene = preload("res://Game/FinishScreen.tscn")

var highscore: float
var score: float
var hits: float
var misses: float
var accuracy: float
var max_combo: float

func save_highscore():
	var file = File.new()
	file.open(selected_song,file.READ_WRITE)
	var chart_dict: Dictionary = parse_json(file.get_as_text())
	file.seek(0)
	chart_dict["highscore"] = highscore
	file.store_string(JSON.print(chart_dict))
	file.close()
