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

var time_scale := 1.0:
	set(value): time_scale = value

var is_active: bool = true:
	set(value):
		is_active = value
		set_process(is_active)

var is_selected: bool = false:
	set(value):
		if value:
			assert(is_selectable)
		is_selected = value
		selection_toggled.emit(is_selected)

var is_selectable: bool = true:
	set(value):
		is_selectable = value
		if not is_selectable:
			is_selected = false

var _readiness := 0.0:
	set(value): 
		_readiness = value
		readiness_changed.emit(_readiness)
		
		if _readiness >= 100.0:
			ready_to_act.emit()
			set_process(false)


func _process(delta):
	_readiness = _readiness + stats.spd * delta * time_scale


func is_player_controlled() -> bool:
	return ai_scene == null
