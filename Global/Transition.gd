extends CanvasLayer

signal transition_finished

onready var colorrect: ColorRect = $ColorRect

func transition():
	var old_screen = get_tree().root.get_texture().get_data()
	old_screen.flip_y()
	var old_texture = ImageTexture.new()
	old_texture.create_from_image(old_screen)
	colorrect.material.set_shader_param("old_texture",old_texture)
	$AnimationPlayer.play("transition")
	emit_signal("transition_finished")
