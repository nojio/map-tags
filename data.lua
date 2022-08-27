data:extend({
  {
    type = "shortcut",
    name = "map_tags_shorcut",
    icon = {
      filename = "__map-tags__/graphics/shortcut_icon_black_32.png",
      priority = "extra-high-no-scale",
      size = 32,
      scale = 1,
      flags = {"icon"}
    },
    disabled_icon = {
      filename = "__map-tags__/graphics/shortcut_icon_white_32.png",
      priority = "extra-high-no-scale",
      size = 32,
      scale = 1,
      flags = {"icon"}
    },
    small_icon = {
      filename = "__map-tags__/graphics/shortcut_icon_black_24.png",
      priority = "extra-high-no-scale",
      size = 24,
      scale = 1,
      flags = {"icon"}
    },
    disabled_small_icon = {
      filename = "__map-tags__/graphics/shortcut_icon_white_24.png",
      priority = "extra-high-no-scale",
      size = 24,
      scale = 1,
      flags = {"icon"}
    },
    associated_control_input = "map_tags_toggle_gui",
    toggleable = true,
    action = "lua"
  }
})

data:extend({
  {
    type = "custom-input",
    name = "map_tags_toggle_gui",
    key_sequence = "CONTROL + ALT + T",
    -- consuming = "game-only",
    order = "a"
  }
})
