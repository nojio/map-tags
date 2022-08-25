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

  -- CREATE GUIS

  gui.add(mod_gui.get_button_flow(player), {
    type = "button",
    style = mod_gui.button_style,
    caption = "Tag List",
    actions = {
      on_click = "toggle_chart_tag_list_gui"
    }
  })

  chart_tag_list_gui.build(player, player_table)
end)

local function toggle_chart_tag_list_gui(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local visible = player_table.chart_tag_list.refs.window.visible
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

if script.active_mods["gvv"] then require("__gvv__.gvv")() end
