extends Area2D
var HP_max = 0
var ES_max = 0
var HP = 0
var ES = 0
var speed = 0
var damage = 0
var damage_speed = 0
var opponent = null
var standby_pos
var is_fighting = false
var DEF = 0.1
var initial_scale = {"x":0, "y":0}
var parent
@onready var bar = $HP_bar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.one_shot = false
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Timer.wait_time = 1 / damage_speed
	bar.HP = HP
	bar.ES = ES
	bar.HP_max = HP_max
	bar.ES_max = ES_max
	if not is_instance_valid(opponent):
		opponent = null
	if not is_instance_valid(parent):
		queue_free()
	if $Timer.is_stopped() and is_fighting and opponent != null:
			$Timer.start()
			opponent.HP -= damage * (1 - opponent.DEF)
	if visible:
		if opponent != null:
			# 计算目标位置（敌人位置x坐标+100）
			var target_pos = opponent.sprite.global_position
			target_pos.x -= 250 * (opponent.scale.x)
			if global_position.distance_to(target_pos) >= speed * delta and not is_fighting:
				if (target_pos.x - global_position.x > 0 and scale.x > 0) or (target_pos.x - global_position.x < 0 and scale.x < 0):
					scale.x = -scale.x
				global_position += (target_pos - global_position).normalized() * speed * delta
			else:
				is_fighting = true
				opponent.is_fighting = true
				scale.x = -opponent.scale.x * initial_scale["x"]
		else:
			is_fighting = false
			var target_pos = standby_pos
			if global_position.distance_to(target_pos) >= speed * delta:
				global_position += (target_pos - global_position).normalized() * speed * delta
				if (target_pos.x - global_position.x > 0 and scale.x > 0) or (target_pos.x - global_position.x < 0 and scale.x < 0):
					scale.x = -scale.x
			else:
				global_position = target_pos
				if scale.x < 0:
					scale.x = -scale.x
				if $Timer.is_stopped():
					$Timer.start()
					HP += HP_max / 5
					if HP > HP_max:
						HP = HP_max
	if HP <= 0:
		if opponent != null:
			for i in range(len(opponent.opponents) - 1, -1, -1):
				if opponent.opponents[i] == self:
					opponent.opponents.pop_at(i)
			opponent.is_fighting = false
		for i in range(len(parent.drones)):
			if parent.drones[i] == self:
				parent.drones.pop_at(i)
				break
		queue_free()

func _on_timer_timeout() -> void:
	$Timer.stop()
