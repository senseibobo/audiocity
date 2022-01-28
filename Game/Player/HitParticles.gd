extends Particles2D


func _ready():
	$Particles2D.texture = texture
	$Particles2D.emitting = true
