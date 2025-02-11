extends Area2D
var level = 1
var d_range = [3000, 4000, 5000]
var damage = [5, 10, 15]
var damage_speed = [1.5, 1.5, 1.5]
var HP = [30, 40, 50]
var ES = [0, 0, 0]
var DEF = [0.1, 0.1, 0.1]
var speed = [1000, 1100, 1200]
var generate_speed = [0.8, 0.8, 0.8]
var enemies_in_range = {}
var build_time = 0.2  # 建造时间
var time_passed = 0  # 已经过的时间
var price = [10, 100, 200]
var sell = [5, 10, 20, 30]
var drone = preload("res://towers/drone.tscn")
var full_drone = false
var drones = []
@onready var pos = [$level1/drone0, $level1/drone1, $level1/drone2, $level1/drone3]
@onready var sprites = [$level1]
@onready var gates = [$level1/g1, $level1/g2]
@onready var lights = [$level1/light/l1, $level1/light/l2, $level1/light/l3]

# 门动画相关变量
var gate_animation_state = "idle"  # idle, moving_forward, waiting, moving_back
var gate_animation_frame = 0
var forward_frames = 10
var wait_frames = 15
var back_frames = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.one_shot = false
	$Timer.start()
	$Timer.wait_time = generate_speed[level - 1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# 处理敌人和无人机的对手匹配
	if not enemies_in_range.is_empty() and not drones.is_empty():
		for res in drones:
			if res.opponent == null:
				var goal = null
				var min_dis = INF
				for enemy in enemies_in_range.keys():
					if enemy.opponent == null and enemies_in_range[enemy] < min_dis:
						min_dis = enemies_in_range[enemy]
						goal = enemy
				if goal != null:
					res.opponent = goal
					goal.opponent = res
	for i in range(3):
		if i <= len(drones) - 1:
			lights[i].visible = true
			drones[i].standby_pos = pos[i + 1].global_position
		else:
			lights[i].visible = false
	# 处理门的动画
	if len(drones) < 3 and full_drone:
		full_drone = false
		$Timer.wait_time = damage_speed[level - 1] * 10
		$Timer.start()
	if not full_drone and $Timer.is_stopped():
		match gate_animation_state:
			"moving_forward":
				gate_animation_frame += 1
				var progress = float(gate_animation_frame) / forward_frames
				for gate in gates:
					gate.get_node("PathFollow2D").progress_ratio = progress
				if gate_animation_frame >= forward_frames:
					gate_animation_state = "waiting"
					gate_animation_frame = 0
			"waiting":
				gate_animation_frame += 1
				# 在waiting状态且drones数量少于3时生成新的drone
				if len(drones) < 3 and gate_animation_frame == 1:
					var new_drone = drone.instantiate()
					add_child(new_drone)
					drones.append(new_drone)
					# 设置初始位置为pos[0]的位置和相同图层
					new_drone.HP = HP[level - 1]
					new_drone.HP_max = HP[level - 1]
					new_drone.ES = ES[level - 1]
					new_drone.ES_max = ES[level - 1]
					new_drone.DEF = DEF[level - 1]
					new_drone.damage = damage[level - 1]
					new_drone.damage_speed = damage_speed[level - 1]
					new_drone.speed = speed[level - 1]
					new_drone.position = pos[len(drones)].position
					new_drone.visible = false
				elif len(drones) > 0 and gate_animation_frame <= 9:
					# 在9帧内平滑向上移动400单位
					var start_pos = pos[0].position
					var target_pos = start_pos
					target_pos.y -= 100
					pos[0].position = pos[0].position.lerp(target_pos, float(gate_animation_frame) / 9)
				if gate_animation_frame >= wait_frames:
					gate_animation_state = "moving_back"
					gate_animation_frame = 0
			"moving_back":
				gate_animation_frame += 1
				var progress = 1.0 - float(gate_animation_frame) / back_frames
				for gate in gates:
					gate.get_node("PathFollow2D").progress_ratio = progress
				# 移动最后一个drone到对应的pos位置
				if len(drones) > 0:
					var target_pos = pos[len(drones)].position
					pos[0].position = pos[0].position.lerp(target_pos, float(gate_animation_frame) / back_frames)
				if gate_animation_frame >= back_frames:
					gate_animation_state = "idle"
					gate_animation_frame = 0
					pos[0].position = Vector2(12, 30)
					drones[-1].visible = true
					if len(drones) == 3:
						full_drone = true
					else:
						$Timer.wait_time = generate_speed[level - 1]
					$Timer.start()

func _on_timer_timeout() -> void:
	$Timer.stop()
	gate_animation_state = "moving_forward"
	gate_animation_frame = 0
