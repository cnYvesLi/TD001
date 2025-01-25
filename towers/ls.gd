extends Area2D
var level = 1
var d_range = 3000
var damage = 30
var damage_speed = 1
var enemies_in_range = {}
var can_shoot = false  # 初始设置为false
var build_time = 0.2  # 建造时间
var time_passed = 0  # 已经过的时间

func _ready() -> void:
	$CollisionShape2D.shape.radius = d_range
	# 连接Timer信号
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.wait_time = 1.0
	$Timer.one_shot = false
	$Timer.start()

func _process(delta: float) -> void:
	# 更新建造时间
	if not can_shoot:
		time_passed += delta
		if time_passed >= build_time:
			can_shoot = true
	
	if can_shoot and not enemies_in_range.is_empty():
		var closest_enemy = null
		var min_distance = INF
		
		for enemy in enemies_in_range:
			var distance = enemies_in_range[enemy]
			if distance < min_distance:
				min_distance = distance
				closest_enemy = enemy
		
		if closest_enemy:
			var direction = closest_enemy.position - global_position
			var target_rotation = direction.angle() + PI/2
			rotation = lerp_angle(rotation, target_rotation, 0.1)
			
			# 只在可以射击时创建子弹
			if $Timer.is_stopped():
				var bullet = preload("res://towers/ls_bullet.tscn").instantiate()
				bullet.damage = damage
				bullet.position = position
				bullet.goal = closest_enemy
				get_parent().add_child(bullet)
				$Timer.start()

func _on_timer_timeout() -> void:
	$Timer.stop()
