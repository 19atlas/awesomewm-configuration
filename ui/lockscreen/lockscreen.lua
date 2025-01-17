local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")

local helpers = require("helpers")
local color_helpers = require("helpers.color-helpers")

local lock_screen = require("ui.lockscreen")

local lock_screen_box = function(s)
    return wibox {
        visible = false,
        ontop = true,
        type = "splash",
        screen = s,
        bg = beautiful.black .. "42"
    }
end

-- Vars
local char =
    "I T L I S A S A M P M A C Q U A R T E R D C T W E N T Y F I V E X H A L F S T E N F T O P A S T E R U N I N E O N E S I X T H R E E F O U R F I V E T W O E I G H T E L E V E N S E V E N T W E L V E T E N S E O C L O C K"

local pos_map = {
    ["it"] = {1, 2},
    ["is"] = {4, 5},
    ["a"] = {12, 12},
    ["quarter"] = {14, 20},
    ["twenty"] = {23, 28},
    ["five"] = {29, 32},
    ["half"] = {34, 37},
    ["ten"] = {39, 41},
    ["past"] = {45, 48},
    ["to"] = {43, 44},
    ["1"] = {56, 58},
    ["2"] = {75, 77},
    ["3"] = {62, 66},
    ["4"] = {67, 70},
    ["5"] = {71, 74},
    ["6"] = {59, 61},
    ["7"] = {89, 93},
    ["8"] = {78, 82},
    ["9"] = {52, 55},
    ["10"] = {100, 102},
    ["11"] = {83, 88},
    ["12"] = {94, 99},
    ["oclock"] = {105, 110}
}

local char_map = {
    ["it"] = {},
    ["is"] = {},
    ["a"] = {},
    ["quarter"] = {},
    ["twenty"] = {},
    ["five"] = {},
    ["half"] = {},
    ["ten"] = {},
    ["past"] = {},
    ["to"] = {},
    ["1"] = {},
    ["2"] = {},
    ["3"] = {},
    ["4"] = {},
    ["5"] = {},
    ["6"] = {},
    ["7"] = {},
    ["8"] = {},
    ["9"] = {},
    ["10"] = {},
    ["11"] = {},
    ["12"] = {},
    ["oclock"] = {}
}

local reset_map = {
    4, 12, 14, 23, 29, 34, 39, 43, 45, 52, 56, 59, 62, 67, 71, 75, 78, 83, 89, 94, 100, 105
}

local function split_str(s, delimiter)
    result = {};
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end

    return result;
end

local time_char = split_str(char, " ")

-- Helpers

local time = wibox.widget {
    forced_num_cols = 11,
    spacing = beautiful.useless_gap,
    layout = wibox.layout.grid
}

local function create_text_widget(index, w)
    local text_widget = wibox.widget {
        id = "t" .. index,
        markup = w,
        font = beautiful.font_name .. " Bold 18",
        align = "center",
        valign = "center",
        forced_width = dpi(25),
        forced_height = dpi(30),
        widget = wibox.widget.textbox
    }

    time:add(text_widget)

    return text_widget
end

local var_count = 0
for i, char in pairs(time_char) do
    local text = color_helpers.colorize_text(char, beautiful.light_black .. "16")

    var_count = var_count + 1
    local create_dummy_text = true

    for j, k in pairs(pos_map) do
        if i >= pos_map[j][1] and i <= pos_map[j][2] then
            char_map[j][var_count] = create_text_widget(i, text)
            create_dummy_text = false
        end

        for _, n in pairs(reset_map) do
            if i == n then
                var_count = 1
            end
        end

    end

    if create_dummy_text then
        create_text_widget(i, text)
    end

end

local last_hour
local last_minute
local time_of_day_color

local function activate_word(w)
    for i, char in pairs(char_map[w]) do
        char.markup = color_helpers.colorize_text(char.text, time_of_day_color)
    end
end

local function deactivate_word(w)
    for i, char in pairs(char_map[w]) do
        char.markup = color_helpers.colorize_text(char.text, beautiful.light_black .. "16")
    end
end

local function reset_time()
    for j, k in pairs(char_map) do
        deactivate_word(j)
    end

    activate_word("it")
    activate_word("is")
end

gears.timer {
    timeout = 2,
    call_now = true,
    autostart = true,
    callback = function()
        local time = os.date('%I:%M')
        local h, m = time:match('(%d+):(%d+)')
        local hour = tonumber(h)
        local min = tonumber(m)

        if last_hour ~= hour then
            time_of_day_color = color_helpers.get_color_by_time_of_day()
            last_hour = hour
        end

        -- update if minute has changed
        if last_minute == min then
            return
        end
        last_minute = min

        for s in screen do
            if s.lockscreen then
                s.lockscreen:get_children_by_id("container")[1].border_color = time_of_day_color
            end
        end

        reset_time()

        if min >= 0 and min <= 2 or min >= 58 and min <= 59 then
            activate_word("oclock")
        elseif min >= 3 and min <= 7 or min >= 53 and min <= 57 then
            activate_word("five")
        elseif min >= 8 and min <= 12 or min >= 48 and min <= 52 then
            activate_word("ten")
        elseif min >= 13 and min <= 17 or min >= 43 and min <= 47 then
            activate_word("a")
            activate_word("quarter")
        elseif min >= 18 and min <= 22 or min >= 38 and min <= 42 then
            activate_word("twenty")
        elseif min >= 23 and min <= 27 or min >= 33 and min <= 37 then
            activate_word("twenty")
            activate_word("five")
        elseif min >= 28 and min <= 32 then
            activate_word("half")
        end

        if min >= 3 and min <= 32 then
            activate_word("past")
        elseif min >= 33 and min <= 57 then
            activate_word("to")
        end

        local hh

        if min >= 0 and min <= 30 then
            hh = hour
        else
            hh = hour + 1
        end

        if hh > 12 then
            hh = hh - 12
        end

        activate_word(tostring(hh))
    end
}

