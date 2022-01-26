extends CanvasLayer


func invert():
	var material = $ColorRect.material
	material.set_shader_param("inverted",not material.get_shader_param("inverted"))
	
	
