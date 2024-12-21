extends AudioStreamPlayer2D
@onready var stat = $"../entity_var".bgm
@onready var bgm_n = $"../entity_var".bgm
@onready var bgm = $backgroundmusic1
@onready var battle = preload("res://assets/Music/battlemusic.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(bgm_n)
	if !bgm_n == true:
		$".".stream = battle
		$".".play()
	print($".".playing)	
	
