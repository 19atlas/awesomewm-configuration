local gfs = require("gears.filesystem")
local dir = gfs.get_configuration_dir() .. "ui/icons/"

return {
    notification = dir .. "notification.svg",
    notification_bell = dir .. "notification_bell.svg",
    ram = dir .. "ram.svg",
    cpu = dir .. "cpu.svg",
    gpu = dir .. "gpu.svg",
    window = dir .. "window.svg"
}
