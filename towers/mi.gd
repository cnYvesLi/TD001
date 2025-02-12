extends Area2D
var level = 1
var d_range = [900, 900, 900]
var damage = [30, 40, 50]
var damage_speed = [1.2, 1.5, 1.7]
var enemies_in_range = {}
var can_shoot = false  # 初始设置为false
var build_time = 0.2  # 建造时间
var time_passed = 0  # 已经过的时间
var price = [8, 80, 200]
var sell = [1, 4, 40, 30]
var bullet_number = 0
var current_bullet = 0
var max_bullet_number = 3
var bullets = []
var missiles_displacement = [0, 0, 0]
@onready var sprites = [$level1]
@onready var barrels = [$level1/barrel]
@onready var missiles = [$missile/missile1, $missile/missile2, $missile/missile3]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.one_shot = false
	$Timer.start()
	$Timer1.timeout.connect(_on_timer_timeout1)
	$Timer1.one_shot = false
	$Timer1.start()
	for i in range(3):
		var bullet = preload("res://towers/mi_bullet.tscn").instantiate()
		bullet.damage = damage[level - 1]
		bullet.global_position = missiles[current_bullet].global_position  # 设置位置
		bullet.position.y += 3
		bullet.rotation = $missile.rotation # 设置旋转
		bullet.scale =  $missile/missile1.scale


		# 将子弹添加到 bullets 数组中
		bullets.append(bullet)
		get_parent().add_child(bullet)

		# 更新 current_bullet
		current_bullet = (current_bullet + 1) % max_bullet_number
		bullet_number += 1  # 增加子弹数量

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(sprites.size()):
		if level - 1 != i:
			sprites[i].visible = false
		else:
			sprites[i].visible = true
	$Timer.wait_time = 1 / damage_speed[level - 1]
	$Timer1.wait_time = 1 / damage_speed[level - 1]
	$CollisionShape2D.shape.radius = d_range[level - 1]
	if not can_shoot:
		time_passed += delta
		if time_passed >= build_time:
			can_shoot = true
	
	for i in range(bullet_number):
		# 让 bullets 中的实例绕着 $missile 的位置旋转
		if missiles_displacement[i] < -25:
			missiles_displacement[i] += 0.5
		elif missiles_displacement[i] < 0:
			missiles_displacement[i] += 0.5
			missiles[i].position.y -= 0.5
		bullets[i].global_position = missiles[(i + current_bullet) % 3].global_position
		bullets[i].rotation = $missile.rotation  # 设置旋转

	if can_shoot and not enemies_in_range.is_empty():
		var closest_enemy = null
		var min_distance = INF
		
		for enemy in enemies_in_range:
			var distance = enemies_in_range[enemy]
			if distance < min_distance:
				min_distance = distance
				closest_enemy = enemy
		if closest_enemy:
			var direction = closest_enemy.global_position - barrels[level - 1].global_position
			var target_rotation = direction.angle() + PI/2
			barrels[level - 1].rotation = lerp_angle(barrels[level - 1].rotation, target_rotation, 0.1)
			$missile.rotation = lerp_angle($missile.rotation, target_rotation, 0.1)
		
		if closest_enemy and $Timer.is_stopped():
			# 设置 bullets[0] 的 goal 为最近的敌人
			bullets[0].goal = closest_enemy
			bullets[0].have_goal = true
			
			# 从数组中移除 bullets[0]
			bullets.pop_at(0)
			
			# 减少 bullet_number
			bullet_number -= 1
			$Timer.start()

	if enemies_in_range.is_empty():
		var target_rotation = 0
		barrels[level - 1].rotation = lerp_angle(barrels[level - 1].rotation, target_rotation, 0.1)
		$missile.rotation = lerp_angle($missile.rotation, target_rotation, 0.1)

	if can_shoot and bullet_number < 3 and $Timer1.is_stopped():
		# 初始化一个子弹
		var bullet = preload("res://towers/mi_bullet.tscn").instantiate()
		bullet.damage = damage[level - 1]
		bullet.scale = $missile/missile1.scale
		missiles[current_bullet].position.y += 25
		missiles_displacement[current_bullet] = -35
		bullet.global_position = missiles[current_bullet].global_position  # 设置位置
		bullet.rotation = $missile.rotation # 设置旋转

		# 将子弹添加到 bullets 数组中
		bullets.append(bullet)
		get_parent().add_child(bullet)

		# 更新 current_bullet
		current_bullet = (current_bullet + 1) % max_bullet_number
		bullet_number += 1  # 增加子弹数量
		$Timer1.start()

	# 将 barrels[level - 1] 的图层持续置顶
	barrels[level - 1].z_index = 100  # 设置为一个较大的值，确保在最上层

func _on_timer_timeout() -> void:
	$Timer.stop()

func _on_timer_timeout1():
	$Timer1.stop()
