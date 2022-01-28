extends Control

var buttons: Array

func _ready():
	buttons = get_all_buttons(self)
	for button in buttons:
		button.rect_pivot_offset = button.rect_size / 2
		button.self_modulate = Color(3.0,3.0,3.0,1.0);

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
	Transition.transition()
	var error = get_tree().change_scene_to(preload("res://Game/Game.tscn"))


func _on_Create_pressed():
	Transition.transition()
	var error = get_tree().change_scene_to(preload("res://Editor/Editor.tscn"))
