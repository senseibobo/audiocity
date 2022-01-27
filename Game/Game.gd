extends Node2D
class_name Game

const timing: float = 0.2

const default_beatmap: Dictionary = {
	"wisps": [
		{
			"type": "basic",
			"beat": "5",
			"lane": "1",
			"color": "black"
		},
		{
			"type": "basic",
			"beat": "6",
			"lane": "2",
			"color": "white"
		},
		{
			"type": "basic",
			"beat": "7",
			"lane": "1",
			"color": "black"
		},
		{
			"type": "basic",
			"beat": "8",
			"lane": "0",
			"color": "black"
		},
		{
			"type": "basic",
			"beat": "9",
			"lane": "1",
			"color": "white"
		}
	],
	"music": preload("res://Sound/Music/sweden.ogg"),
	"bpm": 176.0,
	"beat_offset": 0.122
}

var bpm: float
var speed: float = 400.0
var time: float = 0.0
var beat: float = 0.0
var player_offset: float = 220.0
var beat_offset: float = 0.0
var started: bool = false

var loaded_wisps: Array
var spawned_wisps: Array

onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()



func _ready():
	_configure_player()
	load_beatmap(default_beatmap)
	_configure_music()
	yield(get_tree().create_timer(1.5,false),"timeout")
	start_game()


func _process(delta):
	if started:
		_sync_beat(delta)
		update()


func start_game():
	music_player.play()
	for i in 4:
		if loaded_wisps.size() > 0:
			spawn_wisp(loaded_wisps[-1])
			loaded_wisps.pop_back()
		else:
			break
	started = true
	

func load_beatmap(beatmap: Dictionary):
	#loaded_wisps = beatmap["wisps"] as Array
	loaded_wisps = _debug_generate_wisps()
	loaded_wisps.invert()
	bpm = beatmap["bpm"]
	beat_offset = beatmap["beat_offset"]
	music_player.stream = beatmap["music"]

func _debug_generate_wisps():
	var b = 6.0
	var w = []
	for i in range(500):
		w.append({
			"type": "basic",
			"beat": b,
			"lane": randi()%2,
			"color": ["white","black"][randi()%2]
		})
		b+=[0.5,1.0][randi()%2]
	return w
	
	
func _configure_music():
	add_child(music_player)
	
	
func _configure_player():
	$Player.game = self
	$Player.global_position.x = player_offset-64.0
	
	
func spawn_wisp(wisp_dict: Dictionary):
	var wisp: Wisp
	match wisp_dict["type"]:
		"basic": wisp = BasicWisp.new()
	wisp.game = self
	wisp.beat = wisp_dict["beat"]
	wisp.lane = wisp_dict["lane"]
	wisp.color = wisp_dict["color"]
	spawned_wisps.append(wisp)
	
	
func hit(lane: int, color: String):
	var i = 0
	var nearest: Wisp
	var nearest_difference: float = 1000000.0
	while i < spawned_wisps.size():
		var wisp: Wisp = spawned_wisps[i]
		i+=1
		if wisp.lane != lane or wisp.color != color: continue
		var difference = wisp.beat - beat
		if difference < nearest_difference:
			nearest = wisp
			nearest_difference = difference
	if nearest_difference < timing:
		judge_wisp(nearest, "good")
		return true
	return false
	
	
func judge_wisp(wisp: Wisp, judgement: String):
	print(judgement)
	spawned_wisps.erase(wisp)
	if loaded_wisps.size() > 0:
		spawn_wisp(loaded_wisps[-1])
		loaded_wisps.pop_back()
		
		
func _sync_beat(delta):
	time += delta
	var old_beat = beat
	beat = time * bpm / 60.0 + beat_offset
	if int(old_beat) != int(beat) && int(beat)%2 == 0:
		_on_beat()
	for wisp in spawned_wisps:
		wisp.on_process(beat)
	
	
func _on_beat():
	#time = music_player.get_playback_position()
	for wisp in spawned_wisps:
		wisp.on_beat(beat)
	
	
func _draw():
	_draw_support_lines()
	_draw_wisps()
	
	
func _draw_wisps():
	for wisp in spawned_wisps:
		wisp = wisp as Wisp
		var p = get_beat_position(wisp.beat)
		var texture: Texture = wisp.white_texture if wisp.color == "white" else wisp.black_texture
		var size: Vector2 = texture.get_size()
		draw_texture(texture, Vector2(p,300 + wisp.lane*120) - size/2)

func get_beat_position(b: float):
	return (b-beat)*speed + player_offset
	
	
func _draw_support_lines():
	var pos = (fposmod(-beat,2.0)-2.0)*speed+player_offset
	var pt: Vector2 = Vector2(pos,0)
	var points = []
	while pt.x < 1280.0:
		points.append(pt)
		pt.y += 720.0
		points.append(pt)
		pt.x += speed*2.0
		points.append(pt)
		pt.y -= 720.0
		points.append(pt)
		pt.x += speed*2.0
	draw_multiline(PoolVector2Array(points),Color.red,1000.0)
	
	
	
	
