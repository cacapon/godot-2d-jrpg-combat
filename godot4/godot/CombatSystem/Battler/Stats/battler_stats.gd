## HPやEN、基本ダメージのようなBattlerの基本ステータスを保存、管理します。
extends Resource
class_name BattlerStats

## キャラクターが `health` を失ったときに発せられます。
signal health_depleted
## `health`の値が変化する度に発せられます。[br]
## これをライフバーのアニメーションに使います。
signal health_changed(old_value, new_value)
## `energy`の値が変化する度に発せられます。
signal energy_changed(old_value, new_value)


## Battlerの最大HPです。
@export var max_health := 100.0
## Battlerの最大ENです。
@export var max_energy := 6

# リソースの仕組み上、Godot 4.2ではhealthは `max_health` という値を持たないことに注意してください。
# このため以下に `reinitialize()` という関数を用意しました。
# 各バトラーはエンカウント開始時にこの関数を呼び出す必要があります。
# これはリソースの初期化が、ゲームでロードするときではなく、エディターで作成してシリアライズするときに起こるためです。
var health := max_health: set = set_health
var energy := 0: set = set_energy

@export var base_attack := 10.0: set = set_base_attack
@export var base_defense := 10.0: set = set_base_defense
@export var base_speed := 70.0: set = set_base_speed
@export var base_hit_chance := 100.0: set = set_base_hit_chance
@export var base_evasion := 0.0: set = set_base_evasion

# The values below are meant to be read-only.
var attack := base_attack
var defense := base_defense
var speed := base_speed
var hit_chance := base_hit_chance
var evasion := base_evasion


func reinitialize() -> void:
	health = max_health


func set_health(value:int) -> void:
	var health_previous := health
	# clampi()`を使用して、値が常に[0, max_health]区間にあることを保証しています。
	health = clampi(value, 0, max_health)
	health_changed.emit(health_previous, health)

	if health == 0:
		health_depleted.emit()


func set_energy(value:int) -> void:
	var energy_previous := energy
	energy = clampi(value, 0, max_energy)
	energy_changed.emit(energy_previous, energy)


func set_base_attack(value:float) -> void:
	base_attack = value
	_recalculate_and_update("attack")


func set_base_defense(value:float) -> void:
	base_defense = value
	_recalculate_and_update("defense")


func set_base_speed(value:float) -> void:
	base_speed = value
	_recalculate_and_update("speed")


func set_base_hit_chance(value:float) -> void:
	base_hit_chance = value
	_recalculate_and_update("hit_chance")


func set_base_evasion(value:float) -> void:
	base_evasion = value
	_recalculate_and_update("evasion")


func _recalculate_and_update(stats:String):
	#TODO:ダミーで作成
	pass
