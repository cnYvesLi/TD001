extends Area2D
var HP : float = 100
var speed : float = 300
var damage : float = 10
var damage_speed : float = 1.0
var check_point : int = 1
var root_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 生成-30到+30之间的随机偏移值
	var random_offset = randf_range(-30, 30)
	# 获取Sprite2D和CollisionShape2D节点
	var sprite = $Sprite2D
	var collision = $CollisionShape2D
	# 设置两个节点的y轴偏移值
	sprite.position.y = random_offset
	collision.position.y = random_offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
