extends Area2D
var goal
var speed = 5000
var damage = 10  # 子弹伤害值

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 确保连接信号
	area_entered.connect(_on_area_entered)
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if goal and is_instance_valid(goal):  # 检查目标是否有效
		# 计算朝向目标的方向
		var direction = goal.global_position - global_position
		# 移动子弹（注意这里去掉了负号）
		position += direction.normalized() * speed * delta
		# 让子弹朝向目标
		rotation = direction.angle()
		visible = true
	else:
		# 如果目标无效（已被销毁），则删除子弹
		queue_free()

# 当子弹击中敌人时
func _on_area_entered(area: Area2D) -> void:
	# 检查是否击中目标
	if area == goal:
		# 处理伤害逻辑
		if goal.ES > 0:
			# 如果有护盾，先扣除护盾
			goal.ES -= damage
			if goal.ES < 0:
				# 如果护盾被打破，剩余伤害转移到生命值
				goal.HP += goal.ES  # 加上负值相当于减去溢出的伤害
				goal.ES = 0
		else:
			# 没有护盾直接扣除生命值
			goal.HP -= damage
		
		# 更新血条显示
		goal.get_node("HP_display").HP = goal.HP
		goal.get_node("HP_display").ES = goal.ES
		
		queue_free()  # 销毁子弹
