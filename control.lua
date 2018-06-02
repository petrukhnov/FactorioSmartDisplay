-- debug_status = 1
debug_mod_name = "SmartDisplayRedux"
debug_file = debug_mod_name .. "-debug.txt"
require("utils")
require("config")

local aligns = {left = 1, center = 2, right = 3}

-- taken from Nixie Tubes by GopherAtl and justarandomgeek
local signalColorMap = {
  ["off"]           = {r=1.0,  g=1.0,  b=1.0, a=1}, -- off state, no glow
  ["default"]       = {r=1.0,  g=0.6,  b=0.2, a=1}, -- pretty close to original-orange
  ["signal-red"]    = {r=1.0,  g=0.2,  b=0.2, a=1},
  ["signal-green"]  = {r=0.2,  g=1.0,  b=0.2, a=1},
  ["signal-blue"]   = {r=0.6,  g=0.6,  b=1.0, a=1}, -- pure blue is too dark, so brighten it up just a little bit
  ["signal-yellow"] = {r=1.0,  g=1.0,  b=0.2, a=1},
  ["signal-pink"]   = {r=1.0,  g=0.4,  b=1.0, a=1},
  ["signal-cyan"]   = {r=0.0,  g=1.0,  b=1.0, a=1},
}

--------------------------------------------------------------------------------------
local function set_thousands( s )
	local s2 = ""
	local l = string.len(s)
	local i = l+1
	
	while i > 4 do
		i = i-3	
		s2 =  thousands_separator .. string.sub(s,i,i+2) .. s2
	end
	
	if i > 1 then
		s2 =  string.sub(s,1,i-1) .. s2
	end
	
	return( s2 )
end

--------------------------------------------------------------------------------------
local function set_chk_divisor( flow, chk )
	local name = chk.name
	local state = chk.state
	flow.chk_kilo.state = false
	flow.chk_mega.state = false
	flow.chk_giga.state = false
	flow.chk_tera.state = false
	chk.state = state
	if state then
		if chk.name == "chk_kilo" then
			return( 1e3 )
		elseif chk.name == "chk_mega" then
			return( 1e6 )
		elseif chk.name == "chk_giga" then
			return( 1e9 )
		elseif chk.name == "chk_tera" then
			return( 1e12 )
		end
	end
	return( 1 )
end

--------------------------------------------------------------------------------------
local function find_display(tofind)
	for _, display in ipairs(global.smart_displays) do
		if display.entity == tofind then
			return(display)
		end
	end
	return(nil)
end

--------------------------------------------------------------------------------------
local function add_mapmark( display )
	if display.mapmark == nil then
		local ent = display.entity
		local mapmark = ent.surface.create_entity({name = "smart-display-mapmark", force = game.forces.neutral, position = ent.position})
		script.raise_event(defines.events.on_built_entity, {created_entity = mapmark})
		mapmark.operable = false
		mapmark.active = false
		display.mapmark = mapmark
	end
end

--------------------------------------------------------------------------------------
local function add_radar( display )
	if display.radar == nil then
		local ent = display.entity
		local radar = ent.surface.create_entity({name = "smart-display-radar", force = ent.force, position = ent.position})
		display.radar = radar
	end
end

--------------------------------------------------------------------------------------
local function get_signal_value(entity)
	local behavior = entity.get_control_behavior()
	if behavior == nil then	return(nil)	end
	
	local condition = behavior.circuit_condition
	if condition == nil then return(nil) end
	
	local signal = condition.condition.first_signal
	
	if signal == nil or signal.name == nil then return(nil)	end
	
	-- debug_print( "cond=("  .. signal.name .. ")" )
	
	local network_red = entity.get_circuit_network(defines.wire_type.red)
	local network_green = entity.get_circuit_network(defines.wire_type.green)
	if network_red == nil and network_green == nil then return(nil) end
	
	local val = 0
	
	if network_red ~= nil then 
		val = network_red.get_signal(signal)
	end
	
	if network_green ~= nil then 
		val = val + network_green.get_signal(signal)
	end
	
	-- debug_print( "val=", val )
	
	return(val)
