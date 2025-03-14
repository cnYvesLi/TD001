extends Area2D

var is_chosen : bool = false
var is_entered : bool = false
var is_locked : bool = false
var level = 0
var acessories = [0, 0, 0]
# tower_type: LS MI BH GA FJ
var tower_type : String = ""
const price : Array = [1, 1, 1, 1, 1]
const ranges : Array = [8, 9, 9, 1, 1]
const tower_radius : int = 25
var LS = preload("res://towers/LS.tscn")
var MI = preload("res://towers/MI.tscn")
var GA = preload("res://towers/GA.tscn")
var type
var ui_visible = false  # 新增UI显示状态变量
@onready var sell_p = $UI/sell/sell
@onready var upgrade_p = $UI/upgrade/price
@onready var merge_p = $UI/merge/merge
@onready var damage = $UI/damage
@onready var speed = $UI/speed
@onready var range = $UI/range
var res_upgrade = 0


func _ready() -> void:
	$Tower1.visible = false
	$Tower2.visible = false
	$Tower3.visible = false
	$Tower4.visible = false
	$Tower5.visible = false
	$TowerPositionOpen.visible = false
	$range.visible = false
	$range2.visible = false
	$UI.visible = false  # 初始化时UI不可见
	$UI.modulate.a = 0.8 # 设置UI透明度为80%
	$prev1.modulate.a = 0.5
	$prev2.modulate.a = 0.5
	$prev3.modulate.a = 0.5
	$range.modulate.a = 0.3
	$range2.modulate.a = 0.2
	
func _process(_delta: float):
	$UI.z_index = 100
	var mouse_pos = get_local_mouse_position()
	var enter_tower1 = is_point_in_circle(mouse_pos, $Tower1.position, tower_radius)
	var enter_tower2 = is_point_in_circle(mouse_pos, $Tower2.position, tower_radius)
	var enter_tower3 = is_point_in_circle(mouse_pos, $Tower3.position, tower_radius)
	var enter_tower4 = is_point_in_circle(mouse_pos, $Tower4.position, tower_radius)
	var enter_tower5 = is_point_in_circle(mouse_pos, $Tower5.position, tower_radius)
	if Input.is_action_just_pressed("mouse_left"):
		if is_chosen:
			if  tower_type == "" and not enter_tower1 and not enter_tower2 and not enter_tower3 and not enter_tower4 and not enter_tower5:
				is_chosen = false
				quit_tower_board()
			elif tower_type != "" and not $UI/sell/TowerSellS.visible and not $UI/upgrade/TowerUpgradeS.visible and not $UI/merge/TowerMergeS.visible:
				is_chosen = false
		elif is_entered:
			if not is_chosen:
				is_chosen = true
			if tower_type == "":
				quit_tower_board()
	if is_chosen and tower_type == "":
		choosing_tower()
	elif is_chosen and tower_type != "":
		$UI.visible = true
		$range.visible = true
	else:
		$UI.visible = false
		$range.visible = false
	# 检测点击各个塔的逻辑
	if tower_type == "":
		is_chosen = !is_chosen
		var property = get_parent().energy
		if not $TowerPositionClosed.visible:
			$TowerPositionOpen.visible = true
		preview(enter_tower1, enter_tower2, enter_tower3, enter_tower4, enter_tower5)
		if property > price[0] and $Tower1.visible and enter_tower1 and Input.is_action_just_pressed("mouse_left"):
			tower_type = "LS"
			get_parent().energy -= price[0]
			level += 1
			quit_tower_board()
			type = LS.instantiate()
			add_child(type)
			$CollisionShape2D.scale = Vector2(1.5, 1.5)
		elif property > price[1] and $Tower2.visible and enter_tower2 and Input.is_action_just_pressed("mouse_left"):
			tower_type = "MI"
			get_parent().energy -= price[1]
			level += 1
			quit_tower_board()
			type = MI.instantiate()
			add_child(type)
			$CollisionShape2D.scale = Vector2(1.5, 1.5)
		elif property > price[2] and $Tower3.visible and enter_tower3 and Input.is_action_just_pressed("mouse_left"):
			tower_type = "GA"
			get_parent().energy -= price[2]
			level += 1
			quit_tower_board()
			type = GA.instantiate()
			add_child(type)
			$CollisionShape2D.scale = Vector2(1.5, 1.5)
		elif property > price[3] and $Tower4.visible and enter_tower4 and Input.is_action_just_pressed("mouse_left"):
			tower_type = "BH"
			get_parent().energy -= price[3]
			level += 1
			quit_tower_board()
			$CollisionShape2D.scale = Vector2(1.5, 1.5)
		elif property > price[4] and $Tower5.visible and enter_tower5 and Input.is_action_just_pressed("mouse_left"):
			tower_type = "FJ"
			get_parent().energy -= price[4]
			level += 1
			quit_tower_board()
			$CollisionShape2D.scale = Vector2(1.5, 1.5)
		else:
			is_chosen = !is_chosen
	else:
		$prev1.visible = false
		$prev2.visible = false
		var ready_sell = $UI/sell/TowerSellS.visible and $UI/sell/sell.modulate == Color(0, 1, 0)
		var ready_upgrade = $UI/upgrade/TowerUpgradeS.visible and $UI/upgrade/price.modulate == Color(1, 0, 0)
		var ready_merge = $UI/merge/TowerMergeS.visible and $UI/merge/merge.modulate == Color(1, 0, 0)
		if ready_sell:
			get_parent().energy += type.sell[level - 1]
			if tower_type == "MI":
				for i in range(type.bullets.size() - 1, -1, -1):
					type.bullets[i].queue_free()
			type.queue_free()
			type = null
			tower_type = ""
			is_chosen = !is_chosen
			stage_close()
			level = 0
		if res_upgrade == 0:
			if ready_upgrade and get_parent().energy > type.price[level - 1]:
				get_parent().energy -= type.price[level - 1]
				level += 1
				res_upgrade = 10
				type.level = level
				$range2.visible = false
		else:
			res_upgrade -= 1
		if tower_type != "":
			$range.scale.x = type.d_range[level - 1] / 100.0
			$range.scale.y = type.d_range[level - 1] / 100.0
			if $UI/upgrade/TowerUpgradeS.visible:
				if level <= 2:
					speed.text = str(type.damage_speed[level - 1])
					range.text = str(type.d_range[level]/100)
					damage.text = str(type.damage[level])
					$range2.scale.x = type.d_range[level] / 100.0
					$range2.scale.y = type.d_range[level] / 100.0
					$range2.visible = true
					if type.damage_speed[level] > type.damage_speed[level - 1]:
						speed.modulate = Color(0, 1, 0)
					if type.d_range[level] > type.d_range[level - 1]:
						range.modulate = Color(0, 1, 0)
					if type.damage[level] > type.damage[level - 1]:
						damage.modulate = Color(0, 1, 0)
			else:
				speed.text = str(type.damage_speed[level - 1])
				range.text = str(type.d_range[level - 1]/100)
				damage.text = str(type.damage[level - 1])
				speed.modulate = Color(1, 1, 1)
				range.modulate = Color(1, 1, 1)
				damage.modulate = Color(1, 1, 1)
				type.level = level
				$range2.visible = false
			$TowerPositionOpen.visible = false
			$TowerPositionClosed.visible = false
			$CollisionShape2D.visible = true
			$UI/sell/sell.text = str(type.sell[level - 1])
			$UI/upgrade/price.text = str(type.price[level - 1])
			if level >= 3:
				$UI/merge/merge.text = "100"
			else:
				$UI/merge/merge.text = "INF"

