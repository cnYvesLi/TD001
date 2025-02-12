extends Node2D

var locked_tower = -1
var time_res = 0
var energy = 150
var defensePoints = 10
var towers = []  # 创建数组存储所有tower
var paths = []
var path1 = []
var enemy_scene = preload("res://enemies/001.tscn")  # 预加载敌人场景
var enemies = []  # 存储所有敌人实例的数组
var energy_label 
var defense_label  # 新增防御点数标签变量
@onready var p1_satellites = [$Tower, $Tower2, $Tower3]
@onready var p1 = $p1
@onready var offset_planets = {p1:0}

# 存储敌人数据的结构体
class EnemyData:
	var type: String  # 敌人类型 (例如 "001")
	var path_index: int  # 路径索引
	var spawn_time: float  # 出现时间
	
	func _init(t: String, r: int, st: float):
		type = t
		path_index = r
		spawn_time = st
	
	func _to_string() -> String:
		return "[Type: %s, Index: %d, Time: %.2f\n]" % [type, path_index, spawn_time]

var enemies_data = []  # 存储从文件读取的敌人数据
var enemy_scenes = {
	"001": preload("res://enemies/001.tscn"),
	# 在这里添加更多敌人类型
}

func _ready():
	# 初始化标签
	energy_label = $Energy
	defense_label = $Defense  # 获取防御点数标签引用
	
	towers = [$Tower, $Tower2, $Tower3]
	path1 = [$Checkpoint, $Checkpoint2, $Checkpoint3, $Checkpoint4]
	paths.append(path1)
	for i in range(path1.size()):
		path1[i].visible = false	
	# 读取敌人配置文件
	load_enemy_sequence()
	time_res = 0
	print(enemies_data)
	
	# 设置背景颜色为黑色
	RenderingServer.set_default_clear_color(Color(0, 0, 0, 1))
	
	# 设置标签的字体大小
	energy_label.add_theme_font_size_override("font_size", 40)
	defense_label.add_theme_font_size_override("font_size", 40)  # 设置防御点数标签字体大小

func _process(delta: float) -> void:
	time_res += delta
	locking()
	change_tower_stage()
	spawn_enemies()
	update_enemies_position(delta)  # 添加更新敌人位置的调用
	relocate(p1, p1_satellites, 250)
	# 更新标签文本
	energy_label.text = "Energy: " + str(energy)
	defense_label.text = "Defense: " + str(defensePoints)  # 更新防御点数显示
	
	# 检查右键是否按下并且在 p1 范围内
	if p1.position.distance_to(get_global_mouse_position()) <= $p1/CollisionShape2D.shape.radius:
		if Input.is_action_pressed("mouse_right"):
			offset_planets[p1] += delta  # 持续增加 offset_planets[p1] 的值

func relocate(planet, satellites, distance):
	var num_satellites = satellites.size()
	for i in range(num_satellites):
		var angle = (i * 2 * PI) / num_satellites  # 计算每个卫星的角度
		var x = planet.position.x + distance * cos(angle + offset_planets[planet])  # 计算 x 坐标
		var y = planet.position.y + distance * sin(angle + offset_planets[planet])  # 计算 y 坐标
		satellites[i].position = Vector2(x, y)  # 设置卫星位置

func locking():
	for i in range(towers.size()):
		if locked_tower == i + 1:
			towers[i].z_index = 10
		else:
			towers[i].z_index = 0
		if towers[i].is_chosen and locked_tower != i + 1:
			locked_tower = i + 1
			change_tower_stage()
			towers[i].stage_open()

func change_tower_stage():
	for i in range(towers.size()):
		if locked_tower != i + 1 and towers[i].is_chosen:
			towers[i].is_chosen = false
			towers[i].stage_close()

# 读取敌人序列配置文件
func load_enemy_sequence():
	var file = FileAccess.open("res://enemies/sequence/m1.txt", FileAccess.READ)
	if file:
		while !file.eof_reached():
			var line = file.get_line().strip_edges()
			if line.length() > 0:  # 忽略空行
				var data = line.split(" ")
				if data.size() >= 3:
					var enemy_data = EnemyData.new(
						data[0],  # 敌人类型
						int(data[1]),  # 路径索引
						float(data[2])  # 出现时间
					)
					enemies_data.append(enemy_data)

# 更新所有敌人的位置
func update_enemies_position(delta: float) -> void:
	# 首先清空所有炮塔的 enemies_in_range
	for tower in towers:
		if tower.type:
			tower.type.enemies_in_range.clear()
	
	for enemy in enemies:
		if enemy.check_point >= paths[enemy.path_index].size():
			continue  # 跳过已经到达终点的敌人
		
		# 更新到终点的距离
		var last_checkpoint = paths[enemy.path_index][paths[enemy.path_index].size() - 1]
		enemy.dis2final = enemy.position.distance_to(last_checkpoint.position)
		
		# 检查每个炮塔与敌人的距离
		for tower in towers:
			if tower.type:  # 确保炮塔有类型
				var distance = enemy.global_position.distance_to(tower.global_position)
				if distance <= tower.type.d_range[tower.level - 1]:
					# 将敌人及其到终点的距离添加到炮塔的检测范围内
					tower.type.enemies_in_range[enemy] = enemy.dis2final
		
		# 原有的移动逻辑
		if not enemy.is_fighting:
			var target = paths[enemy.path_index][enemy.check_point].position
			var direction = target - enemy.position
			var distance = direction.length()
			if (target.x - enemy.position.x > 0 and enemy.scale.x > 0) or (target.x - enemy.position.x < 0 and enemy.scale.x < 0):
				enemy.scale.x = -enemy.scale.x
			if distance <= enemy.speed * delta:
				enemy.check_point += 1
				if enemy.check_point < paths[enemy.path_index].size():
					enemy.position = target
			else:
				enemy.position += direction.normalized() * enemy.speed * delta

# 生成敌人的函数
func spawn_enemy(enemy_data: EnemyData):
	if enemy_scenes.has(enemy_data.type):
		var enemy = preload("res://enemies/enemy.tscn").instantiate()
		enemy.init_enemy_type(enemy_scenes[enemy_data.type])
		add_child(enemy)
		enemies.append(enemy)
		# 设置敌人的初始属性
		if enemy_data.path_index < paths.size():
			enemy.path_index = enemy_data.path_index  # 保存路径索引
			enemy.check_point = 0  # 初始检查点
			enemy.position = paths[enemy_data.path_index][0].position

func spawn_enemies():
	for i in range(enemies_data.size() - 1, -1, -1):
		if time_res > enemies_data[i].spawn_time:
			spawn_enemy(enemies_data[i])
			enemies_data.pop_at(i)
