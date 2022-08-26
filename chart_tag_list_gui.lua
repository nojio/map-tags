require("scripts/util")

local gui = require("__flib__.gui")

local chart_tag_list_gui = {}

local function find_all_chart_tags()
    local chart_tags = {}
    for _, force in pairs(game.forces) do
        for _, surface in pairs(game.surfaces) do
            table.insert(chart_tags, force.find_chart_tags(surface))
        end
    end
    return chart_tags
end

local function create_content()
  local records = {}

  local chart_tags = find_all_chart_tags()

  chart_tags = chart_tags[1]
  table.sort(chart_tags, Comp_alphabetically)

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

    table.insert(records, { type = "label", caption = tag.text })
    -- table.insert(records, { type = "label", caption = tag.last_user.name })
    -- table.insert(records, { type = "label", caption = tag.surface.name })
    -- table.insert(records, { type = "label", caption = tag.tag_number })
  end

  return records
end

function chart_tag_list_gui.build(player, player_table)
  local width = settings.get_player_settings(player)["map_tags_width"].value
  local height = settings.get_player_settings(player)["map_tags_height"].value

  local tag_contents = create_content()

  local column_count = 2
  local padding = 10

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
        }
      }
    }
  })

  -- refs.subfooter_flow.items_left_label.caption = "hoge items left hogehogehoge"

  refs.titlebar_flow.drag_target = refs.window
  refs.window.force_auto_center()
  player.opened = refs.window

  player_table.map_tags = {
    refs = refs
  }
end

function chart_tag_list_gui.open(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.map_tags

  gui_data.refs.window.visible = true
  player.opened = gui_data.refs.window
end

function chart_tag_list_gui.close(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.map_tags

  gui_data.refs.window.visible = false
  if player and player.opened then
    player.opened = nil
  end
end

return chart_tag_list_gui
