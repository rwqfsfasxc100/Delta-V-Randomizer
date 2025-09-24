extends "res://Settings.gd"

# You may want to change many of the variable names to provide a unique identifier
# Make sure anything read by the ModMain is consistent with this file or they will not work
# These are DVRandomizer_default config values
# Any value not set in the config file will generate the missing values exactly as these are
var DVRandomizer = {
	"options":{
		"randomize_ships":true,
		"randomize_equipment":true,
		"allow_unobtainable_ships":false,
		"remove_slot_restriction":false,
		"override_consumable_limits":false,
	},
}

# The config file name. Make sure you set something unique
# Config is set to the cfg folder to make it easy to find
var DVRandomizer_ConfigPath = "user://cfg/DVRandomizer.cfg"
var DVRandomizer_CfgFile = ConfigFile.new()

var DVRandomizer_default = {}

func _ready():
	var dir = Directory.new()
	dir.make_dir("user://cfg")
	load_DVRandomizer_FromFile()
	save_DVRandomizer_ToFile()


func save_DVRandomizer_ToFile():
	for section in DVRandomizer:
		for key in DVRandomizer[section]:
			DVRandomizer_CfgFile.set_value(section, key, DVRandomizer[section][key])
	DVRandomizer_CfgFile.save(DVRandomizer_ConfigPath)


func load_DVRandomizer_FromFile():
	if DVRandomizer_default.keys().size() == 0:
		DVRandomizer_default = DVRandomizer.duplicate(true)
	var error = DVRandomizer_CfgFile.load(DVRandomizer_ConfigPath)
	if error != OK:
		Debug.l("Example Mod: Error loading settings %s" % error)
		return 
	for section in DVRandomizer:
		for key in DVRandomizer[section]:
			DVRandomizer[section][key] = DVRandomizer_CfgFile.get_value(section, key, DVRandomizer[section][key])
	
