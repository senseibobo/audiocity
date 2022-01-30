extends Node2D
class_name Game

signal game_started

const timing: float = 0.12

var bpm: float
var speed: float = 1.0
var note_spread: float = 1200.0
var time: float = 0.0
var beat: float = 0.0
var player_offset: float = 220.0
var time_offset: float = 0.0
var started: bool = false
var pos: float
var combo: int = 0
var score: float = 0.0
var shown_score: float = 0.0
var hits: float
var misses: float
var max_combo: float


var loaded_wisps: Array
var spawned_wisps: Array

onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
onready var player = $Player



func _ready():
	load_beatmap(Global.selected_song if Global.selected_song != "" else "res://Beatmaps/Speeden.json")
	_configure_player()
	_configure_music()
	time_offset /= speed
	yield(get_tree().create_timer(1.5,false),"timeout")
	start_game()
	#start_inverting()

func start_inverting():
	while true:
		yield(get_tree().create_timer(60.0/bpm*60.0,false),"timeout")
		invert()


func _process(delta):
	shown_score = lerp(shown_score,score,5.2*delta)
	$Label.text = str(round(shown_score))
	if started:
		_sync_beat(delta)
		update()


func start_game():
	emit_signal("game_started")
	for i in 30:
		if loaded_wisps.size() > 0:
			spawn_wisp(loaded_wisps[-1])
			loaded_wisps.pop_back()
		else:
			break
	started = true
	if time_offset >= 0:
		music_player.play(time_offset)
	else:
		yield(get_tree().create_timer(-time_offset),"timeout")
		music_player.play()

func load_beatmap(beatmap_path: String):
	var file = File.new()
	file.open(beatmap_path, file.READ)
	var beatmap = parse_json(file.get_as_text())
	file.close()
	loaded_wisps = beatmap["wisps"] as Array
	loaded_wisps.invert()
	for i in ["bpm","time_offset","speed"]:
		set(i,beatmap[i])
	if beatmap.has("highscore"):
		Global.highscore = beatmap["highscore"]
	music_player.stream = load(beatmap["song_path"])
	music_player.volume_db = beatmap["volume"]
	
	
func _configure_music():
	add_child(music_player)
	music_player.pitch_scale = speed
	
	
func _configure_player():
	$Player.game = self
	$Player.adjust_bpm(bpm*speed)
	$Player.global_position.x = player_offset-84.0
	
	
func spawn_wisp(wisp_dict: Dictionary):
	var type = [BasicWisp,HoldWisp][wisp_dict["type"]]
	var wisp: Wisp = type.new()
	wisp.game = self
	wisp.time = wisp_dict["time"]
	wisp.lane = wisp_dict["lane"]
	wisp.color = wisp_dict["color"]
	if wisp is HoldWisp:
		wisp.length = wisp_dict["length"]
	spawned_wisps.append(wisp)
	wisp.added()
	
	
func hit(lane: int, color: String):
	var i = 0
	var nearest: Wisp
	var nearest_difference: float = 1000000.0
	while i < spawned_wisps.size():
		var wisp: Wisp = spawned_wisps[i]
		i+=1
		if wisp.lane != lane or wisp.color != color: continue
		var difference = (wisp.time - time)/speed
		if difference < nearest_difference:
			nearest = wisp
			nearest_difference = difference
	if nearest_difference < timing:
		nearest.hit()
		return true
	return false
	
	
func judge_wisp(wisp: Wisp, judgement: String):
	if judgement == "good":
		hits += 1.0
		combo += 1
		if combo > max_combo:
			max_combo = combo
		score += lerp(float(combo),1.0,0.6)*200
	else:
		misses += 1.0
		combo = 0
	spawned_wisps.erase(wisp)
	if loaded_wisps.size() > 0:
		spawn_wisp(loaded_wisps[-1])
		loaded_wisps.pop_back()
	elif spawned_wisps.size() == 0:
		Global.score = score
		Global.hits = hits
		Global.misses = misses
		Global.accuracy = hits / (hits + misses)
		Global.max_combo = max_combo
		if Global.score > Global.highscore:
			Global.highscore = Global.score
			Global.save_highscore()
		yield(Tools.timer(2.0,self),"timeout")
		end_game()
func end_game():
	Transition.transition()
	get_tree().change_scene_to(Global.finish_screen_scene)
	
		
		
func _sync_beat(delta):
	time += speed*delta
	pos = time*note_spread
	var old_beat = beat
	beat += speed*bpm/60.0*delta
	if int(old_beat) != int(beat):
		_on_beat()
	for wisp in spawned_wisps:
		wisp.on_process(delta)
	
	
func _on_beat():
	#time = music_player.get_playback_position()
	for wisp in spawned_wisps:
		wisp.on_beat(beat)
	
	
func _draw():
	_draw_support_lines()
	_draw_wisps()

func _draw_wisps():
	for wisp in spawned_wisps:
		wisp.draw()

func time_to_beat(time: float):
	return bpm/60.0*(time-self.time)
	

func get_time_from_position(position: float):
	return (position-pos)/note_spread
	
func get_time_position(time: float):
	return (time-self.time)*note_spread/speed + player_offset
	
func get_beat_position(b: float):
	return b*note_spread*bpm/60.0/speed + player_offset

func _draw_support_lines():
	var spacing = note_spread/bpm*60.0/speed
	var p = get_beat_position(0)
	var points = []
	while p < pos + 1280.0:
		var width = 0.5
		var color = Color(0.5,0.5,0.5,0.2)
		draw_line(Vector2(p-pos/speed,0),Vector2(p-pos/speed,720),color,width)
		p += spacing
	

func invert():
	var new_color = Color(1,1,1,1)-$ColorRect.modulate
	new_color.a = 1.0
	Tools.tween(
		$ColorRect,
		"modulate",
		$ColorRect.modulate,
		new_color,
		0.2
	)
	Tools.tween(
		$Label,
		"modulate",
		new_color,
		$ColorRect.modulate,
		0.2
	)
	
	


