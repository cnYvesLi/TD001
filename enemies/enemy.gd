extends Area2D
var HP : float = 0
var ES : float = 0
var DEF : float = 0
var speed : float = 0
var damage : float = 0
var damage_speed : float = 0
var check_point : int = 1
var defensePoint = 0
var value = 0
var path_index = 0
var dis2final = INF
var sprite
var opponents = []
var random_offset
var is_fighting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.one_shot = false
	$Timer.start()
	$Sprite2D.visible = false

func _process(delta: float) -> void:
	$Timer.wait_time = 1 / damage_speed
	$HP_display.HP = HP
	$HP_display.ES = ES
	
	if HP <= 0:
		if len(opponents) > 0:
			for opponent in opponents:
				opponent.opponent = null
				opponent.is_fighting = false
		# 通知主场景增加能量
		get_parent().energy += value
		# 从敌人数组中移除自己
		get_parent().enemies.erase(self)
		# 销毁自己
		queue_free()
	
	# 检查是否到达最后一个检查点
	if check_point >= get_parent().paths[path_index].size():
		print(len(opponents))
		# 扣除防御点数
		get_parent().defensePoints -= defensePoint
		# 从敌人数组中移除自己
		get_parent().enemies.erase(self)
		# 销毁自己
		queue_free()
	if $Timer.is_stopped() and is_fighting and len(opponents) > 0:
		$Timer.start()
		opponents[0].HP -= damage * (1 - opponents[0].DEF)

func init_enemy_type(type):
	sprite = type.instantiate()
	add_child(sprite)
	# 生成-30到+30之间的随机偏移值
	random_offset = randf_range(-50, 50)
	# 获取Sprite2D和CollisionShape2D节点
	var collision = $CollisionShape2D
	var bar = $HP_display
	# 设置两个节点的y轴偏移值
	defensePoint = sprite.defensePoint
	HP = sprite.HP
	ES = sprite.ES
	DEF = sprite.DEF
	value = sprite.value
	speed = sprite.speed
	damage = sprite.damage
	damage_speed = sprite.damage_speed
	sprite.position.y = random_offset
	collision.position.y = random_offset
	bar.position.y += random_offset
	bar.HP = HP
	bar.ES = ES
	bar.HP_max = HP
	bar.ES_max = ES
	
func _on_timer_timeout() -> void:
	$Timer.stop()
