extends Control

enum MODES {
	ADD,
	DELETE,
	MODIFY
}

var beat: float
var note_spread: float = 400.0
var player_offset: float = 220.0
var bpm: float = 128
var song_path: String

var dragging: bool = false
var playing: bool = false
var mode: int = MODES.ADD
var speed: float = 1.0
var metronome: bool = false


func _unhandled_input(event):
	if event is InputEventMouseMotion and dragging:
		beat -= event.relative.x/note_spread
	elif Input.is_action_just_pressed("editor_left_click"):
		dragging = true
	elif Input.is_action_just_released("editor_left_click"):
		dragging = false
	elif Input.is_action_just_pressed("editor_play"): toggle_playing()
	elif Input.is_action_just_pressed("editor_reset"): reset()
	elif Input.is_action_just_pressed("editor_slow_down"): change_speed(-0.05)
	elif Input.is_action_just_pressed("editor_speed_up"): change_speed(0.05)
	elif Input.is_action_just_pressed("editor_zoom_in"): change_zoom(10)
	elif Input.is_action_just_pressed("editor_zoom_out"): change_zoom(-10)

func change_zoom(value: float):
	note_spread += value
	note_spread = clamp(note_spread,20,1600)

func change_speed(value: float):
	speed += value
	speed = clamp(speed,0.05,10.0)
	$MusicPlayer.pitch_scale = speed

func reset():
	beat = 0
	if playing:
		$MusicPlayer.seek(0.0)

func toggle_playing():
	print("toggle")
	playing = not playing
	if playing:
		beat = int(beat)
		$MusicPlayer.play(get_time_from_beat(beat))
	else:
		$MusicPlayer.stop()

func _process(delta):
	if playing:
		var old_beat = beat
		beat += bpm/60.0*delta*speed
		if metronome and int(old_beat) != int(beat):
			$Metronome.play()
	update()

func _draw():
	_draw_main_line()
	_draw_beat_sim()
	_draw_support_lines()

func _draw_beat_sim():
	var pos = get_beat_position(beat)
	draw_line(Vector2(pos,0),Vector2(pos,720),Color.blue,3.0)

func _draw_main_line():
	var pos = get_beat_position(0)
	draw_line(Vector2(pos,0),Vector2(pos,720),Color.red,6.0)
	
func _draw_support_lines():
	var pos = (fposmod(-beat,1.0)-4.0)*note_spread+player_offset
	var pt: Vector2 = Vector2(pos,0)
	var points = []
	while pt.x < 1280.0:
		points.append(pt)
		pt.y += 720.0
		points.append(pt)
		pt.x += note_spread
		points.append(pt)
		pt.y -= 720.0
		points.append(pt)
		pt.x += note_spread
	draw_multiline(PoolVector2Array(points),Color.red,1000.0)
	
func get_beat_position(b: float):
	return (b-beat)*note_spread + player_offset

func get_beat_from_position(x: float):
	return (beat*note_spread-player_offset+x)/note_spread

func get_lane_from_position(y: float):
	return int(abs(y-300) > abs(y-420))

func get_time_from_beat(b: float):
	return b*bpm/60.0

func _on_ChooseMode_item_selected(index: int):
	mode = index
	$Panel/VBoxContainer/AddNotes.visible = mode == MODES.ADD


func _on_ChooseSong_pressed():
	$ChooseSongFile.show()


func _on_ChooseSongFile_file_selected(path: String):
	song_path = path
	$MusicPlayer.stream = load(song_path)

func _on_Metronome_toggled(button_pressed: bool):
	metronome = button_pressed
