## すべてのバトラーに順番待ちとターンの委任を行います。
class_name ActiveTurnQueue
extends Node

var _party_members :Array[Battler] = []
var _opponents :Array[Battler] = []

## 戦闘のイントロ, カットシーン, 戦闘終了時に, 戦闘を一時停止できるようにします。[br]
## 各バトラーの `is_active` を更新します。
var is_active: bool = true:
	set(value):
		is_active = value
		for battler:Battler in battlers:
			battler.is_active = is_active

## ActiveTurnQueueのtime_scaleはアクセシビリティと難易度コントロールのために使います。[br]
## 各バトラーの `time_scale` を更新します。
var time_scale:= 1.0: 
	set(value):
		time_scale = value
		for battler:Battler in battlers:
			battler.time_scale = time_scale

## エンカウントした際のすべてのバトラーはこのノードの子になります.[br]
## get_children()ですべてのリストを得ることができます。
@onready var battlers := get_children()


func _ready() -> void:
	for battler:Battler in battlers:
		# 各バトラーのready_to_actシグナルをリッスンし、
		# バトラーへの参照をコールバックにバインドします。
		battler.ready_to_act.connect(_on_Battler_ready_to_act)
		if battler.is_party_member:
			_party_members.append(battler)
		else:
			_opponents.append(battler)


func _play_turn(battler: Battler) -> void:
	var action_data: ActionData
	var targets := []
	
	battler.stats.energy += 1

	# 以下は、`Battler.is_selectable`を使って選択可能なターゲットのリストを作っています。
	var potential_targets := []
	var opponents := _opponents if battler.is_party_member else _party_members
	for opponent in opponents:
		if opponent.is_selectable:
			potential_targets.append(opponent)

	if battler.is_player_controlled():
		# 次のレッスンでは、プレイアブルなBattlerを前進させるために、この選択を使用します。
		# この値は対象のバトラーのHUDを前方に移動させます。
		battler.is_selected = true
		# プレイヤーがアクションとターゲットを選択する間、時間を遅くします。
		# time_scaleのsetterで設定値を戦場にいる全てのキャラに再帰的に割り当てます。
		time_scale = 0.05

		# ここがプレーヤーのターンの肝になる部分です。
		# whileループを使って、プレイヤーが有効なアクションとターゲットを選択するのを待ちます。
		#
		# 今のところ、2つの定型的な非同期関数 
		# `_player_select_action_async()` と `_player_select_targets_async()` があり、
		# それぞれ実行するアクションとターゲットの配列を返します。
		# この一見複雑に見えるセットアップにより、プレイヤーはメニュー操作をキャンセルできます。
		var is_selection_complete := false
		# ループはプレイヤーがアクションとターゲットを選択するまで続きます。
		while not is_selection_complete:
			# プレイヤーはまずアクションを選択し、次にターゲットを選択する。
			# 選択されたアクションは、関数開始時に定義された変数 `action_data` に格納されます。
			action_data = await _player_select_action_async(battler) # complatedは不要
			# アクションがBattlerだけに効果適用する場合, 自動でBattlerをターゲットにします.
			if action_data.is_targeting_self:
				targets = [battler]
			else:
				targets = await _player_select_targets_async(action_data, potential_targets)
			# プレイヤーが正しいアクションとターゲットを選択すると、ループから抜け出せます。
			# コードを読みやすく明快にするために変数を使用しています。
			# `while true`とbreakを使うこともできますが、コードが明示的ではなくなります。
			is_selection_complete = action_data != null && targets != []
		# プレイヤーが操作するバトラーが行動する準備が整いました。
		# タイムスケールをリセットし、バトラーの選択を解除します。
		time_scale = 1.0
		battler.is_selected = false
	else:
		# TODO:まだ出来上がっていないのでハードコーディング
		action_data = battler.actions[0]
		targets = [potential_targets[0]]

# メソッドをコルーチンにするために、プレースホルダーの `await` 呼び出しを使わないといけません。
# そうでなければ、`_play_turn()` メソッドで `await` を使うことはできません。
func _player_select_action_async(battler: Battler) -> ActionData:
	# TODO:まだ出来上がっていないのでハードコーディング
	# godot3+ get_tree().idle_frame -> godot4+ get_tree().process_frame
	await get_tree().process_frame
	return battler.actions[0]


func _player_select_targets_async(_action: ActionData, opponents: Array[Battler]) -> Array[Battler]:
	# TODO:まだ出来上がっていないのでハードコーディング
	await get_tree().process_frame
	return [opponents[0]]


func _on_Battler_ready_to_act(battler: Battler):
	_play_turn(battler)
