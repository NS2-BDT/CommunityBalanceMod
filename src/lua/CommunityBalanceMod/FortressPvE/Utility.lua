-- ========= Community Balance Mod ===============================
--
-- "lua\Utility.lua"
--
--    Created by:   4sdfg
--
-- ===============================================================

function BitMask64_CreateTable(tableBitStrings)
    assert(#tableBitStrings <= 62, "Too many values for bitmask")
    
    local outputBitMask = {}
    local one = 1llu

    for index, bitStringName in ipairs(tableBitStrings) do
        -- Don't use the most significant bit on the low byte
        if index >= 32 then
            outputBitMask[bitStringName] = bit.lshift(one, index)
        else
            outputBitMask[bitStringName] = bit.lshift(one, index - 1)
        end
    end

    return outputBitMask
end

function BitMask64_Split(bitmask)
    -- uint32_t high = (uint32_t) (i >> 32)
    -- uint32_t low = (uint32_t) (i & 0x00000000FFFFFFFF); // could also just cast but I don't think lua can do that 
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


-- === Some tests ===
--
-- This should run on the main menu as that's when Utility.lua is first loaded.
--
-- Make sure there's no assert errors in console before pushing any changes to these functions!
local runTests = false

if runTests then
    for i = 0,15 do print("Utility.lua :: RUNNING TESTS") end

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

    assert(bitmask == 1125899906843152)

    assert(bit.band(bitmask, bitmaskTable["5"])  ~= 0)
    assert(bit.band(bitmask, bitmaskTable["10"]) ~= 0)
    assert(bit.band(bitmask, bitmaskTable["50"]) ~= 0)
    assert(bit.band(bitmask, bitmaskTable["4"]) == 0)
    assert(bit.band(bitmask, bitmaskTable["49"]) == 0)

    local high,low = BitMask64_Split(bitmask)

    assert(type(high) == "number")
    assert(type(low) == "number")
    assert(high == 262144)
    assert(low == 528)

    local bitmask2 = BitMask64_Combine(high, low)

    assert(bitmask2 == 1125899906843152)

    assert(bit.band(bitmask2, bitmaskTable["5"]) ~= 0)
    assert(bit.band(bitmask2, bitmaskTable["10"]) ~= 0)
    assert(bit.band(bitmask2, bitmaskTable["50"]) ~= 0)
    assert(bit.band(bitmask2, bitmaskTable["4"]) == 0)
    assert(bit.band(bitmask2, bitmaskTable["49"]) == 0)

    for i = 0,15 do print("Utility.lua :: TESTS OK") end
end
