-- kmawesome: My configuration of awesome window manager
-- Copyright (c) 2012-2018 Kazuki Maeda <kmaeda@kmaeda.net>

local awful = require('awful')
awful.rules = require('awful.rules')
require('awful.autofocus')
local beautiful = require('beautiful')
local naughty = require('naughty')
local wibox = require('wibox')
local gears = require('gears')

-- http://git.sysphere.org/vicious/
local vicious = require('vicious')

local kmawesome = {}
kmawesome.layout = {}
kmawesome.widget = {}
kmawesome.layout.split = require('kmawesome.layout.split')
kmawesome.widget.tasklist = require('kmawesome.widget.tasklist')

local modkey = 'Mod4'
local shiftkey = 'Shift'
local controlkey = 'Control'

local terminal = 'st -e tmux'
local editor = 'sh -c "XMODIFIERS=@im=none emacs"'
local webbrowser = 'sh -c "LANG=ja_JP.UTF-8 firefox"'
local mua = 'sh -c "LANG=ja_JP.UTF-8 sylpheed"'
local musicplayer = 'sh -c "LANG=ja_JP.UTF-8 audacious"'
local xsetb = 'xset -b'
local xsetr = 'xset r rate 250 25'
local xmodmap = 'xmodmap /home/kmaeda/.Xmodmap'
local xcompmgr = 'xcompmgr'
local hsetroot = 'hsetroot -solid #000000'
local xscreensaver = 'xscreensaver -no-splash'
local ibus = 'ibus-daemon --xim'
local nmapplet = 'sh -c "pgrep nm-applet || nm-applet"'
local polkitgnome = '/usr/libexec/polkit-gnome-authentication-agent-1'
local alsasetup = 'sh -c "~/alsasetup.py > ~/.asoundrc"'
local sleepcommand = "sh -c 'echo mem > /sys/power/state || echo standby > /sys/power/state'"


if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

beautiful.init('/home/kmaeda/.config/awesome/kmawesome/theme.lua')

local layouts = {
   kmawesome.layout.split.v,
   kmawesome.layout.split.h,
   awful.layout.suit.max.fullscreen
}

