extends Node2D
var res = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	res = 5 # Replace with function body.
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if res > 0:
		res -= 1
	else:
		queue_free()
