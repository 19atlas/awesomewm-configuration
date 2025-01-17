local spawn = require("awful.spawn")
local beautiful = require("beautiful")
local wibox_container = require("wibox.container")
local wibox_widget = require("wibox.widget")

local monitor_progressbar = require("ui.widgets.monitor-progressbar")
local text_icon = require("ui.widgets.text-icon")

local function change_asus_fan_profile(temp)
    if temp < 85 then
        return
    end
    spawn.easy_async(
        "asusctl profile -p", function(stdout)
            if stdout:match("Quiet") then
                spawn("asusctl profile -P Balanced")
            end
        end
    )
end

local meter_icon = text_icon {
    text = "\u{e1ff}"
}

local function format_info(stdout)
    local temp = stdout:match("%d+") / 1000
    change_asus_fan_profile(temp)

    return temp, string.format("%.1f °", temp)
end

local cpu_temperature = monitor_progressbar {
    name = "CPU",
    icon_widget = meter_icon,
    info = "1 °",
    min_value = Z0,
    max_value = 100,
    slider_color = {
        type = "linear",
        from = {0},
        to = {240},
        stops = {{0, beautiful.yellow}, {0.8, beautiful.red}}
    },
    bg_color = beautiful.red .. "60",
    watch_command = "cat /sys/class/thermal/thermal_zone0/temp",
    format_info = format_info,
    interval = 5
}

return cpu_temperature
