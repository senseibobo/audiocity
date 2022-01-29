extends Control

var buttons: Array
var mode_selected: String
const song_scene = preload("res://Game/Song.tscn")

func _ready():
	load_songs()
	buttons = get_all_buttons(self)
	for button in buttons:
		button.rect_pivot_offset = button.rect_size / 2
		button.self_modulate = Color(3.0,3.0,3.0,1.0);
	
func load_songs():
	var song_files = list_files_in_directory("res://Beatmaps")
	for path in song_files:
		var song = song_scene.instance()
		song.text = path.substr(0,path.length()-5)
		$Songs/HBoxContainer/ScrollContainer/VBoxContainer.add_child(song)
		song.connect("pressed",self,"song_selected",["res://Beatmaps/"+path])

func song_selected(path: String):
	Global.selected_song = path
	if mode_selected == "Edit":
		edit_song()
	else:
		play_game()

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".json"):
			files.append(file)

	dir.list_dir_end()

	return files

func _process(delta):
	for button in buttons:
		var button_rect: Rect2 = button.get_global_rect()
		button_rect.size *= button.rect_scale
		if not button_rect.has_point(get_global_mouse_position()):
			button.rect_scale = lerp(button.rect_scale,Vector2(1.0,1.0),12*delta)
		elif Input.is_mouse_button_pressed(BUTTON_LEFT):
			button.rect_scale = lerp(button.rect_scale,Vector2(2.2,2.2),30*delta)
		else:
			button.rect_scale = lerp(button.rect_scale,Vector2(2.0,2.0),30*delta)
			
		

func get_all_buttons(node: Control):
	var b: Array = []
	if is_instance_valid(node):
		for child in node.get_children():
			if child is Button:
				b.append(child)
			b.append_array(get_all_buttons(child))
	return b
	
	
func _on_Play_pressed():
	mode_selected = "Play"
	Tools.tween(
		$Songs,
		"rect_position",
		Vector2(1500.0,0.0),
		Vector2(488,0.0),
		0.5,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)
	$Songs.visible = true
	$Songs/HBoxContainer/ScrollContainer/Label.text = "Play song!"
	$Songs/HBoxContainer/ScrollContainer/VBoxContainer/Song.visible = false
	yield(
	Tools.tween(
		$CenterContainer,
		"rect_position",
		Vector2(0,0.0),
		Vector2(-1000,0.0),
		0.5,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN
	),"tween_all_completed")
	$CenterContainer.visible = false

func play_game():
	Transition.transition()
	var error = get_tree().change_scene_to(Global.game_scene)

func edit_song():
	Transition.transition()
	var error = get_tree().change_scene_to(Global.editor_scene)

func _on_Create_pressed():
	mode_selected = "Edit"
	Tools.tween(
		$Songs,
		"rect_position",
		Vector2(1500.0,0.0),
		Vector2(488,0.0),
		0.5,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)
	$Songs.visible = true
	$Songs/HBoxContainer/ScrollContainer/Label.text = "Edit song chart"
	$Songs/HBoxContainer/ScrollContainer/VBoxContainer/Song.visible = true
	yield(
	Tools.tween(
		$CenterContainer,
		"rect_position",
		Vector2(0,0.0),
		Vector2(-1000,0.0),
		0.5,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN
	),"tween_all_completed")
	$CenterContainer.visible = false


func _on_NewSong_pressed():
	Global.selected_song = "new"
	edit_song()
	


func _on_Back_pressed():
	$CenterContainer.visible = true
	Tools.tween(
		$CenterContainer,
		"rect_position",
		Vector2(-1000,0.0),
		Vector2(0,0.0),
		0.5,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)
	yield(Tools.tween(
		$Songs,
		"rect_position",
		$Songs.rect_position,
		Vector2(1500.0,0.0),
		0.5,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN
	),"tween_all_completed")
	$Songs.visible = false
	
