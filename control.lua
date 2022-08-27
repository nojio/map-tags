local event = require("__flib__.event")
local gui = require("__flib__.gui")
local mod_gui = require("__core__.lualib.mod-gui")

local chart_tag_list_gui = require("chart_tag_list_gui")

-- ACTION HANDLERS

chart_tag_list_gui.actions = {
  close = chart_tag_list_gui.close
}

-- ---------------------------------------------------------------------------------------------------------------------
-- EVENT HANDLERS

event.on_init(function()
  global.players = {}
end)

event.on_player_created(function(e)
  -- Create player table
  global.players[e.player_index] = {}
  local player_table = global.players[e.player_index]

  local player = game.get_player(e.player_index)

  chart_tag_list_gui.build(player, player_table)
end)

local function toggle_chart_tag_list_gui(e)
  local player = game.get_player(e.player_index)

  -- when a save file is loaded that previously didn't contain the mod
  if not global.players[e.player_index] then
    global.players[e.player_index] = {}
  end

  local player_table = global.players[e.player_index]

  local visible = false
  if player_table.map_tags then
    visible = player_table.map_tags.refs.window.visible
  end

  if visible then
    chart_tag_list_gui.close(e)
  else
    chart_tag_list_gui.build(player, player_table)
    chart_tag_list_gui.open(e)
  end
end

gui.hook_events(function(e)
  local action = gui.read_action(e)
  if action then
    if action == "toggle_chart_tag_list_gui" then
      toggle_chart_tag_list_gui(e)
    elseif action.action and action.action == "zoom_position" then
      local player = game.players[e.player_index]
      player.zoom_to_world(action.position, 0.5)
    else
      chart_tag_list_gui.actions[action](e)
    end
  end
end)

-- Keyboard shortcuts
script.on_event("map_tags_toggle_gui", function(e)
  toggle_chart_tag_list_gui(e)
end)

-- Buttom Bar Shortcuts Clicked
script.on_event(defines.events.on_lua_shortcut, function(e)
  if e.prototype_name == "map_tags_shorcut" then
    toggle_chart_tag_list_gui(e)
  end
end)

if script.active_mods["gvv"] then require("__gvv__.gvv")() end
