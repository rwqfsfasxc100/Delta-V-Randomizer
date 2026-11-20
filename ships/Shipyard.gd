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

extends "res://ships/Shipyard.gd"

onready var upgrade_scene = preload("res://enceladus/Upgrades.tscn").instance()

var invalid_ships = PoolStringArray(["HYBRID","OBONTO","MADCERF","DRONE","ATLAS","TSUKUYOMI"])

var random_num_gen = RandomNumberGenerator.new()

func createShipByConfig(cfg: Dictionary, new = true, age = 24 * 3600 * 365 * 100, sd = 0):
	var allow_invalids = Settings.DVRandomizer["options"]["allow_unobtainable_ships"]
	var allow_ship_randomization = Settings.DVRandomizer["options"]["randomize_ships"]
	var allow_equipment_randomization = Settings.DVRandomizer["options"]["randomize_equipment"]
	var valid_ships = []
	for shp in ships:
		if allow_invalids:
			valid_ships.append(shp)
		else:
			if shp in invalid_ships:
				pass
			else:
				valid_ships.append(shp)
	var sps = valid_ships.size()
	if sps >= 1:
		var select = valid_ships[int(rand_range(0,sps - 1))]
		if allow_ship_randomization:
			cfg.model = select
	var random_ship_data = .createShipByConfig(cfg, new, age, sd)
	var equipment_data = {}
	var upg_items_path = NodePath("VB/MarginContainer/ScrollContainer/MarginContainer/Items")
	var slots = upgrade_scene.get_node(upg_items_path).get_children()
	for slot in slots:
		var slot_type_main = slot.slot
		for i in slot.get_node("VBoxContainer").get_children():
			if slot.isUpgrade(i):
				if slot_type_main == "":
					slot_type_main = i.slot
				if slot_type_main in equipment_data:
					pass
				else:
					equipment_data.merge({slot_type_main:[]})
				
				var add = true
				var sys = i.system
				if i.numVal >= 0:
					sys = i.numVal
#				var shipAllows = alwaysAllows(slot_type_main,random_ship_data,slot.restrictType,slot.always)
#				if shipAllows:
#					if i.visible == false:
#						add = false
#					if i.capabilityLock:
#						if not random_ship_data.queryCapability(slot_type_main, i.system):
#							add = false
#					if i.numVal >= 0:
#						if Settings.DVRandomizer["options"]["override_consumable_limits"]:
#							add = true
#						else:
#							var limit = random_ship_data.upgradeLimits.get(slot_type_main, null)
#							if limit is Vector2:
#								if i.numVal < limit.x or i.numVal > limit.y:
#									add = false
#				else:
#					add = false
				
				add = i.visible
				
				if Settings.DVRandomizer["options"]["remove_slot_restriction"]:
					add = true
				
				if add:
					equipment_data[slot_type_main].append(sys)
				
	if allow_equipment_randomization:
		for s in equipment_data:
			var dt = equipment_data.get(s)
			var size = dt.size()
			if size >= 1:
				var select = dt[int(rand_range(0,size - 1))]
				random_ship_data.setConfig(s,select)
#	random_num_gen.randomize()
#	random_ship_data.initializeTuning()
#	get_tuning(random_ship_data)
#	var config = random_ship_data.shipConfig
#	random_ship_data.shipConfig.fuel.initial = config.fuel.capacity
#	random_ship_data.shipConfig.drones.initial = config.drones.capacity
#	random_ship_data.shipConfig.ammo.initial = config.ammo.capacity
#	var fc = random_ship_data.fullConfig
	return random_ship_data


func alwaysAllows(slot,ship,restrictType,always):
	if slot or restrictType:
		var cfg = ship.getConfigWithDefaults(slot)
		var type = ship.shipType
		
		if ( not cfg and not always) or (restrictType and type != restrictType):
			return false
		else:
			return true


func get_tuning(ship):
	if Tool.claim(ship):
		if not ship.setup:
			
			yield(ship, "setup")
			
		var systems = ship.getSystems()
		var group = {}
		var used = {}
		var first = true
		for k in systems:
			var key = k
			var s = systems[k]
			var name = s.name
			var system = s.ref
			if "slotName" in s.ref:
				key = s.ref.slotName
				
			if system.has_method("getTuneables") and not used.has(key):
				var tuning = system.getTuneables()
				if tuning:
					used[key] = true
					for titem in tuning:
						var tit = tuning[titem]
						var sn = name
						if "subsystem" in tit and tit.subsystem:
							sn = tit.subsystem
							
						var gk = "%s:%s" % [sn, key]
							
						if not gk in group:
							group[gk] = {"key": key, "name": sn, "tuning": {}}
						
						group[gk].tuning[titem] = tit
		Tool.release(ship)
		
		for gn in group:
			var system = group[gn].name
			var key = group[gn].key
			var tuning = group[gn].tuning
			
			for k in tuning:
				var tune = tuning[k]
				match tune.type:
					"float":
						var tuningItem = k
						var rng = rng_float(tune.min,tune.max,tune.step,tune.default)
						tuningChanged(key,tuningItem,rng,ship)
#						breakpoint
					"bool":
						var tuningItem = k
						var rng = rng_bool()
						tuningChanged(key,tuningItem,rng,ship)
#						breakpoint
			
#			breakpoint

func tuningChanged(system, type, to, ship):
	ship.setTunedValue(system, type, to)
	
	if Tool.claim(ship):
		ship.setTunedValue(system, type, to)
		Tool.release(ship)

func rng_float(minimum, maximum, step, default):
	random_num_gen.randomize()
	var reroll = true
	var value = default
	var r = int(rand_range(minimum/step,maximum/step))
	value = r*step
	if value > maximum or value < minimum:
		breakpoint
	if value == null:
		breakpoint
#	while not reroll:
#		reroll = false
#		var r = int(rand_range(minimum/step,maximum/step))
#		var probability = int(float(default/step))-r
#		var chance = int(float(default/step))
#		var stand = int(rand_range(0,chance))
#
#		if probability < stand:
#			reroll = true
#		value = r*step
#		if value > maximum or value < minimum:
#			breakpoint
#		if value == null:
#			breakpoint
	return value

func rng_bool():
	if randf() < 0.5:
		return true
	else:
		return false