end

local function getAlphaSignals(entity,wire_type,charsig,colorsig)
  local net = entity.get_circuit_network(wire_type)

  local ch,co = charsig,colorsig

  if net then
    for _,s in pairs(net.signals) do
      if signalColorMap[s.signal.name] then
        co = signalColorMap[s.signal.name]
      end
    end
  end

  return ch,co
end


--------------------------------------------------------------------------------------
local function update_display(display,force)
	local ent = display.entity
	local v = get_signal_value(ent)
	
	if (not force) then
		if v == display.last_v then return end
		display.last_v = v
	end

	local s 
	local slen
	local lfix = display.lfix
	local div = display.divisor
	local c, tag
	local pos = ent.position
	local x= pos.x - 0.5 -- +x is right
	local y = pos.y + 0.5 -- +y is down
	local font_scale = font_scales[display.font_scale_index]
--	local font_scale = font_scales[1]
	local font_scale_tag = tostring( font_scale * 10 )
	local dy = font_scale*(under_height-font_height)/2/32
	local surf = ent.surface
	local force = ent.force
	
	  local _,color = nil,nil
	  if display.use_colors then
		 _,color=getAlphaSignals(entity,defines.wire_type.red,_,color)
		 _,color=getAlphaSignals(entity,defines.wire_type.green,_,color)
	  end
	  if color == nil then
		color = signalColorMap["default"]
	  end
	  
	if v == nil then 
		if display.leading_zeros and lfix > 0 then
			s = string.rep( "-", lfix )
		else
			s = "-"
		end
	else
		if div > 1 and type(v) == "number" then
			v = math.floor(v / div )
		end
		
		s = tostring(v)
		if display.thousands then
			s = set_thousands( v )
		end
		
		if lfix > 0 then
			s = string.sub(s,1,lfix)
			slen = string.len(s)
			if display.leading_zeros then
				s = string.rep("0",lfix-slen) .. s
			else
				s = string.rep(" ",lfix-slen) .. s
			end
		end
		
		if div ~= 1 then
			if div == 1e3 then
				s = s .."k"
			elseif div == 1e6 then
				s = s .."M"
			elseif div == 1e9 then
				s = s .."G"
			elseif div == 1e12 then
				s = s .."T"
			end
		end
	end

	s = display.prefix .. s .. display.suffix

	slen = string.len(s)
	
	if display.mapmark then
			display.mapmark.backer_name = s
	end
	
	if display.align == aligns.right then
		x = x - font_scale * ((slen-1) * font_width )/32 - (font_scale-1) * (font_width+under_width+3) / 32
	elseif display.align == aligns.center then
		x = x - font_scale * (3 + ((slen-1) * font_width )/2)/32
	else
		x = x - font_scale * 3 /32
	end

	for _,deco in pairs(display.decos) do
		if deco and deco.valid then deco.destroy() end
	end
	
	display.decos = {}
	
	-- debug_print( "s=", s )
	-- debug_print( "dy=", dy )

	deco = surf.create_entity({name = prefix_under_g .. font_scale_tag, force = force, position = {x,y}})
	table.insert( display.decos, deco )
	x = x + font_scale * under_width / 32

	for i = 1, slen do
		c = string.sub( s, i, i ) 
		asc = string.byte(c)
		-- debug_print( c, "=", asc )
		if asc < first_asc or asc > last_asc then asc = string.byte("?") end
		deco = surf.create_entity({name = prefix_under_c .. font_scale_tag, force = force, position = {x,y}})
		table.insert( display.decos, deco )
		deco = surf.create_entity({name = prefix_font .. font_scale_tag .. "_" .. asc, force = force, position = {x,y+y_shift_priority}})
		table.insert( display.decos, deco )
		x = x + font_scale * font_width / 32
	end

	local deco = surf.create_entity({name = prefix_under_d .. font_scale_tag, force = force, position = {x,y}})
	table.insert( display.decos, deco )