-- Lock animation
local lock_icon = "\u{e897}"
local password_icon = "\u{f042}"
local password_failed_icon = color_helpers.colorize_text(password_icon, beautiful.red)

local lock_animation_icon = wibox.widget {
    -- Set forced size to prevent flickering when the icon rotates
    forced_height = dpi(80),
    forced_width = dpi(80),
    markup = color_helpers.colorize_text(lock_icon, beautiful.light_black),
    font = beautiful.icon_font_name .. 24,
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local lock_animation_widget_rotate = wibox.container.rotate()

local arc = function(cr, width, height)
    gears.shape.arc(cr, width, height, dpi(5), 0, math.pi / 3, true, true)
end

local lock_animation_arc = wibox.widget {
    shape = arc,
    bg = "#00000000",
    forced_width = dpi(50),
    forced_height = dpi(50),
    widget = wibox.container.background
}

local lock_animation = {
    {
        lock_animation_arc,
        widget = lock_animation_widget_rotate
    },
    lock_animation_icon,
    layout = wibox.layout.stack
}

-- Lock helper functions
local characters_entered = 0
local function reset()
    characters_entered = 0;
    lock_animation_icon.markup = color_helpers.colorize_text(lock_icon, beautiful.light_black)
    lock_animation_widget_rotate.direction = "north"
    lock_animation_arc.bg = "#00000000"
end

local function fail()
    characters_entered = 0;
    lock_animation_icon.markup = password_failed_icon
    lock_animation_widget_rotate.direction = "north"
    lock_animation_arc.bg = "#00000000"
end

local animation_colors = { -- Rainbow sequence =)
    beautiful.red, beautiful.magenta, beautiful.accent, beautiful.cyan, beautiful.green,
    beautiful.yellow
}

local animation_directions = {"north", "west", "south", "east"}

-- Function that "animates" every key press
local function key_animation(char_inserted)
    local color
    local direction = animation_directions[(characters_entered % 4) + 1]
    if char_inserted then
        color = animation_colors[(characters_entered % 6) + 1]
        lock_animation_icon.markup = color_helpers.colorize_text(password_icon, beautiful.white)
    else
        if characters_entered == 0 then
            reset()
        else
            color = beautiful.white .. "55"
        end
    end

    lock_animation_arc.bg = color
    lock_animation_widget_rotate.direction = direction
end

local function set_visibility(visible)
    naughty.suspended = visible

    for s in screen do
        s.lockscreen.visible = visible
        s.lockscreen:get_children_by_id("container")[1].border_color = time_of_day_color
    end
end

-- Get input from user
local function grab_password()
    local function reset_input()
        reset()
        grab_password()
    end

    awful.prompt.run {
        hooks = {
            -- Do not cancel input with Escape or Ctrl+Del
            -- This will just clear any input received so far.
            {{}, 'Escape', reset_input},
            {{'Control'}, 'Delete', reset_input},

            -- Prevent Awesomewm restarting
            {{'Control', 'Mod4'}, 'r', reset_input}
        },
        keypressed_callback = function(mod, key, cmd)
            -- Only count single character keys (thus preventing
            -- "Shift", "Escape", etc from triggering the animation)
            if #key == 1 then
                characters_entered = characters_entered + 1
                key_animation(true)
            elseif key == "BackSpace" then
                if characters_entered > 0 then
                    characters_entered = characters_entered - 1
                end
                key_animation(false)
            end
        end,
        exe_callback = function(input)
            -- Check input
            if lock_screen.authenticate(input) then
                reset()
                set_visibility(false)
            else
                fail()
                grab_password()
            end
        end,
        textbox = wibox.widget.textbox()
    }
end

function lock_screen_show()
    set_visibility(true)
    grab_password()
end

-- Add lockscreen to each screen
awful.screen.connect_for_each_screen(
    function(s)
        s.lockscreen = lock_screen_box(s)
        s.lockscreen:setup{
            {
                {
                    {
                        time,
                        lock_animation,
                        spacing = dpi(40),
                        layout = wibox.layout.fixed.vertical
                    },
                    margins = dpi(64),
                    widget = wibox.container.margin
                },
                id = "container",
                shape = helpers.rrect(beautiful.border_radius),
                bg = beautiful.xbackground,
                border_color = beautiful.focus,
                border_width = dpi(2),
                widget = wibox.container.background
            },
            widget = wibox.container.place
        }

        awful.placement.maximize(s.lockscreen)
    end
)
