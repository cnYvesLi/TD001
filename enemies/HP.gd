extends Node2D
const length = 458
var HP_max = 100
var ES_max = 100
var HP = 100
var ES = 100

@onready var hp_bar = $HP  # 血条精灵引用
@onready var es_bar = $ES  # 护盾精灵引用

func _process(delta: float) -> void:
	update_bars()
	HP -= 0.2
	ES -= 0.1
	if ES < 0:
		ES = 0
	if HP < 0:
		HP = 0

func update_bars():
	# 计算并设置血条的缩放
	if HP >= 0:
		var hp_scale = HP / float(HP_max)
		hp_bar.scale.x = hp_scale
		hp_bar.position.x = length * (1 - hp_scale) / -2
	
	# 计算并设置护盾条的缩放
	if ES >= 0:
		var es_scale = ES / float(ES_max)
		es_bar.scale.x = es_scale
		es_bar.position.x = length * (1 - es_scale) / -2
