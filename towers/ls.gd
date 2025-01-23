extends Area2D
var d_range = 1000
var damage = 30
var damage_speed = 1
var enemies_in_range = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CollisionShape2D.shape.radius = d_range


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not enemies_in_range.is_empty():
		# 找出距离终点最近的敌人
		var closest_enemy = null
		var min_distance = INF
		
		for enemy in enemies_in_range:
			var distance = enemies_in_range[enemy]
			if distance < min_distance:
				min_distance = distance
				closest_enemy = enemy
		
		if closest_enemy:
			# 计算朝向敌人的角度
			var direction = closest_enemy.position - global_position
			var target_rotation = direction.angle() + PI/2
			rotation = lerp_angle(rotation, target_rotation, 0.1)