end

--------------------------------------------------------------------------------------
local function show_menu_display(player, display)
	local gui1 = player.gui.left.frame_smadisp
	
	if gui1 == nil then
		gui1 = player.gui.left.add({type = "frame", name = "frame_smadisp", caption = "Smart display", direction = "vertical", style = "smadisp_frame_style"})
		local guif2 = gui1.add({type = "flow", name = "flow_smadisp", direction = "vertical", style = "smadisp_vertical_flow_style"})

		local gui3 = guif2.add({type = "flow", name = "flow_prefix", direction = "horizontal", style = "smadisp_flow_style"})
		gui3.add({type = "label", name = "label_prefix", caption = {"gui-smadisp-prefix"}, style = "smadisp_label_style"})
		gui3.add({type = "textfield", name = "textfield_prefix", text = "", style = "smadisp_textfield_style"})
		
		gui3 = guif2.add({type = "flow", name = "flow_suffix", direction = "horizontal", style = "smadisp_flow_style"})
		gui3.add({type = "label", name = "label_suffix", caption = {"gui-smadisp-suffix"}, style = "smadisp_label_style"})
		gui3.add({type = "textfield", name = "textfield_suffix", text = "", style = "smadisp_textfield_style"})
		
		gui3 = guif2.add({type = "flow", name = "flow_scale", direction = "horizontal", style = "smadisp_flow_style"})
		gui3.add({type = "label", name = "lab_scale", caption = "", "default", style = "smadisp_label_style"})
		gui3.add({type = "button", name = "but_scale_dec", caption = "-", style = "smadisp_button_style"})
		gui3.add({type = "button", name = "but_scale_inc", caption = "+", style = "smadisp_button_style"})	

		gui3 = guif2.add({type = "flow", name = "flow_align", direction = "horizontal", style = "smadisp_flow_style"})
		gui3.add({type = "label", name = "lab_align", caption = "", "default", style = "smadisp_label_style"})
		gui3.add({type = "button", name = "but_align_dec", caption = "<", style = "smadisp_button_style"})
		gui3.add({type = "button", name = "but_align_inc", caption = ">", style = "smadisp_button_style"})	

		gui3 = guif2.add({type = "flow", name = "flow_lfix", direction = "horizontal", style = "smadisp_flow_style"})
		gui3.add({type = "label", name = "lab_lfix", caption = "", "default", style = "smadisp_label_style"})
		gui3.add({type = "button", name = "but_lfix_dec", caption = "-", style = "smadisp_button_style"})
		gui3.add({type = "button", name = "but_lfix_inc", caption = "+", style = "smadisp_button_style"})	
		gui3.add({type = "button", name = "but_lfix_reset", caption = "X", style = "smadisp_button_style"})	

		gui3 = guif2.add({type = "flow", name = "flow_form1", direction = "horizontal", style = "smadisp_flow_style"})
		gui3.add({type = "checkbox", name = "chk_lead", caption = {"gui-smadisp-lead"}, state = false, style = "checkbox"})
		gui3.add({type = "checkbox", name = "chk_thousands", caption = {"gui-smadisp-thousands"}, state = false, style = "checkbox"})

		gui3 = guif2.add({type = "flow", name = "flow_form2", direction = "horizontal", style = "smadisp_flow_style"})
		gui3.add({type = "checkbox", name = "chk_kilo", caption = "k(ilo)", state = false, style = "checkbox"})
		gui3.add({type = "checkbox", name = "chk_mega", caption = "M(ega)", state = false, style = "checkbox"})
		gui3.add({type = "checkbox", name = "chk_giga", caption = "G(iga)", state = false, style = "checkbox"})
		gui3.add({type = "checkbox", name = "chk_tera", caption = "T(era)", state = false, style = "checkbox"})

		gui3 = guif2.add({type = "flow", name = "flow_map", direction = "horizontal", style = "smadisp_flow_style"})
		gui3.add({type = "label", name = "label_map", caption = {"gui-smadisp-map"}, style = "smadisp_label_style"})
		gui3.add({type = "checkbox", name = "chk_map", caption = "", state = false, style = "checkbox"})

		-- gui3 = guif2.add({type = "flow", name = "flow_action", direction = "horizontal", style = "smadisp_flow_style"})
		-- gui3.add({type = "button", name = "but_update", caption = {"gui-smadisp-update"}, style = "smadisp_button_style"})
	end
	
	return(gui1)
