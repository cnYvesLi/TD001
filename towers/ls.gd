extends Area2D
var level = 1
var d_range = [3000, 4000, 5000]
var damage = [40, 60, 100]
var damage_speed = [1, 1, 1]
var enemies_in_range = {}
var can_shoot = false  # 初始设置为false
var build_time = 0.2  # 建造时间
var time_passed = 0  # 已经过的时间
var price = [10, 100, 200]
var sell = [5, 10, 20, 30]
var sprites = []

func _ready() -> void:
	# 连接Timer信号
	sprites.append($level1)
	sprites.append($level2)
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.one_shot = false
	$Timer.start()

func _process(delta: float) -> void:
	# 更新建造时间
	for i in range(sprites.size()):
		if level - 1 != i:
			sprites[i].visible = false
		else:
			sprites[i].visible = true
	$Timer.wait_time = 1 / damage_speed[level - 1]
	$CollisionShape2D.shape.radius = d_range[level - 1]
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
				bullet.damage = damage[level - 1]
				bullet.position = position
				bullet.goal = closest_enemy
				bullet.level = level
				get_parent().add_child(bullet)
				$Timer.start()
	if enemies_in_range.is_empty():
		var target_rotation = 0
		rotation = lerp_angle(rotation, target_rotation, 0.1)

func _on_timer_timeout() -> void:
	$Timer.stop()
