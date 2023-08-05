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
        if i % 10 == 0 then
            chan:supply(tbl)
        end
    end
    if do_tables_match(t, tbl) then
        tbl = shuffle(t)
    end
    chan:supply(tbl)
    return tbl
end

local tab = {}
for i = 1, 1000 do
    tab[#tab + 1] = i
end
chan:supply(tab)
tab = shuffle(tab)
chan:supply(tab)
luamidi.noteOff(0, lastshuffle)
love.timer.sleep(1)
local solvedTab = {}
-- function swap(a, b, table)
--     if table[a] == nil or table[b] == nil then
--         return false
--     end

--     if table[a] > table[b] then
--         table[a], table[b] = table[b], table[a]
--         return true
--     end

--     return false
-- end

-- local lastsolve = 0
-- function bubblesort(array)
--     for i = 1, table.maxn(array) do
--         local ci = i
--         ::redo::
--         luamidi.noteOff(0, lastsolve)
--         lastsolve = math.floor((array[i] / #tab) * 127)
--         luamidi.noteOn(0, lastsolve)
--         chan:supply(array)

--         if swap(ci, ci + 1, array) then
--             ci = ci - 1
--             goto redo
--         end
--     end
--     return array
-- end

-- tab = bubblesort(tab)
for i, v in ipairs(tab) do
    solvedTab[#solvedTab + 1] = v
end
local lastsolve = 0
for i = 1, #tab do
    solvedTab[tab[i]] = tab[i]
    luamidi.noteOff(0, lastsolve)
    lastsolve = math.floor((tab[i] / #tab) * 127)
    luamidi.noteOn(0, lastsolve)
    if i % 10 == 0 then
        chan:supply(solvedTab)
    end
end

luamidi.noteOff(0, lastsolve)
local function doDone()
    tab = {}
    for i = 1, #solvedTab do
        tab[#tab + 1] = solvedTab[i]
    end
    local ga = 0
    for i = 1, #tab do
        tab[i] = "done"
        luamidi.noteOff(0, ga)
        ga = math.floor((i / #tab) * 127)
        luamidi.noteOn(0, ga)
        if i % 10 == 0 then
            chan:supply(tab)
        end
    end

    chan:supply(solvedTab)
end

doDone()
love.timer.sleep(3)
luamidi.gc()
