extends Node2D

var locked_tower = -1
var time_res = 0
var towers = []  # 创建数组存储所有tower
var roots = []
var root1 = []
var enemy_scene = preload("res://enemies/001.tscn")  # 预加载敌人场景
var enemies = []  # 存储所有敌人实例的数组

# 存储敌人数据的结构体
class EnemyData:
	var type: String  # 敌人类型 (例如 "001")
	var root_index: int  # 路径索引
	var spawn_time: float  # 出现时间
	
	func _init(t: String, r: int, st: float):
		type = t
		root_index = r
		spawn_time = st
	
	func _to_string() -> String:
		return "[Type: %s, Index: %d, Time: %.2f\n]" % [type, root_index, spawn_time]

var enemies_data = []  # 存储从文件读取的敌人数据
var enemy_scenes = {
	"001": preload("res://enemies/001.tscn"),
	# 在这里添加更多敌人类型
}

func _ready():
	# 初始化towers数组
	towers = [$Tower, $Tower2, $Tower3]
	root1 = [$Checkpoint, $Checkpoint2, $Checkpoint3, $Checkpoint4]
	roots.append(root1)
	for i in range(root1.size()):
		root1[i].visible = false	
	# 读取敌人配置文件
	load_enemy_sequence()
	time_res = 0
	print(enemies_data)

func _process(delta: float) -> void:
	time_res += delta
	locking()
	change_tower_stage()
	spawn_enemies()
	update_enemies_position(delta)  # 添加更新敌人位置的调用

func locking():
	for i in range(towers.size()):
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
	for enemy in enemies:
		if enemy.check_point >= roots[enemy.root_index].size():
			continue  # 跳过已经到达终点的敌人
		var target = roots[enemy.root_index][enemy.check_point].position
		var direction = target - enemy.position
		var distance = direction.length()
		
		# 如果到达当前检查点
		if distance <= enemy.speed * delta:
			enemy.check_point += 1  # 移动到下一个检查点
			if enemy.check_point < roots[enemy.root_index].size():
				# 如果还有下一个点，直接设置到当前点的位置
				enemy.position = target
		else:
			# 向目标点移动
			enemy.position += direction.normalized() * enemy.speed * delta

# 生成敌人的函数
func spawn_enemy(enemy_data: EnemyData):
	if enemy_scenes.has(enemy_data.type):
		var enemy = enemy_scenes[enemy_data.type].instantiate()
		add_child(enemy)
		enemies.append(enemy)
		# 设置敌人的初始属性
		if enemy_data.root_index < roots.size():
			enemy.root_index = enemy_data.root_index  # 保存路径索引
			enemy.check_point = 0  # 初始检查点
			enemy.position = roots[enemy_data.root_index][0].position

func spawn_enemies():
	for i in range(enemies_data.size() - 1, -1, -1):
		if time_res > enemies_data[i].spawn_time:
			spawn_enemy(enemies_data[i])
			enemies_data.pop_at(i)