# 添加一个辅助函数来检查点是否在圆形区域内
func is_point_in_circle(point: Vector2, circle_center: Vector2, radius: float) -> bool:
	return point.distance_to(circle_center) <= radius

func _on_mouse_entered() -> void:
	is_entered = true
	if tower_type == "":
		stage_open()


func _on_mouse_exited() -> void:
	is_entered = false
	if !is_chosen:
		if tower_type == "":
			stage_close()

func stage_open():
	$TowerPositionOpen.visible = true
	$TowerPositionClosed.visible = false

func stage_close():
	$TowerPositionOpen.visible = false
	$TowerPositionClosed.visible = true 
	quit_tower_board()

func choosing_tower():
	$Tower1.visible = true
	$Tower2.visible = true
	$Tower3.visible = true
	$Tower4.visible = true
	$Tower5.visible = true


func quit_tower_board():
	$Tower1.visible = false
	$Tower2.visible = false
	$Tower3.visible = false
	$Tower4.visible = false
	$Tower5.visible = false

func preview(enter_tower1, enter_tower2, enter_tower3, enter_tower4, enter_tower5):
	var previewing = false
	#preview LS
	if $Tower1.visible and enter_tower1:
		previewing = true
		$prev1.visible = true
		$TowerPositionOpen.visible = false
		$range.scale.x = ranges[0]
		$range.scale.y = ranges[0]
	else:
		$prev1.visible = false
	#preview MI
	if $Tower2.visible and enter_tower2:
		$prev2.visible = true
		previewing = true
		$TowerPositionOpen.visible = false
		$range.scale.x = ranges[1]
		$range.scale.y = ranges[1]
	else:
		$prev2.visible = false
	#preview GA
	if $Tower3.visible and enter_tower3:
		$prev3.visible = true
		previewing = true
		$TowerPositionOpen.visible = false
		$range.scale.x = ranges[2]
		$range.scale.y = ranges[2]
	else:
		$prev3.visible = false
	#Preview range
	if previewing:
		$range.visible = true
	else:
		$range.visible = false
