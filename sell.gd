extends Area2D
var res = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("input_event", Callable(self, "_on_input_event")) 

func _process(delta: float) -> void:
	if res > 0:
		res -= 1
	else:
		$sell.modulate = Color(1, 1, 1)

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		$sell.modulate = Color(0, 1, 0)
		res = 5

func _on_mouse_entered() -> void:
	$TowerSellS.visible = true

func _on_mouse_exited() -> void:
	$TowerSellS.visible = false
