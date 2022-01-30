extends Control

enum MODES {
	ADD,
	DELETE,
	MODIFY
}

enum TYPES {
	BASIC
}

const default = {
	"chart_name": "My chart",
	"time_offset": 0.0,
	"bpm": 128.0,
	"song_path": "res://Sounds/Music/sweden.ogg",
	"volume": 0.0,
	"speed": 1.0
}

var note_spread: float = 400.0

var chart_name: String = "My chart"
var time_offset: float = 0.0
var bpm: float = 128.0
var song_path: String
var volume: float = 0.0
var speed: float = 1.0
var wisps: Array

var beat_speed: float = 200.0
var pos: float = 0.0
var time: float
var beat: float
var dragging: bool = false
var playing: bool = false
var mode: int = MODES.ADD
var metronome: bool = false
var note_sounds: bool = false
var note_type: int = 0
var note_color: String = "white"
var snap_amount: float = 0.25
var selecting: bool = false
var select_time: float = 0.0
var select_y: float = 0.0
var selected_wisps: Array
var wisp_clipboard: Array
var clipboard_time: float
var cursor_time: float
var dragging_notes: bool = false
var note_drag_time: float = 0.0
var note_drag_y: float = 0.0
var drag_change_lanes: bool = false


func _ready():
	if Global.selected_song != "":
		load_beatmap(Global.selected_song)


func _unhandled_input(event):
	if event is InputEventMouseMotion: mouse_motion(event)
	elif Input.is_action_just_pressed("editor_left_click"): left_click()
	elif Input.is_action_just_released("editor_left_click"): release_left_click()
	elif Input.is_action_just_pressed("editor_right_click"): right_click()
	elif Input.is_action_just_released("editor_right_click"): release_right_click()
	elif Input.is_action_just_pressed("editor_play"): toggle_playing()
	elif Input.is_action_just_pressed("editor_reset"): reset()
	elif Input.is_action_just_pressed("editor_add_note"): add_wisp(time)
	elif Input.is_action_just_pressed("editor_add_black_note"): add_black_wisp()
	elif Input.is_action_just_pressed("editor_add_white_note"): add_white_wisp()
	elif Input.is_action_just_pressed("editor_slow_down"): change_speed(-0.05)
	elif Input.is_action_just_pressed("editor_speed_up"): change_speed(0.05)
	elif Input.is_action_just_pressed("editor_zoom_in"): change_zoom(10)
	elif Input.is_action_just_pressed("editor_zoom_out"): change_zoom(-10)
	elif Input.is_action_pressed("editor_left"): move_selected(-1)
	elif Input.is_action_pressed("editor_right"): move_selected(1)
	elif Input.is_action_just_released("editor_left"): regulate_wisps()
	elif Input.is_action_just_released("editor_right"): regulate_wisps()
	elif Input.is_action_just_pressed("editor_copy"): copy_wisps()
	elif Input.is_action_just_pressed("editor_cut"): cut_wisps()
	elif Input.is_action_just_pressed("editor_paste"): paste_wisps()
	elif Input.is_action_just_pressed("editor_delete"): delete_wisps()
	elif Input.is_action_just_pressed("editor_save"): save()
	elif Input.is_action_just_pressed("editor_escape"): deselect_wisps()


func left_click():
	drop_all_focus()

func synchronize_music():
	if playing:
		var t = time+time_offset
		if t >= 0:
			$MusicPlayer.seek(time+time_offset)
		else:
			$MusicPlayer.seek(0)
			beat = time_to_beat(time)
	
func time_to_beat(time: float = time):
	return bpm/60.0*time

func beat_to_time(beat: float = beat):
	return beat/bpm*60.0

func load_beatmap(path: String):
	var file = File.new()
	file.open(path,file.READ)
	var parse_result: JSONParseResult = JSON.parse(file.get_as_text())
	if parse_result.error: 
		push_error(parse_result.error_string)
		return
	var save_dict: Dictionary = parse_result.result
	file.close()
	for i in default:
		if save_dict.has(i):
			set(i,save_dict[i])
		else:
			set(i,default[i])
	$MusicPlayer.volume_db = volume
	$MusicPlayer.stream = load(song_path)
	$MusicPlayer.pitch_scale = speed
	$Panel/ChartInfo/ChartName/LineEdit.text = chart_name
	$Panel/ChartInfo/BPM/LineEdit.text = str(bpm)
	$Panel/ChartInfo/BeatOffset/LineEdit.text = str(time_offset)
	$Panel/ChartInfo/SongSpeed/SpinBox.value = speed
	$Panel/ChartInfo/SongVolume/SpinBox.value = volume
	if song_path != "":
		$Panel/ChartInfo/ChooseSong/Button.text = "Song Chosen"
		$Panel/ChartInfo/ChooseSong/Button.disabled = true
		$Panel/ChartInfo/SongPath.visible = false
	for wisp in save_dict["wisps"]:
		add_wisp_from_dict(wisp)

