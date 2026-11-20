# [license]
# SPDX-License-Identifier: LicenseRef-Proprietary
# Copyright © 2026 __hev (Benjamin Buckhurst). All Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that all following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

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
	},
}

# The config file name. Make sure you set something unique
# Config is set to the cfg folder to make it easy to find
var DVRandomizer_ConfigPath = "user://cfg/Delta-V-Randomizer.cfg"
var DVRandomizer_CfgFile = ConfigFile.new()

var DVRandomizer_default = {}

var random_settings_uinit : bool = false
func _ready():
	if random_settings_uinit:
		ModLoader._savedObjects[0].log_double_load_error(get_script().resource_path)
	random_settings_uinit = true
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
	
