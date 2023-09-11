function BitMask64_CreateTable(tableBitStrings)
    local outputBitMask = {}
    local one = 1llu

    for index, bitStringName in ipairs(tableBitStrings) do
        outputBitMask[bitStringName] = bit.lshift(one, index - 1)
    end

    return outputBitMask
end

function BitMask64_Split(bitmask)
    -- uint32_t high = (uint32_t) (i >> 32)
    -- uint32_t low = (uint32_t) (i & 0x00000000FFFFFFFF); // this could be a simple cast but lua can't do that...
    local high64 = bit.rshift(bitmask, 32)
    local low64 = bit.band(bitmask, 0x00000000FFFFFFFF)

    local high32 = tonumber(high64)
    local low32 = tonumber(low64)

    return high32, low32
end

function BitMask64_Combine(high32, low32)
    -- uint64_t combined = (uint64_t) high << 32 | low;

    local high64 = bit.bor(0llu, high32) -- I suppose this is a cast :}
    local bitmask = bit.bor(bit.lshift(high64, 32), low32)

    return bitmask
end

local function GetNetVarNames(name)
    return string.format("%sHIGH", name), string.format("%sLOW", name)
end

function BitMask64_CreateNetVars(netvars, name)
    local nameHigh, nameLow = GetNetVarNames(name)

    netvars[nameHigh] = "integer"
    netvars[nameLow] = "integer"

    return netvars
end

function BitMask64_NetVarsToSingleValue(obj, name)
    local nameHigh, nameLow = GetNetVarNames(name)

    return BitMask64_Combine(obj[nameHigh], obj[nameLow])
end

function BitMask64_SingleValueToNetVars(obj, name, value)
    local high,low = BitMask64_Split(value)

    local nameHigh, nameLow = GetNetVarNames(name)
    obj[nameHigh] = high
    obj[nameLow] = low
end

function BitMask64_InitNetVars(obj, name)
    local nameHigh, nameLow = GetNetVarNames(name)
    obj[nameHigh] = 0
    obj[nameLow] = 0
end


-- === Some tests ===
--
-- This should run on the main menu as that's when Utility.lua is first loaded.
--
-- Make sure there's no assert errors in console before pushing any changes to these functions!
local runTests = false

if runTests then
    local bitmaskData = {
        "1","2","3","4","5","6","7","8","9","10",
        "11","12","13","14","15","16","17","18","19","20",
        "21","22","23","24","25","26","27","28","29","30",
        "31","32","33","34","35","36","37","38","39","40",
        "41","42","43","44","45","46","47","48","49","50"
    }

    local bitmaskTable = BitMask64_CreateTable(bitmaskData)
    local bitmask = bitmaskTable["5"]
    bitmask = bit.bor(bitmask, bitmaskTable["10"])
    bitmask = bit.bor(bitmask, bitmaskTable["50"])

    assert(bitmask == 562949953421840)
    local high,low = BitMask64_Split(bitmask)

    assert(type(high) == "number")
    assert(type(low) == "number")
    assert(high == 131072)
    assert(low == 528)

    local bitmask2 = BitMask64_Combine(high, low)

    assert(bitmask2 == 562949953421840)

    for i = 0,15 do print("Utility.lua :: TESTS OK") end
end