func add_wisp_from_dict(wisp_dict: Dictionary):
	var type = [BasicWisp,HoldWisp][wisp_dict["type"]]
	var wisp: Wisp = type.new()
	wisp.time = wisp_dict["time"]
	wisp.lane = wisp_dict["lane"]
	wisp.color = wisp_dict["color"]
	if wisp is HoldWisp:
		wisp.length = wisp_dict["length"]
	add_created_wisp(wisp)

func save():
	regulate_wisps()
	var save_dict: Dictionary = {}
	for i in default:
		save_dict[i] = get(i)
	var save_wisps: Array = []
	for wisp in wisps:
		var type: int
		if wisp is BasicWisp: type = 0
		elif wisp is HoldWisp: type = 1
		var dict = {
			"type" : type,
			"time" : wisp.time,
			"lane" : wisp.lane,
			"color" : wisp.color
		}
		if wisp is HoldWisp:
			dict["length"] = wisp.length
		save_wisps.append(dict)
	save_dict["wisps"] = save_wisps
	var file: File = File.new()
	var path = "res://Beatmaps/"+chart_name+".json"
	file.open(path,File.WRITE)
	file.store_string(to_json(save_dict))
	file.close()
	var start_modulate = Color(0.55,1.0,0.42,1.0)
	var end_modulate = Color(0.55,1.0,0.42,0.0)
	Tools.tween(
		$Panel/EditorSettings/Label2,
		"self_modulate",
		start_modulate,
		end_modulate,
		4.0,
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)

func add_black_wisp():
	add_wisp(get_mouse_time(),get_mouse_lane(),"black",note_type)

func add_white_wisp():
	add_wisp(get_mouse_time(),get_mouse_lane(),"white",note_type)
	
func get_mouse_global_position():
	return
	
func mouse_motion(event: InputEventMouseMotion):
	if Input.is_action_pressed("editor_left_click"):
		pos -= event.relative.x
		dragging = true
	if Input.is_action_pressed("editor_right_click"):
		if dragging_notes:
			if selected_wisps.size() == 1:
				var wisp: Wisp = selected_wisps[0]
				if wisp != null:
					var beat = time_to_beat(get_mouse_time())
					wisp.time = beat_to_time(stepify(beat,snap_amount))
					wisp.lane = get_mouse_lane()
			else:
				for wisp in selected_wisps:
					wisp.time += event.relative.x/note_spread
					if drag_change_lanes:
						wisp.lane = get_mouse_lane()
		elif not selecting:
			start_selection()

func release_left_click():
	if dragging:
		dragging = false
	else:
		if select_nearest_wisp() == null:
			cursor_time = get_mouse_time()

func right_click():
	drop_all_focus()
	if get_nearest_wisp() in selected_wisps:
		start_dragging_notes()

func start_dragging_notes():
	dragging_notes = true
	note_drag_time = get_mouse_time()
	note_drag_y = get_global_mouse_position().y
	drag_change_lanes = true
	var a = 0
	for wisp in selected_wisps:
		if wisp != null:
			a = a | (wisp.lane+1)
			if a == (1 | 2):
				drag_change_lanes = false

func stop_dragging_notes():
	dragging_notes = false
	drag_change_lanes = false
	regulate_wisps()
		

func start_selection():
	selecting = true
	select_time = get_mouse_time()
	select_y = get_global_mouse_position().y


func release_right_click():
	if selecting:
		stop_selection()
	elif dragging_notes:
		stop_dragging_notes()
	else:
		select_nearest_wisp()
	
func select_nearest_wisp():
	var nearest_wisp = get_nearest_wisp()
	if Input.is_action_pressed("editor_shift"):
		if nearest_wisp in selected_wisps:
			deselect_wisp(nearest_wisp)
		else:
			select_wisp(nearest_wisp)
	else:
		select_wisp(nearest_wisp)
	return nearest_wisp
	