end

--------------------------------------------------------------------------------------
local function update_gui_display( guif, display )
	guif.caption = {"gui-smadisp-frame", display.n_display}

	guif.flow_smadisp.flow_prefix.textfield_prefix.text = display.prefix
	guif.flow_smadisp.flow_suffix.textfield_suffix.text = display.suffix
	
	guif.flow_smadisp.flow_scale.lab_scale.caption = {"gui-smadisp-scale" , font_scales[display.font_scale_index] }
	
	local align_s
	if display.align == aligns.left then
		align_s = "gui-smadisp-align-left"
	elseif display.align == aligns.center then
		align_s = "gui-smadisp-align-center"
	else
		align_s = "gui-smadisp-align-right"
	end
	
	if display.divisor == 1e3 then
		guif.flow_smadisp.flow_form2.chk_kilo.state = true
	elseif display.divisor == 1e6 then
		guif.flow_smadisp.flow_form2.chk_mega.state = true
	elseif display.divisor == 1e9 then
		guif.flow_smadisp.flow_form2.chk_giga.state = true
	elseif display.divisor == 1e12 then
		guif.flow_smadisp.flow_form2.chk_tera.state = true
	end
	
	guif.flow_smadisp.flow_align.lab_align.caption = {align_s}
	
	guif.flow_smadisp.flow_lfix.lab_lfix.caption = {"gui-smadisp-lfix" , display.lfix }	

	guif.flow_smadisp.flow_form1.chk_lead.state = display.leading_zeros
	
	guif.flow_smadisp.flow_form1.chk_thousands.state = display.thousands
	
	guif.flow_smadisp.flow_map.chk_map.state = iif(display.mapmark == nil, false, true)
end

--------------------------------------------------------------------------------------
local function init_globals()
	-- initialize or update general globals of the mod
	debug_print( "init_globals " )

	global.ticks = global.ticks or 0
	global.n_display = global.n_display or 0
	global.smart_displays = global.smart_displays or {}
	global.player_cur_display = global.player_cur_display or {}
	
	global.refresh_max = global.refresh_max or 3
	global.refresh_n = global.refresh_n or 0
	if global.radar_enabled == nil then global.radar_enabled = radar_enabled end
end

--------------------------------------------------------------------------------------
local function init_player(player)
	if global.ticks == nil then return end
	
	-- initialize or update per player globals of the mod, and reset the gui
	debug_print( "init_player ", player.name, " connected=", player.connected )
	
	global.player_cur_display[player.index] = global.player_cur_display[player.index] or {}
end

--------------------------------------------------------------------------------------
local function init_players()
	for _, player in pairs(game.players) do
		init_player(player)
	end
end

--------------------------------------------------------------------------------------
local function on_init() 
	-- called once, the first time the mod is loaded on a game (new or existing game)
	debug_print( "on_init" )
	init_globals()
	init_players()
end

script.on_init(on_init)

