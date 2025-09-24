extends CheckButton

export  var setting = "randomize_ships"
export  var section = "options"

func _ready():
	connect("visibility_changed", self, "_visibility_changed")
	connect("toggled", self, "_toggled")
	
func _toggled(how):
	Settings.DVRandomizer[section][setting] = how

func _visibility_changed():
	pressed = Settings.DVRandomizer[section][setting]