func select_wisp(wisp: Wisp):
	if wisp != null:
		selected_wisps = [wisp]
		show_wisp_info(wisp)

func select_wisps(wisps: Array):
	if wisps.size() == 1:
		select_wisp(wisps[0])
	elif Input.is_action_pressed("editor_shift"):
		selected_wisps.append_array(wisps)
	else:
		selected_wisps = wisps
	if selected_wisps.size() > 0:
		show_wisp_info(selected_wisps[0])
		
func deselect_wisp(wisp: Wisp):
	selected_wisps.erase(wisp)
	hide_wisp_info()

func show_wisp_info(wisp: Wisp):
	var type: int
	if wisp is BasicWisp: type = 0
	elif wisp is HoldWisp: type = 1
	$Panel/NoteSettings/NoteType/OptionButton.selected = type
	$Panel/NoteSettings/NoteType/OptionButton.disabled = false
	$Panel/NoteSettings/NoteLane/OptionButton.selected = wisp.lane
	$Panel/NoteSettings/NoteLane/OptionButton.disabled = false
	var c: int = int(wisp.color == "black")
	$Panel/NoteSettings/NoteColor/OptionButton.selected = c
	$Panel/NoteSettings/NoteColor/OptionButton.disabled = false
	$Panel/NoteSettings/NoteLength/SpinBox.editable = true

func hide_wisp_info():
	$Panel/NoteSettings/NoteType/OptionButton.selected = -1
	$Panel/NoteSettings/NoteType/OptionButton.disabled = true
	$Panel/NoteSettings/NoteLane/OptionButton.selected = -1
	$Panel/NoteSettings/NoteLane/OptionButton.disabled = true
	$Panel/NoteSettings/NoteColor/OptionButton.selected = -1
	$Panel/NoteSettings/NoteColor/OptionButton.disabled = true
	$Panel/NoteSettings/NoteLength/SpinBox.editable = false

	
func copy_wisps():
	wisp_clipboard = selected_wisps.duplicate(true)
	clipboard_time = cursor_time

func cut_wisps():
	copy_wisps()
	delete_wisps()

func delete_wisps():
	for wisp in selected_wisps:
		wisps.erase(wisp)
	deselect_wisps()

func deselect_wisps():
	selected_wisps = []
	hide_wisp_info()
	

func paste_wisps():
	var new_wisps = []
	for wisp in wisp_clipboard:
		var type: int
		if wisp is BasicWisp: type = 0
		elif wisp is HoldWisp: type = 1
		var new = add_wisp(wisp.time - clipboard_time + cursor_time, wisp.lane, wisp.color, type)
		if wisp is HoldWisp:
			new.length = wisp.length
		new_wisps.append(new)
	select_wisps(new_wisps)

func move_selected(dir: int):
	var move_distance = snap_amount
	if snap_amount == 0: move_distance = 1.0/note_spread*60.0/bpm
	for wisp in selected_wisps:
		if wisp != null:
			var beat = time_to_beat(wisp.time)
			wisp.time = beat_to_time(stepify(time_to_beat(wisp.time) + dir*move_distance,snap_amount))

			
func get_all_children(node: Node):
	var children: Array
	for child in node.get_children():
		children.append(child)
		children.append_array(get_all_children(child))
	return children

func drop_all_focus():
	for child in get_all_children(self):
		if child is Control:
			child.release_focus()

func stop_selection():
	if not selecting: return
	if not Input.is_action_pressed("editor_shift"): 
		selected_wisps = []
	selecting = false
	var mpos = get_global_mouse_position()
	var start_y = select_y
	var end_y = mpos.y
	if start_y > end_y:
		var p = start_y
		start_y = end_y
		end_y = p
	var end_time = get_mouse_time()
	var start_time = select_time
	var lanes_selected = []
	if start_y <= 300 && end_y >= 300.0: lanes_selected.append(0)
	if start_y <= 420 && end_y >= 420.0: lanes_selected.append(1)
	if end_time < start_time:
		var p = start_time
		start_time = end_time
		end_time = p
	
	var twisps: Array = []
	for wisp in wisps:
		wisp = wisp as Wisp
		if wisp.lane in lanes_selected and wisp.time > start_time and wisp.time < end_time:
			twisps.append(wisp)
	select_wisps(twisps)
	
	
func remove_wisp(wisp: Wisp):
	if wisp != null:
		wisps.erase(wisp)