--------------------------------------------------------------------------------------
local function on_configuration_changed(data)
	-- detect any mod or game version change
	if data.mod_changes ~= nil then
		local changes = data.mod_changes[debug_mod_name]
		if changes ~= nil then
			debug_print( "update mod: ", debug_mod_name, " ", tostring(changes.old_version), " to ", tostring(changes.new_version) )
		
			init_globals()
			init_players()

			if changes.old_version then
				if older_version(changes.old_version, "1.0.5") then
					for _, display in pairs(global.smart_displays) do
						display.thousands = display.thousands or false
						display.divisor = display.divisor or 1
					end
				end
				if older_version(changes.old_version, "1.0.7") then
					if radar_enabled then
						for _, display in pairs(global.smart_displays) do
							if display.mapmark ~= nil then
								local ent = display.entity
								display.radar = ent.surface.create_entity({name = "smart-display-radar", force = ent.force, position = ent.position})
							end
						end
					end
				end
				if older_version(changes.old_version, "1.0.13") then
					message_all("Smart Display :  now displays the sum of red and green networks signals if available.")
				end
			end
		end
	end
end

script.on_configuration_changed(on_configuration_changed)

--------------------------------------------------------------------------------------
local function on_player_created(event)
	-- called at player creation
	local player = game.players[event.player_index]
	debug_print( "player created ", player.name )
	
	init_player(player)
end

script.on_event(defines.events.on_player_created, on_player_created )

--------------------------------------------------------------------------------------
local function on_player_joined_game(event)
	-- called in SP(once) and MP(every connect), eventually after on_player_created
	local player = game.players[event.player_index]
	debug_print( "player joined ", player.name )
	
	init_player(player)
end

script.on_event(defines.events.on_player_joined_game, on_player_joined_game )

--------------------------------------------------------------------------------------
local function on_creation( event )
	local ent = event.created_entity
	local player_index = event.player_index
	
	if ent.name == "smart-display-visible" then
		-- debug_print( "smart-display created" )
		
		local pos = ent.position
		local force = ent.force
		local surf = ent.surface
		if ent and ent.valid then ent.destroy() end
		
		ent = surf.create_entity({name = "smart-display", force = force, position = pos})
		
		local display =
		{
			entity = ent,
			mapmark = nil,
			radar = nil,
			decos = {},
			last_s = "",
			last_v = 9999999999999.9,
			n_display = global.n_display,
			font = "arial", -- variables reserved for further developments
			font_scale_index = 2,
			color_bg = "black",
			prefix = "",
			suffix = "",
			align = aligns.left, 
			precision = 0,
			lfix = 0, -- 0 if length adapt to content, otherwise fixed
			leading_zeros = false,
			color = nil,
			thousands = false,
			divisor = 1,
		}
		
		table.insert( global.smart_displays, display )
		
		global.n_display = global.n_display + 1
	end
end

script.on_event(defines.events.on_built_entity, on_creation )
script.on_event(defines.events.on_robot_built_entity, on_creation )

--------------------------------------------------------------------------------------
local function on_destruction( event )
	local ent = event.entity
	
	if ent.name == "smart-display" then
		-- debug_print( "smart-display destroyed" )
		
		for k, display in ipairs(global.smart_displays) do	
			if display.entity == ent then
				for _, deco in ipairs(display.decos) do
					if deco and deco.valid then
						deco.destroy()
					end
				end
				if display.mapmark and display.mapmark.valid then
					display.mapmark.destroy()
				end
				if display.radar and display.radar.valid then
					display.radar.destroy()
				end
				table.remove(global.smart_displays,k)
				break
			end
		end
	end
end

script.on_event(defines.events.on_entity_died, on_destruction )
script.on_event(defines.events.on_robot_pre_mined, on_destruction )
script.on_event(defines.events.on_pre_player_mined_item, on_destruction )

