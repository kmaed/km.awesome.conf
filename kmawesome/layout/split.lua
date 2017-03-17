local screen = require("awful.screen")
local tag = require("awful.tag")
local layout = require("awful.layout")
local math = math

local splitfact = 0.66

module("kmawesome.layout.split")

function setfact(num)
   splitfact = num
   if splitfact < 0 then
      splitfact = 0
   elseif splitfact > 1 then
      splitfact = 1
   end
   layout.arrange(1)
end

function incfact(num)
   setfact(splitfact + num)
end

local function arrange_internal(cls, dir, targetc, endc, wa)
   if targetc == endc then
      cls[targetc]:geometry(wa)
      return
   end

   if dir == 'h' then
      local geom = {
         x = wa.x,
         y = wa.y,
         width = wa.width*splitfact,
         height = wa.height
      }
      cls[targetc]:geometry(geom)
      wa.x = wa.x + geom.width
      wa.width = wa.width - geom.width
      arrange_internal(cls, 'v', targetc+1, endc, wa)
   end

   if dir == 'v' then
      local geom = {
         x = wa.x,
         y = wa.y,
         width = wa.width,
         height = wa.height*splitfact
      }
      cls[targetc]:geometry(geom)
      wa.y = wa.y + geom.height
      wa.height = wa.height - geom.height
      arrange_internal(cls, 'h', targetc+1, endc, wa)
   end
end


local function arrange_entry(param, dir)
   local t = screen.focused().selected_tag
   local cls = param.clients
   local nmaster = math.min(t.master_count, #cls)
   local nother = math.max(#cls - nmaster,0)

   local mwfact = t.master_width_factor
   local wa = param.workarea

   local mwa = {
      x = wa.x,
      y = wa.y,
      width = wa.width,
      height = wa.height
   }
   local owa = {
      x = wa.x,
      y = wa.y,
      width = wa.width,
      height = wa.height
   }

   if nmaster > 0 then
      mwa.width = mwa.width*mwfact
      owa.x = owa.x + mwa.width
      owa.width = owa.width - mwa.width
   end

   if nmaster > 0 then
      arrange_internal(cls, dir, 1, nmaster, mwa)
   end
   if nother > 0 then
      arrange_internal(cls, dir, nmaster+1, #cls, owa)
   end
end

v = {}
h = {}

v.name = "split vertical"
v.arrange = function(param) arrange_entry(param, 'v') end
h.name = "split horizontal"
h.arrange = function(param) arrange_entry(param, 'h') end
