class_name Wisp

var game: CanvasItem
var time: float
var color: String
var lane: int
var white_texture: Texture
var black_texture: Texture

func on_beat(beat: float): # triggered when beat hits
	pass

func on_process(delta: float): # triggered every frame
	if self.time < game.time - game.timing:
		game.judge_wisp(self,"bad")

func hit():
	game.judge_wisp(self,"good")

func added():
	pass

func draw():
	var p = game.get_time_position(time)
	var texture: Texture = white_texture if color == "white" else black_texture
	var size: Vector2 = texture.get_size()
	game.draw_texture(texture, Vector2(p,300 + lane*120) - size/2)
