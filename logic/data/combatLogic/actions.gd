extends Resource

class_name Action

@export var type: String
@export var cost: int
@export var priority: int
@export var execute_func: Callable

func execute(manager: Node):
	execute_func.call(manager, self)
