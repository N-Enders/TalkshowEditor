extends Label

var timers = ["  Loading.","  Loading..","  Loading..."]
var num = 0
var details = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setDetails(detail):
	details = detail
	print(details)
	_on_timer_timeout()


func _on_timer_timeout():
	num += 1
	text = "  " + details + "\n" + timers[num % 3]
