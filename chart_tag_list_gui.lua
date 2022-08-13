local gui = require("__flib__.gui")
-- local mod_gui = require("__core__.lualib.mod-gui")
-- local table = require("__flib__.table")

-- ---------------------------------------------------------------------------------------------------------------------
-- GUI CODE

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
  for _, tag in pairs(chart_tags[1]) do
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
    table.insert(records, { type = "label", caption = tag.last_user.name })
    table.insert(records, { type = "label", caption = tag.surface.name })
    table.insert(records, { type = "label", caption = tag.tag_number })
  end

  return records
end


function chart_tag_list_gui.build(player, player_table)
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      direction = "vertical",
      ref = {"window"},
      actions = {
        on_closed = "close"
      },
      {type = "flow", ref = {"titlebar_flow"}, children = {
        {type ="label", style = "frame_title", caption = "Tags", ignored_by_interaction = true},
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
        -- {
        --   type = "flow",
        --   style_mods = {left_margin = 12, right_margin = 12, bottom_margin = 12},
        --   direction = "vertical",
        --   -- elem_mods = {visible = false},
        --   elem_mods = {visible = true},
        --   ref = {"chart_tags_flow"},
        -- },
        {
            type = "scroll-pane",
            style = "flib_naked_scroll_pane_no_padding",
            ref = { "scroll_pane" },
            vertical_scroll_policy = "always",
            style_mods = {width = 300, height = 400, padding = 6},
            children = {
                {
                    type = "flow",
                    direction = "vertical",
                    children = {
                      {
                        type = "label",
                        caption = "this is label"
                      },
                      {
                        type = "table",
                        column_count = 5,
                        children = create_content()
                      },
                    }
                }
            }
        },
        {
          type = "frame",
          style = "subfooter_frame",
          -- elem_mods = {visible = false},
          elem_mods = {visible = true},
          ref = {"subfooter_frame"},
          {
            type = "flow",
            style_mods = {vertical_align = "center", left_margin = 8},
            ref = {"subfooter_flow"},
            {type = "label", name = "items_left_label", caption = "footer a"},
            {type = "empty-widget", style = "flib_horizontal_pusher"},
          }
        }
      }
    }
  })

  refs.subfooter_flow.items_left_label.caption = "hoge items left hogehogehoge"

  refs.titlebar_flow.drag_target = refs.window
  refs.window.force_auto_center()
  player.opened = refs.window

  player_table.chart_tag_list = {
    refs = refs,
    state = {
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