func get_mouse_time():
	return (get_global_mouse_position().x + pos)/note_spread*speed

func get_mouse_lane():
	var y = get_global_mouse_position().y
	return int(y > 360.0)


func get_nearest_wisp(time: float = get_mouse_time(), lane: int = get_mouse_lane()) -> Wisp:
	var nearest: Wisp
	var nearest_diff: float = 10000000.0
	for wisp in wisps:
		wisp = wisp as Wisp
		if wisp.lane != lane || abs(get_global_mouse_position().y-360.0) > 90.0: continue
		var diff = abs(get_time_position(time) - get_time_position(wisp.time))
		if diff > 30.0: continue
		if diff < nearest_diff:
			nearest_diff = diff
			nearest = wisp
	return nearest
	
	
func add_wisp(
	time: float = get_mouse_time(),
	lane: int = get_mouse_lane(),
	color: String = note_color, 
	type: int = note_type
):
	var beat = time_to_beat(time)
	if snap_amount != 0.0:
		beat = stepify(beat,snap_amount)
	time = beat_to_time(beat)
	var wisp: Wisp
	var t = [BasicWisp,HoldWisp][type]
	wisp = t.new()
	wisp.game = self
	wisp.color = color
	wisp.time = time
	wisp.lane = lane
	if wisp is HoldWisp:
		wisp.length = 1.0
	wisps.append(wisp)
	regulate_wisps()
	return wisp

func regulate_wisps():
	wisps.sort_custom(self,"sort_wisps")
	var wisps_queued_for_destruction: Array
	var i = wisps.size()-1
	while i > 1:
		if wisps.size() == 1: break
		if (wisps[i].lane == wisps[i-1].lane and 
			wisps[i].time == wisps[i-1].time):
			wisps_queued_for_destruction.append(wisps[i])
		i-=1
	for wisp in wisps_queued_for_destruction:
		remove_wisp(wisp)
		

func sort_wisps(a: Wisp, b: Wisp):
	return b.time > a.time
	
func change_zoom(value: float):
	var os = note_spread
	note_spread += value
	note_spread = clamp(note_spread,20,1600)
	pos *= note_spread/os
	

func change_speed(value: float):
	speed += value
	speed = clamp(speed,0.05,10.0)
	$MusicPlayer.pitch_scale = speed
	synchronize_music()
	
func reset():
	cursor_time = 0
	time = 0
	beat = 0
	synchronize_music()

func toggle_playing():
	playing = not playing
	if playing:
		time = cursor_time
		var t = time + time_offset
		beat = time_to_beat(time)
		if t < 0:
			yield(get_tree().create_timer(-t),"timeout")
			$MusicPlayer.play(0.0)
		else:
			$MusicPlayer.play(t)
	else:
		$MusicPlayer.stop()
	synchronize_music()

func _process(delta):
	if playing:
		time += delta*speed
		var old_beat = beat
		beat += bpm/60.0*delta*speed
		if metronome and int(old_beat) != int(beat):
			$Metronome.play()
			synchronize_music()
	update()

func _draw():
	_draw_main_line()
	_draw_cursor()
	_draw_support_lines()
	_draw_wisps()
	_draw_beat_line()
	if selecting: _draw_selection()

func get_time_from_position(position: float):
	return (position+pos)/note_spread


func _draw_beat_line():
	var pos = get_time_position(time)
	draw_line(Vector2(pos,0),Vector2(pos,720),Color.green,3.0)

func _draw_selection():
	var p1 = Vector2(get_time_position(select_time),select_y)
	var p2 = get_global_mouse_position()
	var top_left = Vector2(min(p1.x,p2.x),min(p1.y,p2.y))
	var bottom_right = Vector2(max(p1.x,p2.x),max(p1.y,p2.y))
	draw_rect(Rect2(top_left,bottom_right-top_left),Color(0.2,0.3,0.8,0.4),true,1.0)

func get_time_position(time: float):
	return (time*note_spread)/speed - pos
	
func _draw_wisps():
	for wisp in wisps:
		var mod = Color.white
		if wisp in selected_wisps:
			mod = Color.aqua
		wisp.draw(mod)
		

		

func _draw_cursor():
	var pos = get_time_position(cursor_time)
	draw_line(Vector2(pos,0),Vector2(pos,720),Color.blue,3.0)