--------------------------------------------------------------------------------------
local function on_entity_settings_pasted(event)
	local ent1 = event.source
	local ent2 = event.destination
	
	if ent1.name == "smart-display" and ent2.name == "smart-display" then
		local display1 = find_display(ent1)
		local display2 = find_display(ent2)
		
		if display1.mapmark then
			if display2.mapmark == nil then
				add_mapmark(display2)
				if global.radar_enabled then add_radar(display2) end
			end
		else
			if display2.mapmark and display2.mapmark.valid then display2.mapmark.destroy() end
			if display2.radar and display2.radar.valid then display2.radar.destroy() end
			display2.mapmark = nil
			display2.radar = nil
		end
		
		display2.last_v = 9999999999.9
		display2.font = display1.font
		display2.font_scale_index = display1.font_scale_index
		display2.color_bg = display1.color_bg
		display2.prefix = display1.prefix
		display2.suffix = display1.suffix
		display2.align = display1.align
		display2.precision = display1.precision
		display2.lfix = display1.lfix
		display2.leading_zeros = display1.leading_zeros
		display2.thousands = display1.thousands
		display2.divisor = display1.divisor
		
		update_display(display2,true)
	end
end

script.on_event(defines.events.on_entity_settings_pasted,on_entity_settings_pasted)

--------------------------------------------------------------------------------------
local function on_tick(event)
	if global.ticks == 0 then
		global.ticks = 16
		
		if #global.smart_displays > 0 then	
			-- update displays
			if global.refresh_n == 0 then 
				global.refresh_n = global.refresh_max
				for _, display in ipairs(global.smart_displays) do	
					update_display( display, false )
				end
			end
			global.refresh_n = global.refresh_n - 1

			-- look for an opened display interface
			for _, player in pairs(game.players) do
				if player.connected then
					local opened = player.opened
					local close_previous = true
					local open_new = false
					local display = global.player_cur_display[player.index]
					
					if opened and opened.valid then
						-- there is an opened gui
						if opened.name == "smart-display" then
							-- player has an open smartdisplay : open the gui
							open_new = true

							if display and display.entity == opened then
								-- do not reopen the gui if same display
								close_previous = false
								open_new = false
							end
						end
					end
					
					if close_previous and display then 
						local guif = player.gui.left.frame_smadisp
						if guif ~= nil then guif.destroy() end
						global.player_cur_display[player.index] = nil
					end

					if open_new then
						-- open new smartdisplay
						display = find_display( opened )
						
						if display ~= nil then
							-- debug_print( "display opened " .. display.n_display )
							global.player_cur_display[player.index] = display
							local guif = show_menu_display( player, display )
							update_gui_display( guif, display )
						end
					end
				end
			end
		end
	else
		global.ticks = global.ticks - 1
	end
end

script.on_event(defines.events.on_tick, on_tick)

--------------------------------------------------------------------------------------
local function on_gui_text_changed(event)
	--debug_print( "player click: " , event.player_index )
	local player = game.players[event.player_index]
	local display = global.player_cur_display[event.player_index]
	local guif = player.gui.left.frame_smadisp
	
	if display ~= nil and guif ~= nil then	
		local refresh = false
		
		if event.element.name == "textfield_prefix" then
			display.prefix = guif.flow_smadisp.flow_prefix.textfield_prefix.text
			refresh = true
		elseif event.element.name == "textfield_suffix" then
			display.suffix = guif.flow_smadisp.flow_suffix.textfield_suffix.text
			refresh = true
		end
		
		if refresh then
			update_gui_display( guif, display )
		end
	end
end

script.on_event(defines.events.on_gui_text_changed,on_gui_text_changed)

