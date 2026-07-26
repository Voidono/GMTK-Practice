class_name CountdownHealth
extends Node
## The player's health IS a countdown clock, not a damage pool - the
## mechanical core of "Countdown." Time drains on its own just from
## playing; everything you do either buys more of it (killing enemies)
## or burns through it faster (getting hit, holding your time-slow
## ability).
##
## Kept separate from the generic Health.gd (Enemy still uses that,
## unchanged) rather than bolting ticking behavior onto it - these are
## genuinely different semantics, not the same component reused.
##
## Passive drain uses REAL (unscaled) time, same reasoning as
## Player.move()/get_real_delta(): you experience normal time even
## while TimeSlowAbility has slowed everything else down, so holding
## the ability doesn't slow your own countdown as a side effect - it
## keeps draining at the normal rate, PLUS the extra ability-use
## penalty on top. That stacking is what makes the ability cost
## something real instead of being free defensive utility.

signal health_changed(current: float, max: float)
signal died

@export var max_time: float = 60.0            # total seconds you start with
@export var passive_drain_rate: float = 1.0     # seconds lost per REAL second, just from playing
@export var kill_reward: float = 3.0             # seconds gained per enemy killed
@export var ability_use_penalty: float = 1.0      # EXTRA seconds lost per real second while time-slow is held
@export var time_slow_ability: TimeSlowAbility     # optional - drain adds ability_use_penalty while it's active

var current: float
var _is_dead: bool = false

func _ready() -> void:
	current = max_time

func _process(delta: float) -> void:
	if _is_dead:
		return

	var real_delta := delta / Engine.time_scale if Engine.time_scale > 0.0 else delta
	var drain := passive_drain_rate * real_delta

	if time_slow_ability and time_slow_ability.is_active:
		drain += ability_use_penalty * real_delta

	_drain(drain)

## Same public signature as Health.take_damage() - every existing
## attack (SlashHitbox, Projectile, AttackState, OverloadState) already
## calls this via duck-typing, so nothing about them needs to change.
## The attack's own `damage` value becomes seconds lost directly -
## the boss's Overload already costs more than a grunt's swing, for
## free, since it was already tuned to deal more "damage."
func take_damage(amount: int) -> void:
	_drain(float(amount))

## Called by Enemy on death (see enemy.gd's _on_died()).
func reward_kill() -> void:
	if _is_dead:
		return
	current = minf(current + kill_reward, max_time)
	health_changed.emit(current, max_time)

func _drain(amount: float) -> void:
	if _is_dead:
		return

	current = maxf(current - amount, 0.0)
	health_changed.emit(current, max_time)

	if current <= 0.0:
		_is_dead = true
		died.emit()
