extends Node2D
class_name Game

const default_beatmap = {
	"wisps": [
		{
			"type": "basic",
			"beat": "5",
			"lane": "1",
			"color": "white"
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
			"color": "white"
		},
		{
			"type": "basic",
			"beat": "8",
			"lane": "0",
			"color": "white"
		},
		{
			"type": "basic",
			"beat": "9",
			"lane": "1",
			"color": "white"
		}
	],
	"music": preload("res://Sound/Music/sweden.ogg"),
	"bpm": 88.0,
	"beat_offset": 0.122
}

var bpm: float
var speed: float = 200.0
var time: float = 0.0
var beat: float = 0.0
export var beat_offset: float = 0.0
var started: bool = false


var loaded_wisps: Array
var spawned_wisps: Array


onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	_configure_player()
	load_beatmap(default_beatmap)
	_configure_music()
	yield(get_tree().create_timer(3.0,false),"timeout")
	start_game()

func load_beatmap(beatmap: Dictionary):
	loaded_wisps = beatmap["wisps"] as Array
	loaded_wisps.invert()
	bpm = beatmap["bpm"]
	beat_offset = beatmap["beat_offset"]
	music_player.stream = beatmap["music"]

func _configure_music():
	add_child(music_player)

func _configure_player():
	$Player.game = self

func start_game():
	music_player.play()
	for i in 2:
		if loaded_wisps.size() > 0:
			spawn_wisp(loaded_wisps[-1])
			loaded_wisps.pop_back()
	started = true

func _process(delta):
	if started:
		_sync_beat(delta)
		update()

func _sync_beat(delta):
	time += delta
	var old_beat = beat
	beat = time * bpm / 60.0 + beat_offset
	if int(old_beat) != int(beat) && int(beat)%2 == 0:
		time = music_player.get_playback_position()

func _draw():
	_draw_support_lines()
	_draw_wisps()
	
func _draw_wisps():
	for wisp in spawned_wisps:
		wisp = wisp as Wisp
		var p = get_beat_position(wisp.beat)
		draw_texture(wisp.texture, Vector2(p,360 + (wisp.lane-1)*120))

func get_beat_position(b):
	var x = (b-beat)*speed
	return x

func _draw_support_lines():
	var pos = fposmod(-beat,2.0)*speed
	var pt: Vector2 = Vector2(pos,0)
	var points = []
	while pt.x < 1280.0:
		points.append(pt)
		pt.y += 720.0
		points.append(pt)
		pt.x += speed
		points.append(pt)
		pt.y -= 720.0
		points.append(pt)
		pt.x += speed
	draw_multiline(PoolVector2Array(points),Color.red,1000.0)
	
func spawn_wisp(wisp_dict: Dictionary):
	var wisp: Wisp
	match wisp_dict["type"]:
		"basic": wisp = BasicWisp.new()
	wisp.beat = wisp_dict["beat"]
	wisp.lane = wisp_dict["lane"]
	wisp.color = wisp_dict["color"]
	spawned_wisps.append(wisp)

func hit(lane: int):
	print(spawned_wisps)
	spawned_wisps.pop_front()
	if loaded_wisps.size() > 0:
		spawn_wisp(loaded_wisps[-1])
		loaded_wisps.pop_back()
