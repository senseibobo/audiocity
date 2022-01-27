class_name Wisp

var game: Node2D
var beat: float
var color: String
var lane: int
var white_texture: Texture
var black_texture: Texture

func on_beat(beat: float): # triggered when beat hits
	pass

func on_process(beat: float): # triggered every frame
	if self.beat < beat - game.timing:
		game.judge_wisp(self,"bad")
