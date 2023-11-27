EnumUtils = {}

local function _EnumDelete(tbl, key)
    rawset(tbl, rawget(tbl, key), nil)
    rawset(tbl, key, nil)
end

local function _EnumCreate(tbl, key, idx)
    rawset(tbl, key, idx)
    rawset(tbl, idx, key)
end

--[[
    Append key to enum

    tbl: Enum
    key: Key
]]
function EnumUtils.AppendToEnum(tbl, key)
    assert(tbl, "Enum cannot be nil")
    assert(type(tbl) == "table", "Enum must be of type table")
    assert(key, "Key cannot be nil")
    assert(rawget(tbl, key) == nil, string.format("Key \"%s\" already exists in enum", key))

    local maxVal
    if tbl == kTechId then
        maxVal = tbl.Max

        -- Shift kTechId.Max up by 1
        _EnumDelete(tbl, maxVal)
        _EnumCreate(tbl, 'Max', maxVal + 1)
    else
        maxVal = -1
        for k, v in next, tbl do
            if type(v) == "number" and v > maxVal then
                maxVal = v
            end
        end
        maxVal = maxVal + 1
    end

    assert(maxVal, "Failed to get next value for enum")
    _EnumCreate(tbl, key, maxVal)
end

--[[
    Delete key from enum

    tbl: Enum
    key: Key
]]
function EnumUtils.RemoveFromEnum(tbl, key)
    assert(tbl, "Enum cannot be nil")
    assert(type(tbl) == "table", "Enum must be of type table")
    assert(key, "Key cannot be nil")

    local keyIdx = rawget(tbl, key)
    assert(keyIdx, "Key doesn't exist in enum")

    -- Delete enum entry
    _EnumDelete(tbl, key)

    -- If we modified the kTechId eunm, we need to update kTechId.Max too.
    if tbl == kTechId then
        local maxVal = tbl.Max

        -- Shift everything inbetween the deleted key and kTechId.Max down by 1
        for i = keyIdx+1, maxVal-1 do
            local name = rawget(tbl, i)
            assert(name)
            _EnumDelete(tbl, name) -- remove old entry
            _EnumCreate(tbl, name, i - 1) -- create new one
        end

        -- Shift kTechId.Max down by 1
        _EnumDelete(tbl, maxVal)
        _EnumCreate(tbl, 'Max', maxVal - 1)
    end
end
