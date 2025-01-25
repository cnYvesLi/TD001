extends Area2D

var is_chosen : bool = false
var is_entered : bool = false
var is_locked : bool = false
var level = 0
var acessories = [0, 0, 0]
# tower_type: LS MI BH GA FJ
var tower_type : String = ""
const price : Array = [1, 1, 1, 1, 1]
const tower_radius : int = 25
var LS = [preload("res://towers/LS.tscn")]
var type
var ui_visible = false  # 新增UI显示状态变量

func _ready() -> void:
	$Tower1.visible = false
	$Tower2.visible = false
	$Tower3.visible = false
	$Tower4.visible = false
	$Tower5.visible = false
	$TowerPositionOpen.visible = false
	$UI.visible = false  # 初始化时UI不可见
	$UI.modulate.a = 0.7 # 设置UI透明度为80%

func _process(_delta: float):
	if is_entered and Input.is_action_just_pressed("press"):
		is_chosen = !is_chosen
		if tower_type == "":
			# 未建造塔时的原有逻辑
			quit_tower_board()
	
	if is_chosen and tower_type == "":
		choosing_tower()
	elif is_chosen and tower_type != "":
		$UI.visible = true
	else:
		$UI.visible = false
	var mouse_pos = get_local_mouse_position()
	# 检测点击各个塔的逻辑
	if tower_type == "":
		is_chosen = !is_chosen
		var property = get_parent().energy
		if property > price[0] and $Tower1.visible and is_point_in_circle(mouse_pos, $Tower1.position, tower_radius) and Input.is_action_just_pressed("press"):
			tower_type = "LS"
			get_parent().energy -= price[0]
			level += 1
			quit_tower_board()
			type = LS[0].instantiate()
			add_child(type)
			$CollisionShape2D.scale = Vector2(1.5, 1.5)
		elif property > price[1] and $Tower2.visible and is_point_in_circle(mouse_pos, $Tower2.position, tower_radius) and Input.is_action_just_pressed("press"):
			tower_type = "MI"
			get_parent().energy -= price[1]
			level += 1
			quit_tower_board()
			$CollisionShape2D.scale = Vector2(1.5, 1.5)
		elif property > price[2] and $Tower3.visible and is_point_in_circle(mouse_pos, $Tower3.position, tower_radius) and Input.is_action_just_pressed("press"):
			tower_type = "BH"
			get_parent().energy -= price[2]
			level += 1
			quit_tower_board()
			$CollisionShape2D.scale = Vector2(1.5, 1.5)
		elif property > price[3] and $Tower4.visible and is_point_in_circle(mouse_pos, $Tower4.position, tower_radius) and Input.is_action_just_pressed("press"):
			tower_type = "GA"
			get_parent().energy -= price[3]
			level += 1
			quit_tower_board()
			$CollisionShape2D.scale = Vector2(1.5, 1.5)
		elif property > price[4] and $Tower5.visible and is_point_in_circle(mouse_pos, $Tower5.position, tower_radius) and Input.is_action_just_pressed("press"):
			tower_type = "FJ"
			get_parent().energy -= price[4]
			level += 1
			quit_tower_board()
			$CollisionShape2D.scale = Vector2(1.5, 1.5)
		else:
			is_chosen = !is_chosen
	else:
		$TowerPositionOpen.visible = false
		$TowerPositionClosed.visible = false
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
