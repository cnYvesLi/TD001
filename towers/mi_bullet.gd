extends Area2D
var goal
var have_goal = false
var speed = 1000
var damage = 10  # 子弹伤害值
var level = 1
@onready var sprite = [$level1]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 确保连接信号
	area_entered.connect(_on_area_entered)
	sprite.append($level1)
	sprite[level - 1].visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = true
	if goal and is_instance_valid(goal):  # 检查目标是否有效
		# 计算朝向目标的方向
		var direction = goal.global_position - global_position
		# 移动子弹（注意这里去掉了负号）
		position += direction.normalized() * speed * delta
		# 让子弹朝向目标
		rotation = direction.angle() + PI/2
		if global_position.distance_to(goal.global_position) <= goal.get_node("CollisionShape2D").shape.radius * 0.6:
			# 扣除敌人血量
			exploding(goal.global_position)
			goal.HP -= damage * (1 - goal.DEF)
			goal.get_node("HP_display").HP = goal.HP
			queue_free()
	elif have_goal:
		# 如果目标无效（已被销毁），则删除子弹
		exploding(global_position)
		queue_free()


# 当子弹击中敌人时
func _on_area_entered(area: Area2D) -> void:
	# 检查是否击中目标
	if area == goal:
		exploding(goal.sprite.global_position)
		goal.HP -= damage * (1 - goal.DEF)
		goal.get_node("HP_display").HP = goal.HP
		queue_free()

func exploding(position):
	var explode = preload("res://towers/explode.tscn").instantiate()
	explode.global_position = position
	get_parent().get_parent().add_child(explode)
