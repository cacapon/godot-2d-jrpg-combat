class_name Battler
extends Node2D
## 戦闘に参加しているキャラクターやモンスター。[br]
## どんなバトラーにもAIを与えることができ、コンピューター制御の味方や敵に変身させることができる。

signal ready_to_act
signal readiness_changed(new_value)
signal selection_toggled(value)

@export var stats:BattlerStats
@export var ai_scene: PackedScene
@export var actions: Array[ActionData]
@export var is_party_member := false

var time_scale := 1.0: set = set_time_scale
var is_active: bool = true: set = set_is_active
var is_selected: bool = false: set = set_is_selected
var is_selectable: bool = true: set = set_is_selectable
var _readiness := 0.0: set = _set_readiness


# HPが `0` になったときに反応するように、ステータスの `health_depleted` シグナルに接続します。
func _ready() -> void:
	assert(stats is BattlerStats)
	stats = stats.duplicate() as BattlerStats
	stats.reinitialize()
	stats.health_depleted.connect(_on_BattlerStats_health_depleted)


func _process(delta):
	_readiness = _readiness + stats.spd * delta * time_scale


func is_player_controlled() -> bool:
	return ai_scene == null


func set_time_scale(value:float) -> void:
	time_scale = value


func set_is_active(value:bool) -> void:
	is_active = value
	set_process(is_active)


func set_is_selected(value:bool) -> void:
	if value:
		assert(is_selectable)
	is_selected = value
	selection_toggled.emit(is_selected)


func set_is_selectable(value:bool) -> void:
	is_selectable = value
	if not is_selectable:
		is_selected = false


func _set_readiness(value: float) -> void:
	_readiness = value
	readiness_changed.emit(_readiness)
	
	if _readiness >= 100.0:
		ready_to_act.emit()
		set_process(false)


func _on_BattlerStats_health_depleted() -> void:
	# HPが0になったら, このバトラーの処理をオフにします.
	is_active = false
	# 次に、それが敵であれば、選択不可能にします。
	# パーティメンバーの場合、復活させるために選択できるようにしたい。
	if not is_party_member:
		is_selectable = false
