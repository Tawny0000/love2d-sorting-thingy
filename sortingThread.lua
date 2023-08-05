require("love.math")
require("love.timer")
local luamidi = require("luamidi")
luamidi.noteOn(0, 0, 0)
local chan = love.thread.getChannel("sort")

function do_tables_match(a, b)
    return table.concat(a) == table.concat(b)
end

local lastshuffle = 0
function shuffle(t)
    local tbl = {}
    for i = 1, #t do
        tbl[i] = t[i]
    end
    for i = #tbl, 2, -1 do
        local j = love.math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
        luamidi.noteOff(0, lastshuffle)
        lastshuffle = math.floor((tbl[i] / #tbl) * 127)
        luamidi.noteOn(0, lastshuffle)
        chan:supply(tbl)
    end
    if do_tables_match(t, tbl) then
        tbl = shuffle(t)
    end
    chan:supply(tbl)
    return tbl
end

local tab = {}
for i = 1, 500 do
    tab[#tab + 1] = i
end
chan:supply(tab)
tab = shuffle(tab)
chan:supply(tab)
luamidi.noteOff(0, lastshuffle)
love.timer.sleep(1)
local solvedTab = {}
for i, v in ipairs(tab) do
    solvedTab[#solvedTab + 1] = v
end
local lastsolve = 0
for i = 1, #tab do
    solvedTab[tab[i]] = tab[i]
    luamidi.noteOff(0, lastsolve)
    lastsolve = math.floor((tab[i] / #tab) * 127)
    luamidi.noteOn(0, lastsolve)
    chan:supply(solvedTab)
end

luamidi.gc()
