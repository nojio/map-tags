require("scripts/util")

local gui = require("__flib__.gui")
local tablex = require("__flib__.table")

local chart_tag_list_gui = {}

local sort_modes = tablex.invert{
  "alphabetically",
  "recently_added"
}

function Update_mode_radios(gui_data)
  local mode = gui_data.state.mode
  local subfooter_flow = gui_data.refs.subfooter_flow

  subfooter_flow.alphabetically_radiobutton.state = mode == sort_modes.alphabetically
  subfooter_flow.recently_added_radiobutton.state = mode == sort_modes.recently_added
end

local function find_all_chart_tags()
    local chart_tags = {}
    for _, force in pairs(game.forces) do
        for _, surface in pairs(game.surfaces) do
            table.insert(chart_tags, force.find_chart_tags(surface))
        end
    end
    return chart_tags
end

local function create_content(compact_list, sort_mode)
  local records = {}

  local chart_tags = find_all_chart_tags()
  -- TODO: ???
  chart_tags = chart_tags[1]

  if sort_mode and sort_mode == sort_modes.alphabetically then
    table.sort(chart_tags, Comp_alphabetically)
  else
    table.sort(chart_tags, Comp_tag_number)
  end

  for _, tag in pairs(chart_tags) do
    local sprite = nil
    if tag.icon then
      sprite = tag.icon.type .. "/" .. tag.icon.name
    end

    table.insert(records,
      {
        type = "sprite-button",
        sprite = sprite,
        actions = {
            on_click = { action = "zoom_position", position = tag.position }
        }
      }
    )
    if not compact_list then
      table.insert(records, { type = "label", caption = tag.text })
      -- table.insert(records, { type = "label", caption = tag.last_user.name })
      -- table.insert(records, { type = "label", caption = tag.surface.name })
      -- table.insert(records, { type = "label", caption = tag.tag_number })
    end
  end

  return records
end


function chart_tag_list_gui.build(player, player_table)
  local width = settings.get_player_settings(player)["map_tags_width"].value
  local height = settings.get_player_settings(player)["map_tags_height"].value
  local compact_list = settings.get_player_settings(player)["map_tags_compact_list"].value

  local sort_mode = {}
  if player_table and player_table.chart_tag_list then
    sort_mode = player_table.chart_tag_list.state.mode
  end

  local tag_contents = create_content(compact_list, sort_mode)

  local column_count = 2
  local padding = 10
  if compact_list then
    width = 90
    column_count = 1
    padding = 25
  end

  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      direction = "vertical",
      ref = {"window"},
      actions = {
        on_closed = "close"
      },
      {type = "flow", ref = {"titlebar_flow"}, children = {
        {type ="label", style = "frame_title", caption = {"map_tags.title"}, ignored_by_interaction = true},
        {type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true},
        {
          type = "sprite-button",
          style = "frame_action_button",
          sprite = "utility/close_white",
          hovered_sprite = "utility/close_black",
          clicked_sprite = "utility/close_black",
          mouse_button_filter = {"left"},
          actions = {
            on_click = "close"
          }
        }
      }},
      {type = "frame", style = "inside_shallow_frame", direction = "vertical",
        {
            type = "scroll-pane",
            style = "flib_naked_scroll_pane_no_padding",
            ref = { "scroll_pane" },
            vertical_scroll_policy = "auto",
            style_mods = {width = width, height = height, padding = padding},
            children = {
              {
                type = "flow",
                direction = "vertical",
                children = {
                  {
                    type = "table",
                    column_count = column_count,
                    children = tag_contents
                  }
                }
              }
            }
        },
        {
          type = "frame",
          style = "subfooter_frame",
          {
            type = "flow",
            direction = "vertical",
            style_mods = {vertical_align = "center", left_margin = 8},
            ref = {"subfooter_flow"},
            children = {
            {
              type = "radiobutton",
              name = "alphabetically_radiobutton",
              caption = "Alphabetically",
              state = true,
              actions = {
                on_checked_state_changed = "change_mode"
              },
              tags = {mode = sort_modes.alphabetically},
              {type = "empty-widget", style = "flib_horizontal_pusher"},
            },
            {
              type = "radiobutton",
              name = "recently_added_radiobutton",
              caption = "Recently added",
              state = false,
              actions = {
                on_checked_state_changed = "change_mode"
              },
              tags = {mode = sort_modes.recently_added},
              {type = "empty-widget", style = "flib_horizontal_pusher"},
            },
            }
          }
        }
      }
    }
  })

  -- refs.subfooter_flow.items_left_label.caption = "hoge items left hogehogehoge"

  refs.titlebar_flow.drag_target = refs.window
  refs.window.force_auto_center()
  player.opened = refs.window

  if not sort_mode then
    sort_mode = sort_modes.alphabetically
  end

  player_table.chart_tag_list = {
    refs = refs,
    state = {
      mode = sort_mode,
      chart_tags = {},
      visible = false
    }
  }
end

function chart_tag_list_gui.open(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.chart_tag_list

  gui_data.refs.window.visible = true
  player.opened = gui_data.refs.window
end

function chart_tag_list_gui.close(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.chart_tag_list

  gui_data.refs.window.visible = false
  if player and player.opened then
    player.opened = nil
  end
end

return chart_tag_list_gui