--------------------------------------------------------------------------------------
local function on_gui_click(event)
	--debug_print( "player click: " , event.player_index )
	local player = game.players[event.player_index]
	
	if player ~= nil then
		local display = global.player_cur_display[event.player_index]
		local guif = player.gui.left.frame_smadisp
		
		if display ~= nil and guif ~= nil then		
			-- display.prefix = guif.flow_smadisp.flow_prefix.textfield_prefix.text
			-- display.suffix = guif.flow_smadisp.flow_suffix.textfield_suffix.text
			
			if event.element.name == "but_scale_dec" then
				if display.font_scale_index > 1 then display.font_scale_index = display.font_scale_index - 1 end
				
			elseif event.element.name == "but_scale_inc" then
				if display.font_scale_index < #font_scales then display.font_scale_index = display.font_scale_index + 1 end
				
			elseif event.element.name == "but_align_dec" then
				if display.align > aligns.left then 
					display.align = display.align - 1 
				else
					display.align = aligns.right 
				end
				
			elseif event.element.name == "but_align_inc" then
				if display.align < aligns.right then 
					display.align = display.align + 1 
				else
					display.align = aligns.left 
				end
				
			elseif event.element.name == "but_lfix_dec" then
				if display.lfix > 0 then display.lfix = display.lfix - 1 end
				
			elseif event.element.name == "but_lfix_inc" then
				if display.lfix < 20 then display.lfix = display.lfix + 1 end
				
			elseif event.element.name == "but_lfix_reset" then
				display.lfix = 0
				
			elseif event.element.name == "chk_lead" then
				display.leading_zeros = guif.flow_smadisp.flow_form1.chk_lead.state
				
			elseif event.element.name == "chk_thousands" then
				display.thousands = guif.flow_smadisp.flow_form1.chk_thousands.state
				
			elseif event.element.name == "chk_kilo" then
				display.divisor = set_chk_divisor(guif.flow_smadisp.flow_form2, event.element)
				
			elseif event.element.name == "chk_mega" then
				display.divisor = set_chk_divisor(guif.flow_smadisp.flow_form2, event.element)
				
			elseif event.element.name == "chk_giga" then
				display.divisor = set_chk_divisor(guif.flow_smadisp.flow_form2, event.element)
				
			elseif event.element.name == "chk_tera" then
				display.divisor = set_chk_divisor(guif.flow_smadisp.flow_form2, event.element)
				
			elseif event.element.name == "chk_map" then
				if guif.flow_smadisp.flow_map.chk_map.state then
					add_mapmark(display)
					if global.radar_enabled then add_radar(display) end
					update_display(display)
				else
					if display.mapmark and display.mapmark.valid then display.mapmark.destroy() end
					if display.radar and display.radar.valid then display.radar.destroy() end
					display.mapmark = nil
					display.radar = nil
				end
				
			elseif event.element.name == "textfield_prefix" then
				debug_print("textfield_prefix")
				
			elseif event.element.name == "textfield_suffix" then
				debug_print("textfield_suffix")
			end
			
			update_gui_display( guif, display )
		end
	end
end

script.on_event(defines.events.on_gui_click,on_gui_click)



--------------------------------------------------------------------------------------

local interface = {}

function interface.reset()
	debug_print( "reset" )
	
	init_globals()
end

function interface.refresh( t )
	debug_print( "refresh" )
	
	t = tonumber(t)
	
	if t and t >= 1 then global.refresh_max = math.floor(t) end
end

function interface.mapmark( on_or_off )
	debug_print( "mapmark" )
	
	if on_or_off then
		for _, display in pairs(global.smart_displays) do
			if display.mapmark == nil then
				add_mapmark(display)
				if global.radar_enabled then add_radar(display) end
				update_display(display)
			end
		end
	else
		for _, display in pairs(global.smart_displays) do
			if display.mapmark and display.mapmark.valid then
				display.mapmark.destroy()
				display.mapmark = nil
			end
			if display.radar and display.radar.valid then
				display.radar.destroy()
				display.radar = nil
			end
		end
	end
end

function interface.radar( on_or_off )
	debug_print( "radar" )
	
	global.radar_enabled = (on_or_off == true)
	
	if global.radar_enabled then
		for _, display in pairs(global.smart_displays) do
			if display.mapmark ~= nil then
				add_radar(display)
			end
		end
	else
		for _, display in pairs(global.smart_displays) do
			if display.radar and display.radar.valid then
				display.radar.destroy()
				display.radar = nil
			end
		end
	end
end

remote.add_interface( "smartdisplay", interface )

-- /c remote.call( "smartdisplay", "reset" )
-- /c remote.call( "smartdisplay", "refresh", 6 )
-- /c remote.call( "smartdisplay", "mapmark", false )
-- /c remote.call( "smartdisplay", "radar", false )
