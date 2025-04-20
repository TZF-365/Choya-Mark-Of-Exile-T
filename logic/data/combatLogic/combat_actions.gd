extends Resource
class_name CombatAction

@export var name: String
@export var type: String  # "attack", "defend", "dodge", "skill", "item", etc.
@export var description: String
@export var kal_cost: int = 0
@export var stamina_cost: int = 0
@export var execute_func: Callable

func resolve_action(actor: BaseChar, action: CombatAction, target: BaseChar):
	action.execute_func.call(actor, target, self)