func _draw_main_line():
	var pos = get_time_position(0)
	draw_line(Vector2(pos,0),Vector2(pos,720),Color.red,6.0)
	
func _draw_support_lines():
	var spacing = note_spread/bpm*60.0/speed
	var p = get_beat_position(0)
	var i = 0
	var points = []
	while p < pos + 1280.0:
		var width = 0.5
		var color = Color.red
		i+=1
		draw_line(Vector2(p-pos,0),Vector2(p-pos,720),color,width)
		p += spacing
	
func get_beat_position(b: float):
	return b*note_spread*bpm/60.0/speed

func get_beat_from_position(x: float):
	return beat + x/note_spread

func get_position_offset():
	return time*note_spread

func get_lane_from_position(y: float):
	return int(abs(y-300) > abs(y-420))

func get_time_from_beat(b: float):
	return b/bpm*60.0

func _on_ChooseMode_item_selected(index: int):
	mode = index
	$Panel/NoteSettings/AddNotes.visible = mode == MODES.ADD
	
func _on_ChooseSong_pressed():
	$ChooseSongFile.show()
	
func _on_ChooseSongFile_file_selected(path: String):
	song_path = path
	$MusicPlayer.stream = load(song_path)
	$Panel/ChartInfo/SongPath.visible = false
	$Panel/ChartInfo/ChooseSong/Button.text = "Song Chosen"
	$Panel/ChartInfo/ChooseSong/Button.disabled = true
	
func _on_Metronome_toggled(button_pressed: bool):
	metronome = button_pressed
	
func _on_NoteSounds_toggled(button_pressed: bool):
	note_sounds = button_pressed

func _on_OptionButton_item_selected(index: int):
	note_type = index

func _on_NoteColor_item_selected(index: int):
	note_color = ["white","black"][index]
	
func _on_SnapAmount_text_changed(new_text: String):
	snap_amount = float(new_text)
	
func _on_SnapAmount_focus_exited():
	snap_amount = float($Panel/NoteSettings/Snap/LineEdit.text)


func _on_BPM_text_changed(new_text: String):
	var amount = float(new_text)
	if amount > 10.0: bpm = amount


func _on_BeatOffset_text_changed(new_text):
	var old_offset = time_offset
	time_offset = float(new_text)
	beat += - old_offset + time_offset
	synchronize_music()

func _on_ChartName_text_changed(new_text):
	chart_name = new_text

func _on_LoadBeatmap_file_selected(file_path: String):
	load_beatmap(file_path)

func _on_Load_pressed():
	$LoadBeatmap.show()


func _on_NoteColorOne_item_selected(index):
	for wisp in selected_wisps:
		wisp.color = ["white","black"][index]
	show_wisp_info(selected_wisps[0])
	
func _on_NoteLane_item_selected(index):
	for wisp in selected_wisps:
		wisp.lane = index
	show_wisp_info(selected_wisps[0])
	
func _on_NoteTime_value_changed(value):
	for wisp in selected_wisps:
		wisp.time = value
	show_wisp_info(selected_wisps[0])
	
func _on_NoteType_item_selected(index):
	var wisp_type = [BasicWisp, HoldWisp][index]
	var new_wisp: Wisp = wisp_type.new()
	var old_wisp: Wisp = selected_wisps[0]
	new_wisp.time = old_wisp.time
	new_wisp.lane = old_wisp.lane
	new_wisp.color = old_wisp.color
	if new_wisp is HoldWisp:
		new_wisp.length = beat_to_time(1)
	delete_wisp(old_wisp)
	add_created_wisp(new_wisp)
	select_wisp(new_wisp)

func delete_wisp(wisp: Wisp):
	wisps.erase(wisp)
	selected_wisps.erase(wisp)
	regulate_wisps()

func add_created_wisp(wisp: Wisp):
	wisp.game = self
	wisps.append(wisp)
	regulate_wisps()
	
func _on_SnapAmount_value_changed(value):
	snap_amount = value
	
func _on_NoteLength_value_changed(value):
	for wisp in selected_wisps:
		if wisp is HoldWisp:
			wisp.length = value


func _on_BackToMain_pressed():
	Transition.transition()
	get_tree().change_scene_to(Global.main_scene)


func _on_SongSpeed_value_changed(value):
	speed = value
	$MusicPlayer.pitch_scale = speed


func _on_SongVolume_value_changed(value):
	volume = value
	$MusicPlayer.volume_db = value
