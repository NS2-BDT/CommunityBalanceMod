EnumUtils = {}

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

        -- Delete old max
        rawset(tbl, rawget(tbl, maxVal), nil)
        rawset(tbl, maxVal, nil)

        -- Move max down
        rawset(tbl, 'Max', maxVal + 1)
        rawset(tbl, maxVal + 1, 'Max')
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

    rawset(tbl, key, maxVal)
    rawset(tbl, maxVal, key)
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
    assert(rawget(tbl, key), "Key doesn't exist in enum")

    -- Delete enum entry
    rawset(tbl, rawget(tbl, key), nil)
    rawset(tbl, key, nil)

    -- If we modified the kTechId eunm, we need to update kTechId.Max too.
    if tbl == kTechId then
        local maxVal = tbl.Max

        -- delete old max
        rawset(tbl, rawget(tbl, maxVal), nil)
        rawset(tbl, maxVal, nil)
    
        -- move max down
        rawset(tbl, 'Max', maxVal - 1)
        rawset(tbl, maxVal - 1, 'Max')
    end
end