local tags = awful.tag({'Editor', 'Web', 'Mail', 'Music', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'}, s, layouts[1])

tags[1]:view_only()
beautiful.master_count = 1

for i = 2, 14 do
   tags[i].master_count = 0
end

local function setemacsatmaster()
   if tags[1]:clients()[1] and awful.client.getmaster() then
      tags[1]:clients()[1]:swap(awful.client.getmaster())
   end
end

local function launchprogram(program, tagnum)
   if #tags[tagnum]:clients() == 0 then
      awful.spawn(program)
      tags[tagnum].selected = true
      if tagnum == 1 then
         gears.timer.start_new(1, function() et:stop(); setemacsatmaster() end)
      end
   end
end

local function tagtoggle(tagnum)
   if #tags[tagnum]:clients() == 0 then
      tags[tagnum].selected = true
   else
      awful.tag.viewtoggle(tags[tagnum])
   end
end

local function tagviewonly(tagnum)
   tags[tagnum].selected = true
   for i = 2, 14 do
      if i ~= tagnum then
         tags[i].selected = false
      end
   end
   if #tags[tagnum]:clients() > 0 then
      client.focus = tags[tagnum]:clients()[1]
   end
end

local function movetotag(tagnum)
   if client.focus
      and client.focus:tags()[1] ~= tags[1]
      and client.focus:tags()[1] ~= tags[2]
      and client.focus:tags()[1] ~= tags[3]
      and client.focus:tags()[1] ~= tags[4] then
      local focus = client.focus
      client.focus:move_to_tag(tags[tagnum])
      tags[tagnum].selected = true
      client.focus = focus
   end
end

local autorun = {
   xsetb,
   xsetr,
   hsetroot,
   xmodmap,
   xscreensaver,
   alsasetup,
   ibus,
   nmapplet,
   polkitgnome,
}

for app = 1, #autorun do
   awful.spawn(autorun[app])
end

local waw = awful.screen.focused().workarea.width
local ew = 615
if waw < 1700 then ew = 530 end
for i = 1, 14 do
   tags[i].master_width_factor = ew/waw
end
if 1-ew/(waw-ew) >= 0 then
   kmawesome.layout.split.setfact(1-ew/(waw-ew))
else
   kmawesome.layout.split.setfact(1.0/3)
   awful.layout.set(layouts[2])
end
mouse.coords({x = 3000, y = 2000})

local mytextclock = wibox.widget.textclock('%a %b %d, %Y; %H:%M:%S', 0.1)

local memwidget = wibox.widget.graph()
memwidget:set_width(32)
memwidget:set_height(16)
memwidget:set_background_color('#494B4F')
memwidget:set_border_color('#000000')
memwidget:set_color('#AECF96')
vicious.register(memwidget, vicious.widgets.mem, '$1', 1)

local cpuwidget = wibox.widget.graph()
cpuwidget:set_width(32)
cpuwidget:set_height(16)
cpuwidget:set_background_color('#494B4F')
cpuwidget:set_color('#FF5656')
cpuwidget:set_border_color('#000000')
vicious.register(cpuwidget, vicious.widgets.cpu, '$1', 1)

-- http://awesome.naquadah.org/wiki/Acpitools-based_battery_widget
--local mybattmon = widget.textbox({ type = "textbox", name = "mybattmon", align = "right" })
local mybattmon = wibox.widget.textbox()
function battery_status ()
   local output={} --output buffer
   local fd=io.popen("acpitool -b", "r") --list present batteries
   local line=fd:read()
   while line do --there might be several batteries.
      local battery_num = string.match(line, "Battery #(%d+)")
      local battery_load = string.match(line, " (%d*.%d+)%%")
      local time_rem = string.match(line, "(%d+:%d+):%d+")
      if time_rem == "00:00" then time_rem = nil end
      local discharging
      if string.match(line, "discharging")=="discharging" then --discharging: always red
         discharging="<span color=\"#CC7777\">"
      elseif tonumber(battery_load)>85 then --almost charged
         discharging="<span color=\"#77CC77\">"
      else --charging
         discharging="<span color=\"#CCCC77\">"
      end
      if battery_num and battery_load and time_rem then
         table.insert(output,discharging.."BAT#"..battery_num.." "..battery_load.."% "..time_rem.."</span>")
      elseif battery_num and battery_load then --remaining time unavailable
         table.insert(output,discharging.."BAT#"..battery_num.." "..battery_load.."%</span>")
      end --even more data unavailable: we might be getting an unexpected output format, so let's just skip this line.
      line=fd:read() --read next line
   end
   return table.concat(output," ") --FIXME: better separation for several batteries. maybe a pipe?
end
if os.execute("acpitool") == 0 then
   mybattmon:set_markup(" " .. battery_status() .. " ")
   mybattomon_timer = gears.timer.start_new(30, function() mybattmon:set_markup(" " .. battery_status() .. " "); return true end)
end

local mysensors = wibox.widget.textbox()

function sensors_status ()
   local output={} --output buffer
   local fd=io.popen("sensors")
   local line=fd:read()
   while line do --there might be several batteries.
      local sensors_res = string.match(line, "Physical id 0:  (%a*.%d+).%d°")
      if sensors_res then
         table.insert(output, "<span color=\"#FF8888\">" .. sensors_res .."℃</span>")
      end --even more data unavailable: we might be getting an unexpected output format, so let's just skip this line.
      line=fd:read() --read next line
   end
   return table.concat(output," ")
end

if os.execute('sensors') == 0 then
   mysensors:set_markup(" " .. sensors_status() .. " ")
   gears.timer.start_new(10, function() mysensors:set_markup(" " .. sensors_status() .. " "); return true end)
end

local mywibar = awful.wibar({position = 'top', height=16})

local left_layout = wibox.layout.fixed.horizontal()
left_layout:add(cpuwidget)
left_layout:add(memwidget)

local right_layout = wibox.layout.fixed.horizontal()
right_layout:add(wibox.widget.systray())
right_layout:add(mybattmon)
right_layout:add(mysensors)
right_layout:add(mytextclock)

local layout = wibox.layout.align.horizontal()
layout:set_left(left_layout)
layout:set_middle(kmawesome.widget.tasklist(1, kmawesome.widget.tasklist.filter.currenttags))
layout:set_right(right_layout)

mywibar:set_widget(layout)

local globalkeys = awful.util.table.join(
   awful.key({}, 'XF86AudioLowerVolume', function () awful.spawn('amixer set Master 1-') end),
   awful.key({}, 'XF86AudioMute', function () awful.spawn('amixer set Master toggle') end),
   awful.key({}, 'XF86AudioRaiseVolume', function () awful.spawn('amixer set Master 1+') end),
   awful.key({}, 'XF86Display', function () awful.spawn('/home/kmaeda/vga.sh') end),
   awful.key({}, 'XF86ScreenSaver', function () awful.spawn('xscreensaver-command -lock') end),
   awful.key({}, 'XF86Sleep', function () awful.spawn(sleepcommand) end),

   -- ScrLk means 'Screen_Lock', not 'Scroll_Lock'.
   awful.key({}, 'Scroll_Lock', function () awful.spawn('xscreensaver-command -lock') end),
   awful.key({}, 'Cancel', function () awful.spawn(sleepcommand) end),

   awful.key({modkey}, 'e', function () launchprogram(editor, 1); tags[1].selected = true; setemacsatmaster(); if tags[1]:clients()[1] then client.focus = tags[1]:clients()[1] end end),
   awful.key({modkey}, 'm', function () launchprogram(musicplayer, 4); tagviewonly(4); setemacsatmaster() end),
   awful.key({modkey}, 'n', function () awful.client.focus.byidx(1); if client.focus then client.focus:raise() end end),
   awful.key({modkey}, 'p', function () awful.client.focus.byidx(-1); if client.focus then client.focus:raise() end end),
   awful.key({modkey}, 's', function () launchprogram(mua, 3); tagviewonly(3); setemacsatmaster() end),
   awful.key({modkey}, 'w', function () launchprogram(webbrowser, 2); tagviewonly(2); setemacsatmaster() end),
   awful.key({modkey}, '-', function () awful.spawn('amixer set Master 1-') end),
   awful.key({modkey}, '=', function () awful.spawn('amixer set Master 1+') end),
   awful.key({modkey}, 'Return', function () awful.spawn(terminal) end),
   awful.key({modkey}, 'space', function () awful.layout.inc(layouts, 1) end),

   awful.key({modkey, shiftkey}, 'n', function () awful.client.swap.byidx(1) end),
   awful.key({modkey, shiftkey}, 'p', function () awful.client.swap.byidx(-1) end),

   awful.key({modkey, controlkey}, 'b', function () awful.spawn('audtool playlist-advance') end),
   awful.key({modkey, controlkey}, 'c', function () awful.spawn('audtool playlist-clear') end),
   awful.key({modkey, controlkey}, 'e', function () tagtoggle(1); launchprogram(editor, 1); setemacsatmaster() end),
   awful.key({modkey, controlkey}, 'm', function () tagtoggle(4); launchprogram(musicplayer, 4); setemacsatmaster() end),
   awful.key({modkey, controlkey}, 'n', function () kmawesome.layout.split.incfact(0.01) end),
   awful.key({modkey, controlkey}, 'p', function () kmawesome.layout.split.incfact(-0.01) end),
   awful.key({modkey, controlkey}, 'r', awesome.restart),
   awful.key({modkey, controlkey}, 's', function () tagtoggle(3); launchprogram(mua, 3); setemacsatmaster() end),
   awful.key({modkey, controlkey}, 'v', function () awful.spawn('audtool playback-stop') end),
   awful.key({modkey, controlkey}, 'w', function () tagtoggle(2); launchprogram(webbrowser, 2); setemacsatmaster() end),
   awful.key({modkey, controlkey}, 'x', function () awful.spawn('audtool playback-play') end),
   awful.key({modkey, controlkey}, 'z', function () awful.spawn('audtool playlist-reverse') end)
)

local clientkeys = awful.util.table.join(
   awful.key({modkey}, 'c', function (c) c:kill() end),
   awful.key({modkey, controlkey}, 'space', function(c) c.maximized = false; c.maximized_vertical=false; c.maximized_horizontal=false; c:raise(); client.focus.floating = not client.focus.floating end),
   awful.key({modkey, controlkey}, 'Return', function (c) c:swap(awful.client.getmaster()) end))

for i = 0, 9 do
   local j
   if i == 0 then j = 14 else j = i+4 end
   globalkeys = awful.util.table.join(globalkeys,
                                      awful.key({modkey}, tostring(i), function () tagviewonly(j); setemacsatmaster() end),
                                      awful.key({modkey, controlkey}, tostring(i), function () awful.tag.viewtoggle(tags[j]); setemacsatmaster() end),
                                      awful.key({modkey, shiftkey}, tostring(i), function() movetotag(j) end))
end

local clientbuttons = awful.util.table.join(
   awful.button({}, 1, function (c) client.focus = c; c:raise() end),
   awful.button({modkey}, 1, awful.mouse.client.move),
   awful.button({modkey}, 3, function (c) awful.mouse.client.resize(c, 'bottom_right') end))

root.keys(globalkeys)

awful.rules.rules = {
   { rule = { },
     properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = true,
                    keys = clientkeys,
                    buttons = clientbuttons,
                    tag = tags[14],
                    maximized_vertical = false,
                    maximized_horizontal = false }},
   { rule = { class = "Emacs" },
     properties = { tag = tags[1] } },
   { rule = { class = "Firefox" },
     properties = { tag = tags[2] } },
   { rule = { class = "Sylpheed" },
     properties = { tag = tags[3] } },
   { rule = { class = "Audacious" },
     properties = { tag = tags[4] } },
   { rule = { class = "fontforge" },
     properties = { floating = true } },
   { rule = { class = "Gimp" },
     properties = { floating = true } },
}

local function assignnewtag(c)
   for i = 5, 13 do
      if #tags[i]:clients() == 0 then
         c:tags({tags[i]})
         break
      end
   end
   if not c:tags()[1].selected then
      c:tags()[1].selected = true
   end
   client.focus = c
   c:raise()
end

client.connect_signal("manage",
                  function (c)
                     c.size_hints_honor = false
                     c.opacity = 0.5
                     if client.focus == c then c.opacity = 1 end

                     if c:tags()[1] == tags[14] then
                        assignnewtag(c)
                     end

                     if c:tags()[1] == tags[2] and #tags[2]:clients() > 1 then
                        c.floating = true
                        assignnewtag(c)
                     end

                     if c:tags()[1] == tags[3] and #tags[3]:clients() > 1 then
                        assignnewtag(c)
                     end

                     awful.client.setslave(c)
                     if not c.size_hints.user_position and not c.size_hints.program_position then
                        awful.placement.no_overlap(c)
                        awful.placement.no_offscreen(c)
                     end
                     awful.client.cycle(true)
                     setemacsatmaster()
                  end)

client.connect_signal("focus",
                  function(c)
                     c.border_color = beautiful.border_focus
                     c.opacity = 1
                  end)
client.connect_signal("unfocus",
                  function(c)
                     c.border_color = beautiful.border_normal
                     if not c.floating then
                        c.opacity = 0.5
                     end
                  end)

awful.spawn(xcompmgr)
