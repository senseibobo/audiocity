extends Wisp
class_name BasicWisp

const frame_count: int = 8
const fps: float = 9.0


func _init():
	white_texture = preload("res://Textures/basic_white.png")
	black_texture = preload("res://Textures/basic_black.png")

func draw(modulate: Color = Color.white):
	var texture = [white_texture,black_texture][int(color == "black")]
	var size = texture.get_size()/Vector2(frame_count,1.0)*2.0
	var p = game.get_time_position(time)
	var position = Vector2(p+size.x/4,300+lane*120)
	var t: float = 100.0 + game.time - time
	var current_frame: int = int(t*fps)%frame_count
	var src_pos = Vector2(size.x*current_frame/2.0,0)
	game.draw_texture_rect_region(texture,Rect2(position-size/2,size),Rect2(src_pos,size/2.0),modulate)
