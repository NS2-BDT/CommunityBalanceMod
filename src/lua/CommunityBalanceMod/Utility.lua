--======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Utility.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
--========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/UtilityShared.lua")
Script.Load("lua/Table.lua")
Script.Load("lua/String.lua")
Script.Load("lua/ConfigFileUtility.lua")
Script.Load("lua/DebugUtility.lua")
Script.Load("lua/Closure.lua")
local ffi = require("ffi")
gNetworkRandomLogData = nil
gRandomDebugEnabled = false

kUpVector = Vector(0, 1, 0)

local gGUIConvertItem

local Max = math.max
local Min = math.min
local pairs = pairs
local ipairs = ipairs
local select = select
local StringExplode = string.Explode
local StringFormat = string.format
local TableConcat = table.concat
local type = type

local kLastBuildVersion
function GetLastBuildVersion() -- Gets last build version, from application launch, NOT VM start
    if not kLastBuildVersion then
        kLastBuildVersion = Client and Client.GetOptionInteger("lastLoadedBuild", 0) or 0 -- Servers have a json file for config.
    end

    return kLastBuildVersion
end

GetLastBuildVersion() -- Do this right away to avoid MainVM (or other places) setting the option key before we get a chance to save it

function ConvertWideStringToString(wideString)

    if not gGUIConvertItem then
        gGUIConvertItem = GUI.CreateItem()
        gGUIConvertItem:SetIsVisible(false)
    end

    gGUIConvertItem:SetWideText(wideString)
    return gGUIConvertItem:GetText()

end

function EntityFilterOne(entity)
    if entity == nil then
        return Lambda  [[false]]
    else
        return SLambda [[ self ent; ... == ent ]] (entity)
    end
end

function EntityFilterOneAndIsa(entity, classname)
    return SLambda [[self ent cls; ... == ent or (...):isa(cls)]] (entity, classname)
end

function EntityFilterTwo(entity1, entity2)
    return SLambda [[self ent1 ent2; ... == ent1 or ... == ent2]] (entity1, entity2)
end

function EntityFilterTwoAndIsa(ent1, ent2, cls)
    return SLambda [[self ent1 ent2 cls; ... == ent1 or ... == ent2 or (...):isa(cls)]] (ent1, ent2, cls)
end

function EntityFilterOnly(entity)
    return SLambda [[ ... ~= self[1] ]] (entity)
end

function EntityFilterAll()
    return Lambda [[true]]
end

function EntityFilterAllButIsa(classname)
    return SLambda [[self cls; not (...):isa(cls)]] (classname)
end

function EntityFilterAllButIsaList(classnameList)
    return function(test) return table.icontains(classnameList, test:GetClassName()) end
end

function EntityFilterAllButMixin(mixinType)
    return SLambda [[self mixin; not HasMixin(..., mixin)]] (mixinType)
end

function EntityFilterMixinAndSelf(entity, mixinType)
    return SLambda [[self ent mixin; ... == ent or HasMixin(..., mixin)]] (entity, mixinType)
end

function EntityFilterMixin(mixinType)
    return SLambda [[self mixin; HasMixin(..., mixin)]] (mixinType)
end

function EntityFilterByTeam(teamNumber)
    return 
        function(test) 
            return HasMixin(test, "Team") and test:GetTeamNumber() == teamNumber
        end
end

function EntityFilterByPlayableTeams()
    return
        function(test)
            return HasMixin(test, "Team") and ( test:GetTeamNumber() == kMarineTeamType or test:GetTeamNumber() == kAlienTeamType )
        end
end

--Adds the material effect to the entity and all child entities (hat have a Model mixin) */
function AddMaterialEffect(entity, material, viewMaterial, entities)

    if HasMixin(entity, "Model") then
        local model = entity._renderModel
        if model ~= nil then
            if model:GetZone() == RenderScene.Zone_ViewModel then
                model:AddMaterial(viewMaterial)
            else
                model:AddMaterial(material)
            end
            table.insert(entities, entity:GetId())
        end
    end

    for i = 1, entity:GetNumChildren() do
        local child = entity:GetChildAtIndex(i - 1)
        AddMaterialEffect(child, material, viewMaterial, entities)
    end

end

function RemoveMaterialEffect(entities, material, viewMaterial)

    for i =1, #entities do
        local entity = Shared.GetEntity( entities[i] )
        if entity ~= nil and HasMixin(entity, "Model") then
            local model = entity._renderModel
            if model ~= nil then
                if model:GetZone() == RenderScene.Zone_ViewModel then
                    model:RemoveMaterial(viewMaterial)
                else
                    model:RemoveMaterial(material)
                end
            end
        end
    end

end

-- Splits string into array, along whitespace boundaries. First element indexed at 1.
function StringToArray(instring)

    local thearray = {}
    local index = 1

    for word in instring:gmatch("%S+") do
        thearray[index] = word
        index = index + 1
    end

    return thearray

end

function GetAspectRatio()

    return Client.GetScreenWidth() / Client.GetScreenHeight()

end

function GetLocalSteamID64()
    return Shared.ConvertSteamId32To64(Client.GetSteamId())
end

function GetLocalAvatarTextureName()
    return Client.GetTextureNameForAvatar(GetLocalSteamID64())
end

function GetEnumCount(enumTable)
    return table.icount(enumTable)
end

-- Enums are tables with keys with the string, values of the enum number
function EnumToString(enumTable, enumNumber)

    local string = enumTable[enumNumber]
    return ConditionalValue(string == nil, "nil", string);

end

function StringToEnum(enumTable, enumString)
    
    PROFILE("StringToEnum")
    
    local function f(key, value)
        if EnumToString(enumTable, value) == enumString then
            return value
        end
    end

    if enumTable == nil or enumString == nil then
        return nil
    end

    return table.foreach(enumTable, f)

end

function StringSplit(str, delim, maxNb)

    if string.find(str, delim) == nil then
        return { str }
    end

    if maxNb == nil or maxNb < 1 then
        maxNb = 0
    end

    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos

    for part, pos in string.gmatch(str, pat) do

        nb = nb + 1
        result[nb] = part
        lastPos = pos

        if nb == maxNb then
            break
        end
    end

    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end

    return result

end

-- Returns a string that represents the diff of the two strings passed in. They should be similar
-- or this won't produce anything useful.
function StringDiff(s1, s2)

    if s1 ~= nil and s2 == nil then
        return s1
    elseif s1 == nil and s2 ~= nil then
        return s2
    elseif s1 == nil and s2 == nil then
        return ""
    end

    if string.len(s2) > string.len(s1) then
        local temp = s1
        s1 = s2
        s2 = temp
    end

    local output = ""

    local j = 1
    for i = 1, string.len(s1) do
        local s1char = s1:sub(i, i)
        local s2char = s2:sub(j, j)

        if s1char ~= s2char then
            output = output .. s1char
        else
            j = j + 1
        end

    end

    return output

end

-- Examples:
--    Pluralize(1, "clip") => "1 clip"
--    Pluralize(2, "horse") => "2 horses"
--    Pluralize(0, "player") => "0 players"
--    Pluralize(3, "glass") => "3 glasses"
function Pluralize(number, baseText)
    if number == 1 then
        return StringFormat("%d %s", number, baseText)
    else
        -- If ends with an s
        if(StringEndsWith(baseText, "s")) then
            return StringFormat("%d %ses", number, baseText)
        else
            return StringFormat("%d %ss", number, baseText)
        end
    end
end

function firstToUpper(str)
    return (str:gsub("^%l", string.UTF8Upper))
end

--[[
--The following two methods are based on work by Person8880 from https://github.com/Person8880/Shine
 ]]

--[[
Wraps text to fit the size limit. Used for long words...

Returns two strings, first one fits entirely on one line, the other may not, and should be
added to the next word.
]]
function TextWrap( label, text, xpos, maxWidth )
    local i = 1
    local firstLine = text
    local secondLine = ""
    local chars = string.UTF8Encode( text )
    local textLength = #chars
    local scale = label.GetScale and label:GetScale().x or 1

    --Character by character, extend the text until it exceeds the width limit.
    repeat
        local curText = TableConcat( chars, "", 1, i)

        --Once it reaches the limit, we go back a character, and set our first and second line results.
        if xpos + label:GetTextWidth( curText ) * scale > maxWidth then
            firstLine = TableConcat( chars, "", 1, math.max(i - 1, 1 ) )
            secondLine = TableConcat( chars, "", math.max(i, 2) )

            break
        end

        i = i + 1
    until i >= textLength

    return firstLine, secondLine
end

--[[
    Word wraps text, adding new lines where the text exceeds the width limit.
]]
function WordWrap( label, text, xpos, maxWidth, maxLines )
    if maxWidth <= 0 then return "" end

    local words = StringExplode( text, " " )
    local startIndex = 1
    local lines = {}
    local i = 1
    local scale = label.GetScale and label:GetScale().x or 1

    --While loop, as the size of the words table may increase. But make sure we don't end in a infinite loop
    while i <= #words and i <= 200 do
        local curText = TableConcat( words, " ", startIndex, i )

        if xpos + label:GetTextWidth( curText ) * scale > maxWidth then
            --This means one word is wider than the whole label, so we need to cut it part way through.
            if startIndex == i then
                local firstLine, secondLine = TextWrap( label, curText, xpos, maxWidth )

                lines[ #lines + 1 ] = firstLine

                table.insert(words, i + 1, secondLine )

                startIndex = i + 1
            else
                lines[ #lines + 1 ] = TableConcat( words, " ", startIndex, i - 1 )

                --We need to jump back a step, as we've still got another word to check.
                startIndex = i
                i = i - 1
            end

            if maxLines and maxLines <= #lines then
                break
            end

        elseif i == #words then --We're at the end!
            lines[ #lines + 1 ] = curText
            startIndex = i + 1
        end

        i = i + 1
    end

    return TableConcat( lines, "\n" ), maxLines and TableConcat(words, " ", startIndex), #lines
end

-- Returns nil if it doesn't hit
function GetLinePlaneIntersection(planePoint, planeNormal, lineOrigin, lineDirection)

    local p = Math.DotProduct(lineDirection, planeNormal)

    if p < 0  then

        local d = -Math.DotProduct(planePoint, planeNormal)
        local t = -(Math.DotProduct(planeNormal, lineOrigin) + d) / p

        if t >= 0 then

            return lineOrigin + lineDirection * t

        end

    end

    return nil

end

-- Returns the sign of a number (1, 0, -1)
function Sign(num)

    local sign = 1

    if (num < 0) then
        sign = -1
    elseif(num == 0) then
        sign = 0
    end

    return sign

end

function DebugBox(minPoint, maxPoint, extents, lifetime, r, g, b, a)

    local minX = Min(minPoint.x - extents.x, maxPoint.x - extents.x)
    local maxX = Max(maxPoint.x + extents.x, maxPoint.x + extents.x)

    local minY = Min(minPoint.y - extents.y, maxPoint.y - extents.y)
    local maxY = Max(maxPoint.y + extents.y, maxPoint.y + extents.y)

    local minZ = Min(minPoint.z - extents.z, maxPoint.z - extents.z)
    local maxZ = Max(maxPoint.z + extents.z, maxPoint.z + extents.z)

    -- Bottom of cube
    DebugLine(Vector(minX, minY, minZ), Vector(minX, minY, maxZ), lifetime, r, g, b, a)
    DebugLine(Vector(minX, minY, minZ), Vector(maxX, minY, minZ), lifetime, r, g, b, a)
    DebugLine(Vector(maxX, minY, minZ), Vector(maxX, minY, maxZ), lifetime, r, g, b, a)
    DebugLine(Vector(minX, minY, maxZ), Vector(maxX, minY, maxZ), lifetime, r, g, b, a)

    -- Top of cube
    DebugLine(Vector(minX, maxY, minZ), Vector(minX, maxY, maxZ), lifetime, r, g, b, a)
    DebugLine(Vector(minX, maxY, minZ), Vector(maxX, maxY, minZ), lifetime, r, g, b, a)
    DebugLine(Vector(maxX, maxY, minZ), Vector(maxX, maxY, maxZ), lifetime, r, g, b, a)
    DebugLine(Vector(minX, maxY, maxZ), Vector(maxX, maxY, maxZ), lifetime, r, g, b, a)

    -- Sides
    DebugLine(Vector(minX, maxY, minZ), Vector(minX, minY, minZ), lifetime, r, g, b, a)
    DebugLine(Vector(maxX, maxY, minZ), Vector(maxX, minY, minZ), lifetime, r, g, b, a)
    DebugLine(Vector(maxX, maxY, maxZ), Vector(maxX, minY, maxZ), lifetime, r, g, b, a)
    DebugLine(Vector(minX, maxY, maxZ), Vector(minX, minY, maxZ), lifetime, r, g, b, a)


end

--[[
	Show how a Shared.TraceBox works. 
]]
function DebugTraceBox(extents, startPoint, endPoint, lifetime, r, g, b, a)
    local lineArgs= { lifetime, r, g, b, a }

    DebugLine(startPoint, endPoint, lifetime, r, g, b, a)

    local points = {}
    -- create points for the boxes around the start and endpoint
    for i=0,7 do
        local v = Vector(
            extents.x * (bit.band(i,1) == 1 and 1 or -1),
            extents.y * (bit.band(i,2) == 2 and 1 or -1),
            extents.z * (bit.band(i,4) == 4 and 1 or -1))
        table.insert(points, startPoint + v )
        table.insert(points, endPoint + v)
    end
    -- even points are the startpoint box
    -- first four points have the same z-coords
    -- first point is all negative
    _DebugTraceNeighbours(lineArgs, points, 1, 3, 5, 9, 2)
    _DebugTraceNeighbours(lineArgs, points, 7, 3, 5, 15, 8)
    _DebugTraceNeighbours(lineArgs, points, 11, 3, 9, 15, 12)
    _DebugTraceNeighbours(lineArgs, points, 13, 5, 9, 15, 14)

    _DebugTraceNeighbours(lineArgs, points, 4, 2, 8, 12, 3)
    _DebugTraceNeighbours(lineArgs, points, 6, 2, 8, 14, 5)
    _DebugTraceNeighbours(lineArgs, points, 10, 2, 12, 14, 9)
    _DebugTraceNeighbours(lineArgs, points, 16, 8, 12, 14, 15 )

end

function _DebugTraceNeighbours(lineArgs, points, pi, ...)

    local p1 = points[pi]
    for _,pointIndex in ipairs( {...} ) do

        local p2 = points[pointIndex]
        DebugLine(p1, p2, lineArgs[1], lineArgs[2], lineArgs[3], lineArgs[4], lineArgs[5])

    end

end

function DebugLineSuccess(startPoint, endPoint, lifetime, success)
    DebugLine(startPoint, endPoint, lifetime, ConditionalValue(success, 0, 1), ConditionalValue(success, 1, 0), 0, 1)
end

-- rgba are normalized values (0-1)
function DebugLine(startPoint, endPoint, lifetime, r, g, b, a, forceSharedAPI)

    if (Client or forceSharedAPI)
            and not Shared.GetIsRunningPrediction() then

        Shared.DebugColor(r, g, b, a)
        Shared.DebugLine(startPoint, endPoint, lifetime)

    elseif Server then

        --TODO - get rid of this eventually
        Server.SendNetworkMessage("DebugLine", BuildDebugLineMessage(startPoint, endPoint, lifetime, r, g, b, a), true)

    end

end

function DebugCircle(center, radius, normal, lifetime, r, g, b, a, forceSharedAPI)

    local xMag = math.abs(normal.x)
    local yMag = math.abs(normal.y)
    local zMag = math.abs(normal.z)
    local side

    if xMag < Min(yMag, zMag) then
        side = Vector(1, 0, 0)
    elseif yMag < Min(xMag, zMag) then
        side = Vector(0, 1, 0)
    else
        side = Vector(0, 0, 1)
    end

    local up = side:CrossProduct(normal)
    local lastPoint = center + radius*side

    for i = 1, 16 do

        local angle = 2 * i * math.pi / 16
        local point = center + radius*math.cos(angle)*side + radius*math.sin(angle)*up

        DebugLine(lastPoint, point, lifetime, r, g, b, a, forceSharedAPI)
        lastPoint = point

    end

end

function DebugWireSphere( center, radius, lifetime, r, g, b, a, forceSharedAPI )

    local numCircles = 8
    for i = 1, numCircles do

        local rads = (i-1)*math.pi/numCircles
        local normal = Vector(math.cos(rads), math.sin(rads), 0)
        DebugCircle( center, radius, normal, lifetime, r, g, b, a, forceSharedAPI )

    end

end


function DebugPoint(point, size, lifetime, r, g, b, a)

    if not Shared.GetIsRunningPrediction() then

        Shared.DebugColor(r, g, b, a)
        Shared.DebugPoint(point, size, lifetime)

    end

end

function DebugCapsule(sweepStart, sweepEnd, capsuleRadius, capsuleHeight, lifetime, forceSharedAPI)

    if (Client or forceSharedAPI) and not Shared.GetIsRunningPrediction() then
        Shared.DebugCapsule(sweepStart, sweepEnd, capsuleRadius, capsuleHeight, lifetime)
    elseif Server then
        -- TODO - get rid of this eventually
        Server.SendNetworkMessage("DebugCapsule", BuildDebugCapsuleMessage(sweepStart, sweepEnd, capsuleRadius, capsuleHeight, lifetime), true)
    end

end

function DebugSolidSphere( center, radius, lifetime, forceSharedAPI )
    DebugCapsule( center, center, radius, 0.0, lifetime, forceSharedAPI )
end

-- Takes an array of four values - RGB (0-255 each) and makes them into a 4-byte int for use with Flash.
-- Red in the most significant byte, blue in the last.
function ColorArrayToInt(color)
    return bit.lshift(color[1], 16) + bit.lshift(color[2], 8) + color[3]
end

-- Takes a color as an integer (0xFF00EE for example) and converts it to a Color object with
-- full opacity.
function ColorIntToColor(color)

    local red = bit.rshift(bit.band(color, 0xFF0000), 16)
    local green = bit.rshift(bit.band(color, 0x00FF00), 8)
    local blue = bit.band(color, 0x0000FF)

    return Color(red / 0xFF, green / 0xFF, blue / 0xFF, 1)

end

function ColorToColorInt(color)
    return bit.bor(bit.lshift(color.r * 255, 16), bit.lshift(color.g * 255, 8), color.b * 255)
end

-- Returns table of bit masks 
-- Ex: local t = CreateBitMaskTable({"test1", "test2", "test3"})
-- t.test1 => 1
-- t.test2 => 2
-- t.test3 => 4
function CreateBitMask(tableBitStrings)

    local outputBitMask = {}

    for index, bitStringName in ipairs(tableBitStrings) do
        outputBitMask[bitStringName] = bit.lshift(1, index - 1)
    end

    return outputBitMask

end

function BitMaskToString(tableBitStrings, bitMask)

    for currentBitStringName, currentBitMask in pairs(tableBitStrings) do

        if currentBitMask == bitMask then

            return currentBitStringName

        end

    end

    return nil

end

function GetBitMaskNumBits(bitMask)
    local bits = 0
    for k,v in ipairs(bitMask) do
        bits = bit.bor(bits, v)
    end
    return math.ceil(math.log(bits) / math.log(2))
end

function Print(format, ...)
    Shared.Message(StringFormat(format, ...))
end

--[[
	Can print one argument (string or not), or a string and variable list of parameters passed to string.format
	Only prints in dev mode
]]
function DebugPrint(formatString, ...)
    if Shared.GetDevMode() then
        HPrint(formatString, ...)
    end
end


--[[
  As Print, but adds a header consisting of server-type and timestamp header
]]
function HPrint(formatString, ...)

    local result = StringFormat(formatString, ...)

    local predictionString = " "
    if Shared.GetIsRunningPrediction() then
        predictionString = "*"
    end

    if Client then
        Shared.Message(StringFormat("Client%s : %f : %s", predictionString, Shared.GetTime(), result))
    elseif Predict then
        Shared.Message(StringFormat("Predict : %f : %s", Shared.GetTime(), result))
    elseif Server then
        Shared.Message(StringFormat("Server  : %f : %s", Shared.GetTime(), result))
    end

end

-- uses system time instead of world time
function HPrint2(formatString, ...)

    local result = StringFormat(formatString, ...)

    local predictionString = " "
    if Shared.GetIsRunningPrediction() then
        predictionString = "*"
    end

    if Client then
        Shared.Message(StringFormat("Client%s : %f : %s", predictionString, Shared.GetSystemTimeReal(), result))
    elseif Predict then
        Shared.Message(StringFormat("Predict : %f : %s", Shared.GetSystemTimeReal(), result))
    elseif Server then
        Shared.Message(StringFormat("Server  : %f : %s", Shared.GetSystemTimeReal(), result))
    end

end

-- Save to server log for 3rd party utilities
function PrintToLog(formatString, ...)
    Print(formatString, ...)
end

function LogS(formatString, ...)
    local args = {}
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        table.insert(args, ToString(v))
    end
    if #args > 0 then
        HPrint2(formatString, unpack(args))
    else
        HPrint2(formatString)
    end
end

--[[
	Enable a logger that can be turned on /off
	Usage:
	self.logTable = {}
	self.logStats = Logger("stats", self.logTable, false)
	self.logStats = Logger("base", self.logTable, true)
	self.enabledLogs.stats = true
	self.logStats("logs %s", msg)
]]
function Logger(name, logTable, enabled)
    local result = function(format, ...) if logTable[name] then Log(format, ...) end end
    logTable[name] = enabled and true or false
    return result
end

--[[
	Allow turning on/off loggers belonging to the given logTable.
	It returns a description of changed logs and the available logs.
]]
function LogCtrl(prefix, on, logTable)
    local msg
    if prefix and string.len(prefix) > 0 then
        for name,v in pairs(logTable) do
            if prefix == "all" or prefix == "*" or string.find(name, prefix) == 1 then
                logTable[name] = on
                msg = (msg and msg .. ", " .. name) or "Set " .. name
            end
        end
    end
    msg = msg or "No logs changed"
    for name,v in pairs(logTable) do
        msg = msg .. "\n" .. name .. " = " .. (v and "on" or "off")
    end
    return msg
end



function ConditionalValue(expression, value1, value2)

    if(expression) then
        return value1
    else
        return value2
    end

end

function SafeId(entity, default)
    if entity ~= nil then
        return entity:GetId()
    end
    return default
end

function SafeClassName(entity)
    if entity ~= nil and entity.GetClassName then
        return entity:GetClassName()
    end
    return "nil"
end

function SafeCSSClassName(menuElement)
    if menuElement and menuElement.GetCSSClass then
        local className = menuElement:GetCSSClass()
        return ConditionalValue(className, className, "none")
    end
    return "none"
end

function GetDisplayName(entity)

    local name = "nil"

    if entity ~= nil then

        if entity:isa("Player") then
            name = entity:GetName()
        else

            name = GetDisplayNameForTechId(entity:GetTechId())
            if not name then
                name = entity:GetClassName()
            end

        end

    end

    return name

end

function GetDisplayNameForAlert(techId, defaultText)
    local displayName = LookupTechData(techId, kTechDataAlertText, defaultText)

    local localizedName
    if displayName ~= nil then
        localizedName = Locale.ResolveString(displayName)
    end

    if type(localizedName) == "string" then
        displayName = localizedName
    else
        if (displayName ~= nil) then
            displayName = "#" .. displayName
        else
            displayName = "#" .. ToString(EnumToString(kTechId, techId))
        end
    end

    return displayName
end

--Get localized name for tech data display name's
function GetDisplayNameForTechId(techId, defaultText)
    
    PROFILE("GetDisplayNameForTechId")
    
    local displayName = LookupTechData(techId, kTechDataDisplayName, defaultText)

    --Now localize.
    local localizedName
    if displayName ~= nil then
        localizedName = Locale.ResolveString(displayName)
    end

    if type(localizedName) == "string" then
        displayName = localizedName
    else

        if displayName ~= nil then
            displayName = "#" .. displayName
        elseif techId ~= kTechId.None then
            displayName = "#" .. ToString(EnumToString(kTechId, techId))
        end

    end

    return displayName

end

function GetTooltipInfoText(techId)

    local text = LookupTechData(techId, kTechDataTooltipInfo, "")

    local localizedText = text ~= "" and Locale.ResolveString(text)
    if type(localizedText) == "string" and localizedText ~= "NO STRING" then
        text = localizedText
    end

    --Display special message if not yet implemented
    local implemented = LookupTechData(techId, kTechDataImplemented, true) or Shared.GetDevMode()

    if implemented == false then
        if tech ~= "" then
            text = text .. Locale.ResolveString("COMING_SOON_1")
        else
            text = text .. Locale.ResolveString("COMING_SOON_2")
        end
    else

        local newString = LookupTechData(techId, kTechDataNew)
        if newString then

            -- Localize "new" string if possible
            local localizedNewString = Locale.ResolveString(newString)
            if type(localizedNewString) == "string" then
                newString = localizedNewString
            end
            text = text .. " (" .. newString .. ")"

        end

    end

    return text

end

function CreatePickRay(player, xRes, yRes)

    local pickVec = Client.CreatePickingRayXY(xRes, yRes)

    -- Do traceline against world to see where it ends (for debugging)
    --local trace = Shared.TraceRay(player:GetOrigin(), player:GetOrigin() + pickVec * 1000, CollisionRep.Select, PhysicsMask.AllButPCs, EntityFilterOne(player))
    --DebugLine(player:GetOrigin(), trace.endPoint, 3, 1, 1, 1, 1)   

    return pickVec

end

--[[
	Assumes input angles are in radians and will move angle towards target the shortest direction (CW or CCW). Speed must be positive.
	Ex. current 1, desired 4, speed 2 => angleDiff 3, sign = +1, moveAmount = 2, return 1 + 2 = 3
	current -1, desired -3, speed 1 => angleDiff -2, sign = -1, moveAmount = -1, return -1 - 1 = -2
]]
function InterpolateAngle(currentAngle, desiredAngle, speed)

    local angleDiff = desiredAngle - currentAngle

    local angleDiffSign = GetSign(angleDiff)

    -- Don't move past angle
    local moveAmount = Min(math.abs(angleDiff), math.abs(speed))*angleDiffSign

    return currentAngle + moveAmount

end

--[[
	Returns the difference in two angles wrapping around from PI * 2 to 0.
]]
function RadianDiff(angle1, angle2)

    if angle1 - angle2 > math.pi then
        angle1 = angle1 - 2 * math.pi
    elseif angle2 - angle1 > math.pi then
        angle1 = angle1 + 2*math.pi
    end

    return angle1 - angle2

end

--Moves value towards target by rate, regardless of sign of rate
function Slerp(current, target, rate)

    if(rate < 0) then
        rate = -rate
    end

    if(math.abs(target - current) < rate) then
        return target
    end

    return current + GetSign(target - current)*rate

end

function SlerpRadians(current, target, rate)

    -- normalize the current and target angles to between -pi to pi
    current = ((current + math.pi) % (2 * math.pi)) - math.pi
    target = ((target + math.pi) % (2 * math.pi)) - math.pi

    -- Interpoloate the short way around
    if(target - current > math.pi) then
        target = target - 2*math.pi
    elseif(current - target > math.pi) then
        target = target + 2*math.pi
    end

    return Slerp(current, target, rate)

end

function SlerpAngles(current, target, rate)

    local result = Angles()

    result.pitch = SlerpRadians(current.pitch, target.pitch, rate)
    result.yaw = SlerpRadians(current.yaw, target.yaw, rate)
    result.roll = SlerpRadians(current.roll, target.roll, rate)

    return result

end

function SlerpDegrees(current, target, rate)

    -- Interpolate the short way around
    if(target - current > 180) then
        target = target - 360
    elseif(current - target > 180) then
        target = target + 360
    end

    return Slerp(current, target, rate)

end

function SlerpVector(current, target, rate)

    local result = Vector()

    if type(rate) == "number" then

        result.x = Slerp(current.x, target.x, rate)
        result.y = Slerp(current.y, target.y, rate)
        result.z = Slerp(current.z, target.z, rate)

    elseif rate:isa("Vector") then

        result.x = Slerp(current.x, target.x, rate.x)
        result.y = Slerp(current.y, target.y, rate.y)
        result.z = Slerp(current.z, target.z, rate.z)

    end

    return result

end

function Lerp(a, b, t)
    return a * (1.0 - t) + b * t
end

function LerpColor(startColor, targetColor, percentage)

    return Color(startColor.r + (targetColor.r - startColor.r) * percentage,
        startColor.g + (targetColor.g - startColor.g) * percentage,
        startColor.b + (targetColor.b - startColor.b) * percentage,
        startColor.a + (targetColor.a - startColor.a) * percentage)

end

function LerpNumber(start, target, percentage)
    return start + ((target - start) * percentage)
end

--[[
	Lerps between any two color, vector or numerical values. Can also lerp between
	two tables with any of these values (but must have the same number of elements
	and same order of types).
]]
function LerpGeneric(startValue, targetValue, percentage)

    local lerpedValue = 0

    ASSERT(percentage >= 0)
    ASSERT(percentage <= 1)

    --If table, call recursively on values in it
    if type(startValue) == "table" then

        if table.icount(startValue) ~= table.icount(targetValue) then
            Print("LerpGeneric(): startValue and targetValue tables not the same size (%s, %s)", ToString(startValue), ToString(targetValue))
        else

            lerpedValue = {}
            for index, value in ipairs(startValue) do
                table.insert(lerpedValue, LerpGeneric(startValue[index], targetValue[index], percentage))
            end

        end

    elseif type(startValue) == "number" then
        lerpedValue = LerpNumber(startValue, targetValue, percentage)
    elseif startValue:isa("Color") then
        lerpedValue = LerpColor(startValue, targetValue, percentage)
    elseif startValue:isa("Vector") then

        lerpedValue = Vector(startValue.x + (targetValue.x - startValue.x) * percentage,
            startValue.y + (targetValue.y - startValue.y) * percentage,
            startValue.z + (targetValue.z - startValue.z) * percentage)
    else
        Print("LerpGeneric(): Can't handle type \"%s\".", type(startValue))
    end

    return lerpedValue

end

function GetClientServerString()
    return ConditionalValue(Client, "Client", "Server")
end

function IsNumber(var)
    return var ~= nil and type(var) == "number"
end

function IsBoolean(var)
    return var ~= nil and type(var) == "boolean"
end

local cDataTypes =
{
    "Vector",
    "Color",
    "Trace",
    "Angles",
    "Coords",
}
function GetCDataClassName(x)
    for i=1, #cDataTypes do
        if x:isa(cDataTypes[i]) then
            return cDataTypes[i]
        end
    end
    return "UnknownType"
end

local function ExpandedPrintHelper(v, vName, seen, indent)
    
    vName = vName or "value"
    
    if v == nil then
        HPrint("%s%s = nil", string.rep("  ", indent), vName)
        return
    end
    
    local seenBefore = seen[v] ~= nil
    seen[v] = true
    
    if type(v) == "table" and not seenBefore then
        if vName then
            HPrint("%s%s =", string.rep("  ", indent), vName)
        end
        HPrint("%s{", string.rep("  ", indent))
        for key, value in pairs(v) do
            ExpandedPrintHelper(value, key, seen, indent + 1)
        end
        HPrint("%s}", string.rep("  ", indent))
    else
        HPrint("%s%s = %s", string.rep("  ", indent), vName, ToString(v))
    end
    
end

-- Prints value and all sub-values.  Tables are neatly indented and formatted across multiple lines.
function ExpandedPrint(v, name)
    ExpandedPrintHelper(v, name, {}, 0)
end

local ctint64, ctuint64 = 1ll, 1llu

function ToString(t)
    
    if t == nil then
        return "nil"
    elseif type(t) == "string" then
        return t
    elseif type(t) == "table" then
        if t.classname then
            if type(t.__tostring) == "function" then
                return t:__tostring()
            else
                return string.format("class %s", t.classname)
            end
        else
            return TableToString(t)
        end
    elseif type(t) == "function" then
        return DebugFunctionToString(t)

    elseif type(t) == "cdata" then

        if ffi.istype(ctint64, t) or ffi.istype(ctuint64, t) then
            return tostring(t)
        end

        if t.isa then
            if t:isa("Vector") then
                return StringFormat("%f, %f, %f", t.x, t.y, t.z)
            elseif t:isa("Trace") then
                return StringFormat("trace fraction: %.2f entity: %s", t.fraction, SafeClassName(t.entity))
            elseif t:isa("Color") then
                return StringFormat("color rgba: %.2f, %.2f, %.2f, %.2f", t.r, t.g, t.b, t.a)
            elseif t:isa("Angles") then
                return StringFormat("angles yaw/pitch/roll: %.2f, %.2f, %.2f", t.yaw, t.pitch, t.roll)
            elseif t:isa("Coords") then
                return CoordsToString(t)
            end
        end

        --defer to __tostring
        return tostring(t)

    elseif type(t) == "userdata" then
        if t.__tostring then
            return t:__tostring()
        elseif type(getmetatable(t)) ~= "table" then
            return tostring(t)
        elseif t.isa and t:isa("Entity") then
            return t:GetClassName() .. "-" .. t:GetId()
        elseif t.GetClassName then
            return t:GetClassName()
        elseif t.GetTagName then
            return StringFormat("tag: %s CSS class: %s", t:GetTagName(), SafeCSSClassName(t))
        else
            return tostring(t)
        end
    elseif type(t) == "boolean" then
        return tostring(t)
    elseif type(t) == "number" then

        --Insert commas in proper places
        local s = tostring(t)
        local suffix = ""

        local index = string.len(s) - 3

        --Take into account decimal place, if any
        local decimalIndex = string.find(s, "(%.)")
        if decimalIndex ~= nil then
            index = decimalIndex - 4
            suffix = string.sub(s, decimalIndex)
            s = string.sub(s, 1, decimalIndex - 1)
        end

        while index >= 1 do

            local prefix = string.sub(s, 1, index)
            local postfix = string.sub(s, index + 1)
            s = StringFormat("%s,%s", prefix, postfix)
            index = index - 3

        end

        return s .. suffix
    end

    Print("ToString() on type \"%s\" failed.", type(t))
end

function CopyCData(cdata)
    if cdata:isa("Vector") then
        return Vector(cdata)
    elseif cdata:isa("Angles") then
        return Angles(cdata)
    elseif cdata:isa("Coords") then
        return Coords(cdata)
    elseif cdata:isa("Color") then
        return Color(cdata)
    elseif cdata:isa("Trace") and Trace then
        return Trace(cdata)
    else
        return cdata
    end
end

function Copy(t)
    
    PROFILE("Utility:Copy")
    
    if t == nil then
        return nil
    elseif type(t) == "string" then
        return t
    elseif type(t) == "table" then
        if type(t.__copy) == "function" then
            return t:__copy()
        else
            local newTable = {}
        table.copy(t, newTable, true)
            return newTable
        end
    elseif type(t) == "cdata" then
        return CopyCData(t)
    end

    return t

end

function GetAnglesDifference(startAngle, endAngle)

    local tolerance = 0.1
    local diff = endAngle - startAngle

    if(math.abs(diff) > 100) then
        Print("Warning - GetAnglesDiff(%.2f, %.2f) called with large numbers, should be optimized.", startAngle, endAngle)
    end

    while(math.abs(diff) > (2*math.pi - tolerance)) do
        diff = diff - GetSign(diff)*2*math.pi
    end

    -- Return shortest path around circle
    if(math.abs(diff) > math.pi) then
        diff = diff - GetSign(diff)*2*math.pi
    end

    return diff

end

--Takes a normalized vector
function SetAnglesFromVector(entity, vec)

    local angles = Angles(entity:GetAngles())
    angles.yaw = GetYawFromVector(vec)
    entity:SetAngles(angles)

end

function SetViewAnglesFromVector(entity, vec)

    local angles = Angles(entity:GetViewAngles())
    angles.yaw = GetYawFromVector(vec)
    angles.pitch = GetPitchFromVector(vec)
    entity:SetViewAngles(angles)

end

function SetRandomOrientation(entity)

    local angles = Angles(entity:GetAngles())
    angles.yaw = math.random() * math.pi * 2
    entity:SetAngles(angles)

end

function SampleCircleUniform(cx, cy, radius)

    local r = math.sqrt(math.random()) * radius
    local angle = math.random() * 2*math.pi
    return
    cx + r*math.cos(angle),
    cy + r*math.sin(angle)

end

function GetYawFromVector(vec)

    local dx = vec.x
    local dz = vec.z

    if math.abs(dx) < 0.001 and math.abs(dz) < 0.001 then
        -- If the vector is vertical, then the rotation around the vertical
        -- axis is arbitrary.
        return 0.0
    else

        local result = math.atan2(dx, dz)
        if result < 0 then
            return result + math.pi * 2
        end

        return result

    end

end

function GetPitchFromVector(vec)
    local y = Clamp(vec.y, -1, 1)
    return -math.asin(y)
end

function DrawCoords(coords, larger)
    DebugLine(coords.origin, coords.origin + coords.xAxis, .2, 1, 0, 0, 1)
    DebugLine(coords.origin, coords.origin + coords.yAxis, .2, 0, 1, 0, 1)
    DebugLine(coords.origin, coords.origin + coords.zAxis, .2, 0, 0, 1, 1)
    if larger then
        DebugLine(coords.origin, coords.origin + -coords.xAxis, .2, 1, 0, 0, 1)
        DebugLine(coords.origin, coords.origin + -coords.yAxis, .2, 0, 1, 0, 1)
        DebugLine(coords.origin, coords.origin + -coords.zAxis, .2, 0, 0, 1, 1)
    end
end

function DebugDrawAxes(coords, origin, length, duration, colorScale)
    if colorScale == nil then
        colorScale = 1.0
    end
    DebugLine(origin, origin + length*coords.xAxis, duration, colorScale, 0, 0, 1)
    DebugLine(origin, origin + length*coords.yAxis, duration, 0, colorScale, 0, 1)
    DebugLine(origin, origin + length*coords.zAxis, duration, 0, 0, colorScale, 1)
end

-- Draws angles as a coordinate frame
function DebugDrawAngles(angles, origin, length, duration, colorScale)
    DebugDrawAxes( angles:GetCoords(), origin, length, duration, colorScale )
end

-- Returns degrees between -360 and 360
function DegreesTo360(degrees, positiveOnly)

    while(degrees < -360 or (positiveOnly and degrees < 0)) do
        degrees = degrees + 360
    end

    while(degrees > 360) do
        degrees = degrees - 360
    end

    return degrees

end

-- Returns radians in [0,2*pi)
function RadiansTo2PiRange(rads)

    while rads >= 2*math.pi do
        rads = rads - 2*math.pi
    end

    while rads < 0 do
        rads = rads + 2*math.pi
    end

    return rads

end

function AnglesTo2PiRange(angles)
    angles.yaw = RadiansTo2PiRange(angles.yaw)
    angles.pitch = RadiansTo2PiRange(angles.pitch)
    angles.roll = RadiansTo2PiRange(angles.roll)
end

function DebugTraceRay(p0, p1, mask, filter)

    if not filter then
        filter = EntityFilterOne(nil)
    end

    local trace = Shared.TraceRay(p0, p1, CollisionRep.Default, mask, filter)

    if Client then
        if trace.fraction ~= 1 and trace.entity then
            DebugLine(p0, p1, 10, 1, 0, 0, 1)
        else
            DebugLine(p0, p1, 10, 0, 1, 0, 1)
        end
    end

    return trace

end

function DrawEntityAxes(entity)

    -- Draw x red, y green, z blue (like 3ds Max)
    local lineLength = 2
    local coords = entity:GetAngles():GetCoords()
    local p0 = entity:GetOrigin()

    DebugLine(p0, p0 + coords.xAxis*lineLength, .1, 1, 0, 0, 1)
    DebugLine(p0, p0 + coords.yAxis*lineLength, .1, 0, 1, 0, 1)
    DebugLine(p0, p0 + coords.zAxis*lineLength, .1, 0, 0, 1, 1)

end

function GetIsDebugging()
    return (decoda_output ~= nil)
end

function GetSign(number)

    if(number > 0) then
        return 1
    elseif(number < 0) then
        return -1
    end

    return 0

end

-- Pass no parameters for 0-1 random value, otherwise pass integers for random number between those numbers (inclusive).
-- NOTE: It's important to make sure that this is called the same number of times and for the same reasons both on client
-- and server during OnProcessMove().
function NetworkRandom(logMessage)

    local result = Shared.GetRandomFloat()

    if gNetworkRandomLogData and gRandomDebugEnabled then

        local baseLogMessage = StringFormat("NetworkRandom() => %s", tostring(result))

        LogRandom(baseLogMessage, logMessage)

    end

    return result

end

function NetworkRandomInt(minValue, maxValue, logMessage)

    local result = Shared.GetRandomInt( Min(minValue, maxValue), Max(minValue, maxValue) )

    if gNetworkRandomLogData and gRandomDebugEnabled then

        local baseLogMessage = StringFormat("NetworkRandomInt(%s, %s) => %s", ToString(minValue), ToString(maxValue), ToString(result))

        LogRandom(baseLogMessage, logMessage)

    end

    return result

end

function LogRandom(baseLogMessage, logMessage)

    if gNetworkRandomLogData and gRandomDebugEnabled then

        local s = baseLogMessage

        if logMessage then
            s = StringFormat("%s (%s)", s, ToString(logMessage))
        end

        table.insert(gNetworkRandomLogData, s)

    end

end

function EncodePointInString(point)
    return StringFormat("%0.2f_%0.2f_%0.2f_", point.x, point.y, point.z)
end

function DecodePointFromString(string)

    local numParsed = 0
    local point = Vector()

    for stringCoord in string.gmatch(string, "[0-9.\\-]+") do

        local coord = tonumber(stringCoord)
        numParsed = numParsed + 1

        if(numParsed == 1) then
            point.x = coord
        elseif(numParsed == 2) then
            point.y = coord
        else
            point.z = coord
        end

        if(numParsed == 3) then
            return true, point
        end

    end

    return false, nil

end

-- Grabbed these from the lua wiki 
-- http://lua-users.org/wiki/StringRecipes
function url_decode(str)
    str = string.gsub (str, "+", " ")
    str = string.gsub (str, "%%(%x%x)",
        function(h) return string.char(tonumber(h,16)) end)
    str = string.gsub (str, "\r\n", "\n")
    return str
end

function url_encode(str)
    if (str) then
        str = string.gsub (str, "\n", "\r\n")
        str = string.gsub (str, "([^%w ])",
            function (c) return StringFormat ("%%%02X", string.byte(c)) end)
        str = string.gsub (str, " ", "+")
    end
    return str
end

function EncodeStringForNetwork(inputString)
    return url_encode(inputString)
end

function DecodeStringFromNetwork(inputString)
    if(inputString == nil) then
        return nil
    end

    return url_decode(inputString)
end

function GetColorForPlayer(player)

    if(player ~= nil) then
        if player:GetTeamNumber() == kTeam1Index then
            return kMarineTeamColor
        elseif player:GetTeamNumber() == kTeam2Index then
            return kAlienTeamColor
        end
    end

    return kNeutralTeamColor

end

-- This assumes marines vs. aliens
function GetColorForTeamNumber(teamNumber)
    
    PROFILE("GetColorForTeamNumber")
    
    if teamNumber == kTeam1Index then
        return kMarineTeamColor
    elseif teamNumber == kTeam2Index then
        return kAlienTeamColor
    end

    return kNeutralTeamColor

end

-- Generate unique name that isn't taken by another player on the server. If it is,
-- return number variant "NsPlayer (2)". Optionally pass a list of names for testing.
-- If not passing a list of names, this is on the server only.
function GetUniqueNameForPlayer(name, nameList)

    -- Make sure name isn't in use
    if(nameList == nil) then

        nameList = {}

        for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            local name = player:GetName()
            if(name ~= nil and name ~= "") then
                table.insert(nameList, string.lower(name))
            end
        end

    end

    -- Case-insensitive check for specified name in nameList
    local function nameInTable(name)

        for index, entryName in ipairs(nameList) do

            if(string.lower(entryName) == string.lower(name)) then
                return true
            end

        end

        return false

    end

    local returnName = name

    if(nameInTable(name)) then

        for i = 1, kMaxPlayers do

            -- NsPlayer (2)
            local newName = StringFormat("%s (%d)", name, i+1)

            if(not nameInTable(newName)) then

                returnName = newName
                break

            end

        end

    end

    return returnName

end

-- http://lua-users.org/wiki/InfAndNanComparisons
function IsValidValue(value)

    if(type(value) == "number") then

        if(value ~= value) then
            return false, "NaN"
        elseif(value >= math.huge) then
            return false, "infinity"
        elseif(value <= -math.huge) then
            return false, "-infinity"
        end

    end

    return true

end

function ValidateValue(value, logMessage)

    if(type(value) == "number") then

        local valid, reason = IsValidValue(value)
        if(not valid) then
            if(logMessage) then
                Print("Numeric value not valid (%s) - %s", reason, logMessage)
            end
            return false
        end

    else

        local valid, reason = IsValidValue(value.x)
        if(not valid) then
            if(logMessage) then
                Print("Vector.x not valid (%s) - %s", reason, logMessage)
            end
            return false
        end

        valid, reason = IsValidValue(value.y)
        if(not valid) then
            if(logMessage) then
                Print("Vector.y not valid (%s) - %s", reason, logMessage)
            end
            return false
        end

        valid, reason = IsValidValue(value.z)
        if(not valid) then
            if(logMessage) then
                Print("Vector.z not valid (%s) - %s", reason, logMessage)
            end
            return false
        end

    end

    return true

end

-- Parse number value from editor_setup and emit error if outside expected range
function GetAndCheckValue(valueString, min, max, valueName, defaultValue, silent)

    local numValue = tonumber(valueString)

    if(numValue == nil) then

        numValue = defaultValue

        if(not silent) then
            Shared.Message(StringFormat("GetAndCheckValue(%s): Value is nil, returning default of %s.", valueName, numValue))
        end

    elseif(numValue < min or numValue > max) then

        local clampedValue = Max(Min(numValue, max), min)

        if (not silent) then
            Shared.Message(StringFormat("%s - Value %.2f is outside expected range (%.2f, %.2f), clamping to %.2f: ", valueName, numValue, min, max, clampedValue))
        end
        numValue = clampedValue

    end

    return numValue

end

function GetAndCheckBoolean(valueString, valueName, defaultValue)

    local returnValue = false

    if valueString == nil  then
        returnValue = defaultValue
    elseif type(valueString) == "string" then
        returnValue = ConditionalValue(string.find(valueString, "true") ~= nil, true, false)
    elseif type(valueString) == "boolean" then
        returnValue = valueString
    end

    return returnValue

end

function StringStartsWith(inString, startString)

    if(type(inString) ~= "string" or type(startString) ~= "string") then
        Print("StringStartsWith(%s, %s) not called with strings.", tostring(inString), tostring(startString))
        return false
    end

    return string.lower(string.sub(inString, 1, string.len(startString))) == string.lower(startString)

end

function StringEndsWith(inString, endString)

    if(type(inString) ~= "string" or type(endString) ~= "string") then
        Print("StringEndsWith(%s, %s) not called with strings.", tostring(inString), tostring(endString))
        return false
    end

    return string.lower(string.sub(inString, -string.len(endString))) == string.lower(endString)

end

--[[
	Return a string that removes any leading or trailing whitespace characters from the passed in string.
]]
function StringTrim(inString)

    assert(type(inString) == "string")

    -- Strip out escape characters.
    inString = inString:gsub("[\a\b\f\n\r\t\v]", "")
    return inString:gsub("^%s*(.-)%s*$", "%1")

end

function TrimName(nameString)

    assert(type(nameString) == "string")

    local whitespaceCleanName = StringTrim(nameString)

    return whitespaceCleanName:gsub("\"", "")

end

-- Returns base value when dev is off, base value * scalar when it's on
function GetDevScalar(value, scalar)
    return ConditionalValue(Shared.GetDevMode(), value * scalar, value)
end

-- Capsule start and end define the "core" of the capsule. The ends of the capsule are 
-- rounded and are a half-sphere with radius capsuleRadius.
-- Default is human/bipedal movement, so return upright capsule
function GetTraceCapsuleFromExtents(extents)

    local radius = Max(extents.x, 0)

    if radius == 0 then
        Print("%GetTraceCapsuleFromExtents(): radius is 0.")
    end

    local height = Max(extents.y * 2, 0)
    return height, radius

end

function GetFileExists(path)
    local searchResult = {}
    Shared.GetMatchingFileNames( path, false, searchResult )
    return #searchResult > 0
end

function PrecacheAssetIfExists(effectName)
    if GetFileExists(effectName) then
        PrecacheAsset(effectName)
    end
end

local sharedlib = Shared or {}

local precacheLookup = {
    [".cinematic"] = sharedlib.PrecacheCinematic,
    [".model"] = sharedlib.PrecacheModel,
    [".material"] = sharedlib.PrecacheMaterial,
    [".animation_graph"] = sharedlib.PrecacheAnimationGraph,
    [".dds"] = sharedlib.PrecacheTexture,
    [".fnt"] = sharedlib.PrecacheFont,
    [".font"] = sharedlib.PrecacheFont,
    [".surface_shader"] = sharedlib.PrecacheSurfaceShader,
}

local dot = string.byte(".")

function PrecacheAsset(effectName)

    if type(effectName) ~= "string" then

        error(string.format("PrecacheAsset(%s): effect name isn't a string (%s instead).", tostring(effectName), type(effectName)))
        return nil

    end

    local extidx = string.find(effectName, ".", 1, true)
    local precacher

    if extidx then
        -- Assume all almost all paths only have 1 dot
        if string.find(effectName, ".", extidx+1, true) then
            for i = #effectName, 1, -1 do
                if effectName[i] == dot then
                    extidx = i
                    break
                end
            end
        end
        precacher = precacheLookup[string.lower(string.sub(effectName, extidx))]
    end

    if not precacher and StringStartsWith(effectName, "sound") then
        precacher = Shared.PrecacheSound
    end

    if precacher then
        precacher(effectName)
    else
        Shared.Message("Warning: Was not able to find the type of asset for " .. effectName .. " while precacheing\n" .. Script.CallStack())
    end

    return effectName
end

-- Precache multiple assets, using table as a substitution
function PrecacheMultipleAssets(effectName, substTable)

    for index, substString in ipairs(substTable) do

        PrecacheAsset(StringFormat(effectName, substString))

    end

end

if Server then

    --[[
		Creates entity, initializes it and adds it to the proper team via gamerules.
		Pass the mapName, not className (teamNumber and origin optional - defaults to -1 and the origin)
    ]]
    function CreateEntity(mapName, origin, teamNumber, extraValues, suppressError)

        teamNumber = teamNumber or -1
        origin = origin or Vector(0, 0, 0)

        assert(type(mapName) == "string")
        assert(type(teamNumber) == "number")
        assert(origin:isa("Vector"))

        local values = { origin = origin, teamNumber = teamNumber }
        -- Add in any extra values passed in.
        if extraValues then

            for name, value in pairs(extraValues) do
                values[name] = value
            end

        end

        -- Calls OnCreate() automatically.
        local entity = Server.CreateEntity(mapName, values)

        if entity then

            -- Add entity to team, add/remove tech from tech tree, etc.
            GetGamerules():OnEntityCreate(entity)

        else
            if not suppressError then
                Log("CreateEntity(%s, %s, %s) returned nil.", ToString(mapName), ToString(origin), ToString(teamNumber))
                return nil
            else
                return nil
            end
        end

        return entity

    end

    --[[
		Script should only use this function, never call Server.DestroyEntity directly.
    ]]
    function DestroyEntity(entity)

        assert(entity ~= nil)

        if GetGamerules() then
            GetGamerules():OnEntityDestroy(entity)
        end

        -- Calls OnDestroy()
        Server.DestroyEntity(entity)

    end

    --[[
		Destroys an entity unless it is a map entity. In this case the entity will be disabled
		but not destroyed.
    ]]
    function DestroyEntitySafe(entity)

        if entity:GetIsMapEntity() then

            entity:SetIsAlive(false)
            entity:SetIsVisible(false)
            entity:SetPhysicsType(PhysicsType.None)

        else
            DestroyEntity(entity)
        end

    end
end

--[[
	Scale the passed in value down based on two other values.
]]
function math.scaledown(value, av, mv)
    if mv ~= 0 and av >= mv then
        return value
    end
    if mv == 0 then
        mv = av
    end
    return math.percentf((av/mv)*100,value)
end

--[[
	Rounds to nearest number by the passed in decimal places.
]]
function math.round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

--[[
	Returns the value from the percentage p of v where p is between 0 and 100.
]]
function math.percentf(p, v)
    return (p/100)*v
end

--[[
	ColorValue(0-255) : Convert standard convention to decimal.
]]
function ColorValue(val)
    ASSERT(type(val) == "number")
    return (val/255)
end

function ColorFrom255(r, g, b, a)
    return Color(ColorValue(r), ColorValue(g), ColorValue(b), ColorValue(a or 255))
end

--[[
	AlphaValue(0-100) : Percentage Transparency ~ Convert standard convention to decimal.
]]
function AlphaValue(val)
    ASSERT(type(val) == "number")
    return (val/100)
end

--[[
	Call MonitorCallHistoryBegin() to begin monitoring the calls and MonitorCallHistoryEnd()
	to return a list of functions called in order after MonitorCallHistoryBegin() was called.
	Calling MonitorCallHistoryEnd() stops the monitoring process and returns a string.
]]
local callHistoryMonitorString = ""
local callstackDepth = 1
local allowedFunctionTypes = { "local", "global", "method", "field", "upvalue" }
local filterFunctionNames = { "MonitorCallHistoryEnd", "sethook", "(for generator)" }
local function MonitorCallHistoryHook(type)

    if type == "call" then
        callstackDepth = callstackDepth + 1
        local function generateOffset(offsetString, currentDepth) if currentDepth <= callstackDepth then return generateOffset(" " .. offsetString, currentDepth + 1) end return offsetString end
        local offsetString = generateOffset("", 1)
        local functionName = debug.getinfo(2, "n").name or "No name"
        local functionType = debug.getinfo(2, "n").namewhat
        local otherInfo = functionType .. " - " .. debug.getinfo(2, "S").short_src .. ":" .. debug.getinfo(2, "l").currentline
        if table.icontains(allowedFunctionTypes, functionType) and not table.icontains(filterFunctionNames, functionName) then
            if string.len(callHistoryMonitorString) ~= 0 then
                callHistoryMonitorString = callHistoryMonitorString .. "\n"
            end
            callHistoryMonitorString = callHistoryMonitorString .. offsetString .. functionName .. " - " .. otherInfo
        end
    elseif type == "return" then
        callstackDepth = callstackDepth - 1
    end

end

function MonitorCallHistoryBegin()

    debug.sethook(MonitorCallHistoryHook, "cr")

end

function MonitorCallHistoryEnd()

    debug.sethook()
    local returnHistory = callHistoryMonitorString
    callHistoryMonitorString = ""
    callstackDepth = 1
    return returnHistory

end


local prevSumTable
function DumpEntityCounts(entityType)

    local sumTable = { }

    for index, entity in ientitylist(Shared.GetEntitiesWithClassname(entityType or "Entity")) do

        local cName = entity:GetClassName()
        sumTable[cName] = sumTable[cName] or { }

        sumTable[cName].count = (sumTable[cName].count or 0) + 1

        sumTable[cName].ids = sumTable[cName].ids or { }
        table.insert(sumTable[cName].ids, entity:GetId())

    end

    local total = 0
    for cName, typeTable in pairs(sumTable) do

        local count = typeTable.count
        local ids = typeTable.ids
        local prev = (prevSumTable and prevSumTable[cName] and prevSumTable[cName].count) or 0
        local delta = count - prev
        Log("%s : %s (%s%s)", cName, count, (delta < 0 and "-" or (delta > 0 and "+" or " ")), delta)

        -- Print all Ids for each type if an entity type was specified.
        if entityType then

            local idsMessage = cName .. " Ids:"
            for i, id in ipairs(ids) do
                idsMessage = idsMessage .. " " .. id
            end
            Log(idsMessage)

        end

        total = total + count

    end

    Log("Total %s", total)

    prevSumTable = sumTable

end

gDebugGUI = false
gDebugRectangle = nil
gDebugGUIMessage = ""
function DebugGUIRectangle(position, size)

    if gDebugRectangle == nil then
        gDebugRectangle = GUI.CreateItem()
        gDebugRectangle:SetColor(Color(1,1,0, 0.4))
        gDebugRectangle:SetLayer(50)
    end

    gDebugRectangle:SetPosition(position)
    gDebugRectangle:SetSize(size)

end

function DebugGUIMessage(element, string)

    if type(string) == "string" then
        gDebugGUIMessage = string
    else
        gDebugGUIMessage = ""
    end

    gDebugGUIMessage = gDebugGUIMessage .. "Tag Name: " .. element:GetTagName() .. ", "
    gDebugGUIMessage = gDebugGUIMessage .. "CSS Classes: " .. element:GetCSSClassNames() .. "\n"
    gDebugGUIMessage = gDebugGUIMessage .. "Width: " .. element:GetWidth() .. ", "
    gDebugGUIMessage = gDebugGUIMessage .. "Height: " .. element:GetHeight() .. "\n"

    local position = element:GetBackground():GetPosition()
    gDebugGUIMessage = gDebugGUIMessage .. "Position: (" .. position.x .. ", ".. position.y .. ")\n"
    gDebugGUIMessage = gDebugGUIMessage .. "-----\n\n"

    local parent = element:GetParent()
    if parent then
        DebugGUIMessage(parent, gDebugGUIMessage)
    end

end

function asserttype(varname, requiredType, var)

    local typeMatches = type(var) == requiredType

    if not typeMatches then
        Print("%s has type %s, required type %s, value %s", ToString(varname), ToString(type(var)), ToString(requiredType), ToString(var))
        assert(false)
    end

end

--[[
	Pass in strings and numbers and they will be concatenated together.
]]
function StringConcatArgs(...)

    local returnString

    local args = {...}
    for i, v in ipairs(args) do

        returnString =  returnString and StringFormat("%s %s", returnString, v) or v

    end

    return returnString

end

function ReplaceAllCharsInStringWith(str, char, repWith)

    local outString = str
    local idx = 1
    while idx <= #outString do
        local findIdx = string.find(outString, char, idx)
        if findIdx == nil then
            break
        end

        outString = string.format("%s%s%s", string.sub(outString, idx, findIdx - 1), repWith, string.sub(outString, findIdx+1, #outString))
    end

    return outString

end

local kInsaneChars =
{
    { "+",      "_plus",    },
    { "<",      "_lt",      },
    { ">",      "_gt",      },
    { "|",      "_pipe",    },
    { "\\",     "_bckslsh", },
    -- TODO far from a complete list...
}

function SanitizePathStringForOptionName(str)

    -- Add something to end if the last element is blank.
    local lastChar = string.sub(str, #str, #str)
    if lastChar == "" or lastChar == "/" then
        str = str .. "__blank"
    end

    -- Replace disallowed characters.
    for i=1, #kInsaneChars do
        local char = kInsaneChars[i][1]
        local repWith = kInsaneChars[i][2]
        str = ReplaceAllCharsInStringWith(str, char, repWith)
    end

    return str

end

--[[
	An additional layer on top of StringFormat() to reorder the arguments.
	This is good for localization where word order changes.
	StringReformat("%{name}s has %{points}d", { name = "Brian", points = 100 })
	will return "Brian has 100" while
	StringReformat("%{points}d in %{name}s", { name = "Brian", points = 100 })
	will return "100 in Brian" without changing the arguments passed in.
]]
function StringReformat(formatString, argTable)

    -- First determine the order that the argTable elements should
    -- be formated into the string.
    local argOrder = { }
    for item in string.gmatch(formatString, "{%w+}") do

        local cleanItem = string.gsub(item, "[}{]", "")
        table.insert(argOrder, cleanItem)

    end

    if #argOrder == 0 then return formatString end

    -- Remove the {items} from the string without removing the normal
    -- StringFormat() stuff.
    local cleanFormatString = string.gsub(formatString, "([{].-[}])", "")

    -- Pull the values out of the passed in argTable and assemble
    -- them based on the order determined in argOrder.
    local orderedArgs = { }
    for a = 1, #argOrder do
        if not argTable[argOrder[a]] then return formatString end

        table.insert(orderedArgs, argTable[argOrder[a]])
    end

    return StringFormat(cleanFormatString, unpack(orderedArgs))

end

--[[
	Pass in an integer encoded IP address and a string in the format of
	"127.0.0.1" will be returned.
]]
function IPAddressToString(address)

    if type(address) == "number" then

        local first = bit.rshift(bit.band(address, bit.lshift(0xff, 24)), 24)
        local second = bit.rshift(bit.band(address, bit.lshift(0xff, 16)), 16)
        local third = bit.rshift(bit.band(address, bit.lshift(0xff, 8)), 8)
        local fourth = bit.band(address, 0xff)
        return StringFormat("%d.%d.%d.%d", first, second, third, fourth)
    else
        return address
    end

end

function IsOnScreen(screenPosition)
    return screenPosition.x < Client.GetScreenWidth() and screenPosition.x > 0 and
            screenPosition.y < Client.GetScreenHeight() and screenPosition.y > 0
end

function GetClampedScreenPosition(worldPosition, buffer)

    assert(worldPosition:isa("Vector"))
    assert(type(buffer) == "number" or buffer == nil)
    assert(Client)

    if not buffer then
        buffer = 0
    end

    local cameraCoords = GetRenderCameraCoords()
    local screenPosition = Client.WorldToScreen(worldPosition)

    local toPosition = GetNormalizedVector(worldPosition - cameraCoords.origin)
    local dotProduct = cameraCoords.zAxis:DotProduct(toPosition)
    local screenDiagHalf = math.sqrt(Client.GetScreenWidth() ^ 2 + Client.GetScreenHeight() ^ 2) / 2

    if dotProduct < 0.1 or not IsOnScreen(screenPosition) then

        screenPosition.x = -cameraCoords.xAxis:DotProduct(toPosition)
        screenPosition.y = -cameraCoords.yAxis:DotProduct(toPosition)
        screenPosition:Normalize()

        screenPosition.x = screenPosition.x * screenDiagHalf + Client.GetScreenWidth() * .5
        screenPosition.y = screenPosition.y * screenDiagHalf + Client.GetScreenHeight() * .5

    end

    screenPosition.x = Clamp(screenPosition.x, buffer, Client.GetScreenWidth() - buffer)
    screenPosition.y = Clamp(screenPosition.y, buffer, Client.GetScreenHeight() - buffer)

    return screenPosition

end

function RoundVelocity(velocity)
    return math.ceil(velocity * 100) / 100
end

local gAtmosphericsEnabled = true

function ApplyAtmosphericDensity()
    
    if Client and Client.lightList and gAtmosphericsEnabled then
        
        local atmoModifier = Client.GetOptionFloat("graphics/atmospheric-density", kDefaultLightsAtmoDensity)
        
        if gAtmosphericsEnabled then
            for index, light in ipairs(Client.lightList) do
                
                if light.originalAtmosphericDensity then
                    light:SetAtmosphericDensity(light.originalAtmosphericDensity * atmoModifier)
                end
                
            end
        end
        
    end
    
end

function DisableAtmosphericDensity()

    if Client and Client.lightList and gAtmosphericsEnabled then

        for index, light in ipairs(Client.lightList) do

            if light.originalAtmosphericDensity then
                light:SetAtmosphericDensity(0)
            end
        end

        gAtmosphericsEnabled = false

    end

end

function EnableAtmosphericDensity()

    PROFILE("Utility:EnableAtmosphericDensity")

    if Client and Client.lightList and not gAtmosphericsEnabled then

        gAtmosphericsEnabled = true

        ApplyAtmosphericDensity()

    end

end

local TimedRunStackDepth = 0
function TimedRun( label,func )
    local startTime = Shared.GetSystemTimeReal()
    TimedRunStackDepth = TimedRunStackDepth + 1
    func()
    local spaces = ""
    for i = 1,TimedRunStackDepth-1 do
        spaces = spaces.."  "
    end
    Print("%s%s took %0.4fms", spaces, label, (Shared.GetSystemTimeReal()-startTime)*1000)
    TimedRunStackDepth = TimedRunStackDepth - 1
end

local kVectorList =
{
    -- vec.y >= 0 88
    -- vec.z >= 0 48
    -- vec.x >= 0 26
    -- vec.y >= 0.5  13
    Vector(0.000000, 1.000000, 0.000000),
    Vector(0.000000, 0.955423, 0.295242),
    Vector(0.238856, 0.864188, 0.442863),
    Vector(0.000000, 0.850651, 0.525731),
    Vector(0.147621, 0.716567, 0.681718),
    Vector(0.500000, 0.809017, 0.309017),
    Vector(0.262866, 0.951056, 0.162460),
    Vector(0.850651, 0.525731, 0.000000),
    Vector(0.716567, 0.681718, 0.147621),
    Vector(0.525731, 0.850651, 0.000000),
    Vector(0.000000, 0.525731, 0.850651),
    Vector(0.309017, 0.500000, 0.809017),
    Vector(0.425325, 0.688191, 0.587785),
    Vector(0.688191, 0.587785, 0.425325),

    -- vec.y < 0.5  12
    Vector(0.000000, 0.000000, 1.000000),
    Vector(0.525731, 0.000000, 0.850651),
    Vector(0.295242, 0.000000, 0.955423),
    Vector(0.442863, 0.238856, 0.864188),
    Vector(0.162460, 0.262866, 0.951056),
    Vector(0.864188, 0.442863, 0.238856),
    Vector(0.809017, 0.309017, 0.500000),
    Vector(0.681718, 0.147621, 0.716567),
    Vector(0.587785, 0.425325, 0.688191),
    Vector(0.955423, 0.295242, 0.000000),
    Vector(1.000000, 0.000000, 0.000000),
    Vector(0.951056, 0.162460, 0.262866),
    Vector(0.850651, 0.000000, 0.525731),

    -- vec.x < 0 21
    -- vec.y >= 0.5 9
    Vector(-0.309017, 0.500000, 0.809017),
    Vector(-0.147621, 0.716567, 0.681718),
    Vector(-0.850651, 0.525731, 0.000000),
    Vector(-0.716567, 0.681718, 0.147621),
    Vector(-0.688191, 0.587785, 0.425325),
    Vector(-0.500000, 0.809017, 0.309017),
    Vector(-0.238856, 0.864188, 0.442863),
    Vector(-0.262866, 0.951056, 0.162460),
    Vector(-0.425325, 0.688191, 0.587785),
    Vector(-0.525731, 0.850651, 0.000000),

    -- vec.y < 0.5 11
    Vector(-0.864188, 0.442863, 0.238856),
    Vector(-0.525731, 0.000000, 0.850651),
    Vector(-0.442863, 0.238856, 0.864188),
    Vector(-0.295242, 0.000000, 0.955423),
    Vector(-0.162460, 0.262866, 0.951056),
    Vector(-0.681718, 0.147621, 0.716567),
    Vector(-0.809017, 0.309017, 0.500000),
    Vector(-0.587785, 0.425325, 0.688191),
    Vector(-0.955423, 0.295242, 0.000000),
    Vector(-0.951056, 0.162460, 0.262866),
    Vector(-0.850651, 0.000000, 0.525731),
    Vector(-1.000000, 0.000000, 0.000000),


    -- vec.z < 0  39
    -- vec.x >= 0 21
    -- vec.y >= 0.5 10
    Vector(0.716567, 0.681718, -0.147621),
    Vector(0.000000, 0.850651, -0.525731),
    Vector(0.000000, 0.955423, -0.295242),
    Vector(0.238856, 0.864188, -0.442863),
    Vector(0.262866, 0.951056, -0.162460),
    Vector(0.500000, 0.809017, -0.309017),
    Vector(0.147621, 0.716567, -0.681718),
    Vector(0.309017, 0.500000, -0.809017),
    Vector(0.425325, 0.688191, -0.587785),
    Vector(0.688191, 0.587785, -0.425325),
    Vector(0.000000, 0.525731, -0.850651),

    -- vec.y < 0.5  10
    Vector(0.850651, 0.000000, -0.525731),
    Vector(0.442863, 0.238856, -0.864188),
    Vector(0.587785, 0.425325, -0.688191),
    Vector(0.000000, 0.000000, -1.000000),
    Vector(0.162460, 0.262866, -0.951056),
    Vector(0.295242, 0.000000, -0.955423),
    Vector(0.864188, 0.442863, -0.238856),
    Vector(0.809017, 0.309017, -0.500000),
    Vector(0.951056, 0.162460, -0.262866),
    Vector(0.525731, 0.000000, -0.850651),
    Vector(0.681718, 0.147621, -0.716567),


    -- vec.x < 0 17
    -- vec.y >= 0.5 7
    Vector(-0.500000, 0.809017, -0.309017),
    Vector(-0.716567, 0.681718, -0.147621),
    Vector(-0.238856, 0.864188, -0.442863),
    Vector(-0.262866, 0.951056, -0.162460),
    Vector(-0.147621, 0.716567, -0.681718),
    Vector(-0.309017, 0.500000, -0.809017),
    Vector(-0.688191, 0.587785, -0.425325),
    Vector(-0.425325, 0.688191, -0.587785),

    -- vec.y < 0.5 9
    Vector(-0.587785, 0.425325, -0.688191),
    Vector(-0.525731, 0.000000, -0.850651),
    Vector(-0.442863, 0.238856, -0.864188),
    Vector(-0.295242, 0.000000, -0.955423),
    Vector(-0.162460, 0.262866, -0.951056),
    Vector(-0.864188, 0.442863, -0.238856),
    Vector(-0.951056, 0.162460, -0.262866),
    Vector(-0.809017, 0.309017, -0.500000),
    Vector(-0.681718, 0.147621, -0.716567),
    Vector(-0.850651, 0.000000, -0.525731),

    -- vec.y < 0 72
    -- vec.z >= 0  39
    -- vec.x >= 0 21
    -- vec.y >= 0.5 13
    Vector(0.000000, -1.000000, 0.000000),
    Vector(0.000000, -0.850651, 0.525731),
    Vector(0.000000, -0.955423, 0.295242),
    Vector(0.238856, -0.864188, 0.442863),
    Vector(0.262866, -0.951056, 0.162460),
    Vector(0.500000, -0.809017, 0.309017),
    Vector(0.716567, -0.681718, 0.147621),
    Vector(0.525731, -0.850651, 0.000000),
    Vector(0.309017, -0.500000, 0.809017),
    Vector(0.147621, -0.716567, 0.681718),
    Vector(0.000000, -0.525731, 0.850651),
    Vector(0.425325, -0.688191, 0.587785),
    Vector(0.688191, -0.587785, 0.425325),
    Vector(0.850651, -0.525731, 0.000000),

    -- vec.y < 0.5 7
    Vector(0.442863, -0.238856, 0.864188),
    Vector(0.162460, -0.262866, 0.951056),
    Vector(0.587785, -0.425325, 0.688191),
    Vector(0.955423, -0.295242, 0.000000),
    Vector(0.864188, -0.442863, 0.238856),
    Vector(0.951056, -0.162460, 0.262866),
    Vector(0.809017, -0.309017, 0.500000),
    Vector(0.681718, -0.147621, 0.716567),

    -- vec.x < 0  17
    -- vec.y >= 0.5 9
    Vector(-0.850651, -0.525731, 0.000000),
    Vector(-0.716567, -0.681718, 0.147621),
    Vector(-0.525731, -0.850651, 0.000000),
    Vector(-0.500000, -0.809017, 0.309017),
    Vector(-0.238856, -0.864188, 0.442863),
    Vector(-0.262866, -0.951056, 0.162460),
    Vector(-0.688191, -0.587785, 0.425325),
    Vector(-0.309017, -0.500000, 0.809017),
    Vector(-0.147621, -0.716567, 0.681718),
    Vector(-0.425325, -0.688191, 0.587785),

    -- vec.y < 0.5 7
    Vector(-0.162460, -0.262866, 0.951056),
    Vector(-0.951056, -0.162460, 0.262866),
    Vector(-0.955423, -0.295242, 0.000000),
    Vector(-0.681718, -0.147621, 0.716567),
    Vector(-0.442863, -0.238856, 0.864188),
    Vector(-0.587785, -0.425325, 0.688191),
    Vector(-0.864188, -0.442863, 0.238856),
    Vector(-0.809017, -0.309017, 0.500000),

    -- vec.z < 0  32
    -- vec.x >= 0 17
    -- vec.y >= 0.5 10
    Vector(0.000000, -0.850651, -0.525731),
    Vector(0.262866, -0.951056, -0.162460),
    Vector(0.147621, -0.716567, -0.681718),
    Vector(0.000000, -0.525731, -0.850651),
    Vector(0.309017, -0.500000, -0.809017),
    Vector(0.238856, -0.864188, -0.442863),
    Vector(0.500000, -0.809017, -0.309017),
    Vector(0.425325, -0.688191, -0.587785),
    Vector(0.716567, -0.681718, -0.147621),
    Vector(0.688191, -0.587785, -0.425325),
    Vector(0.000000, -0.955423, -0.295242),

    -- vec.y < 0.5 6
    Vector(0.442863, -0.238856, -0.864188),
    Vector(0.162460, -0.262866, -0.951056),
    Vector(0.587785, -0.425325, -0.688191),
    Vector(0.681718, -0.147621, -0.716567),
    Vector(0.864188, -0.442863, -0.238856),
    Vector(0.809017, -0.309017, -0.500000),
    Vector(0.951056, -0.162460, -0.262866),

    -- vec.x < 0 14
    -- vec.y >= 0.5  7
    Vector(-0.238856, -0.864188, -0.442863),
    Vector(-0.500000, -0.809017, -0.309017),
    Vector(-0.262866, -0.951056, -0.162460),
    Vector(-0.716567, -0.681718, -0.147621),
    Vector(-0.425325, -0.688191, -0.587785),
    Vector(-0.688191, -0.587785, -0.425325),
    Vector(-0.147621, -0.716567, -0.681718),
    Vector(-0.309017, -0.500000, -0.809017),

    -- vec.y < 0.5 6
    Vector(-0.442863, -0.238856, -0.864188),
    Vector(-0.162460, -0.262866, -0.951056),
    Vector(-0.864188, -0.442863, -0.238856),
    Vector(-0.951056, -0.162460, -0.262866),
    Vector(-0.809017, -0.309017, -0.500000),
    Vector(-0.681718, -0.147621, -0.716567),
    Vector(-0.587785, -0.425325, -0.688191),


}

kNumIndexedVectors = 162
function GetVectorFromIndex(index)
    assert(index)
    return Vector(kVectorList[index])
end

function GetIndexFromVector(vector)

    assert(vector)

    local index = 1

    if vector.y < 0 then
        index = index + 88
    end

    if vector.z < 0 then
        index = index + 39
    end

    if vector.x < 0 then
        index = index + 17
    end

    if math.abs(vector.y) < 0.5 then
        index = index + 7
    end

    local bestDot = 0
    local numLookups = 0
    local lookupsForBest = 0

    for i = index, #kVectorList do

        numLookups = numLookups + 1

        local dotProduct = vector:DotProduct(kVectorList[i])
        if dotProduct > bestDot then
            index = i
            bestDot = dotProduct
            lookupsForBest = numLookups
        end

        if dotProduct > 0.98 then
            break
        end

    end

    --Print("bestDot %s  index %s  lookupsForBest %s", ToString(bestDot), ToString(index), ToString(lookupsForBest))

    return index

end


------------------------------------------
--  Counts the number of entries in the hash table. Apparently this is the fastest way to do it.
------------------------------------------
function GetTableSize(t)

    local c = 0
    for _,_ in pairs(t) do
        c = c + 1
    end
    return c

end

------------------------------------------
--  LPF == Linear Piecewise Function
------------------------------------------
function EvalLPF( x, points )

    local N = #points
    assert( N >= 2 )
    assert( x >= points[1][1] )

    -- If x is beyond the key points, then just hold the last Y key
    if x >= points[N][1] then
        return points[N][2]
    end

    for i = 2,N do
        if x <= points[i][1] then

            -- got it
            local x1 = points[i-1][1]
            local y1 = points[i-1][2]
            local x2 = points[i][1]
            local y2 = points[i][2]
            assert( x1 < x2 )

            local t = (x-x1) / (x2-x1)
            return (1-t)*y1 + t*y2

        end
    end

    return 0.0

end

function AssertFloatEqual( x, y )
    assert( math.abs(x-y) < 1e-8 )
end

------------------------------------------
--  Also handles the case if both are equal
------------------------------------------
function VectorsApproxEqual( a, b, squareTol )

    if a ~= nil and b ~= nil then
        return a:GetDistanceSquared(b) < squareTol
    elseif a == nil and b == nil then
        return true
    else
        return false
    end

end

function GetRandomDirXZ()

    local azimuth = math.random() * 2 * math.pi
    return (Vector( math.cos(azimuth), 0, math.sin(azimuth) ))

end

function FindStructByFieldValue( arrayOfStructs, fieldKey, fieldValue )

    for i = 1,#arrayOfStructs do

        if arrayOfStructs[i][fieldKey] == fieldValue then
            return arrayOfStructs[i], i
        end

    end

    return nil, -1

end

local values = {nil, nil, nil, nil, nil, nil, nil, nil, nil}
function RawPrint(fmt, ...)
    if(select("#", ...) == 0) then
        Shared.Message(tostring(fmt))
    elseif(type(fmt) ~= "string" or not string.find(fmt, "%%")) then
        local count = select("#", ...)+1

        values[1] = ((fmt or fmt == false) and ToString(fmt)) or "nil"

        for i=2,count,1 do
            local value = select(i-1, ...)
            if(value == nil) then
                values[i] = "nil"
            else
                values[i] = ToString(value)
            end
        end

        Shared.Message(TableConcat(values, " ", 1, count))

        for i=count,1,-1 do
            values[i] = nil
        end
    else
        Shared.Message(StringFormat(fmt, ...))
    end
end

local set_mt = { __index = function() return false; end }
function set( tbl )
    local ret = {}

    for i=1,#tbl do
        ret[tbl[i]] = true
    end

    return setmetatable( ret, set_mt )
end

function CopyRelevancyMask(fromEnt, toEnt)

    if fromEnt and toEnt then
        toEnt:SetExcludeRelevancyMask(fromEnt:GetExcludeRelevancyMask())
    end

end

local kGamemode
function GetGamemode()
    if kGamemode then return kGamemode end

    local gameSetup = io.open( "game_setup.xml", "r" )

    if not gameSetup then
        kGamemode = "ns2"

        return "ns2"
    end

    local data = gameSetup:read( "*all" )

    gameSetup:close()

    local dataMatch = data:match( "<name>(.+)</name>" )

    kGamemode = dataMatch or "ns2"

    return kGamemode
end

function IsValid(obj)
    return obj ~= nil and (debug.isvalid(obj))
end

function HexToColor(hx, alpha)
    
    if #hx ~= 6 then
        error("Not a valid hexadecimal color string!")
        return (Color(1,1,1,1))
    end
    
    alpha = alpha or 1.0
    
    -- Remove 0x or # prefix... yea, not bulletproof but should work well enough.
    hx = string.gsub(hx, "0x", "")
    hx = string.gsub(hx, "#", "")
    
    hx = "0x"..hx -- add 0x prefix (ensuring it's only there once.)
    
    local dec = tonumber(hx)
    if not dec then
        error("Not a valid hexadecimal color string!")
        return (Color(1,1,1,1))
    end
    local red = bit.rshift(dec, 16) / 255
    local green = bit.band(bit.rshift(dec, 8),255) / 255
    local blue = bit.band(dec, 255) / 255
    
    return (Color(red, green, blue, alpha))
    
end

local kSpaceAdditions = {'Num','Pad','Left','Right','Page','App','Mouse','Button','Wheel','Print', 'Joystick', 'Rotation', 'Pov', 'Slider'}
function GetFriendlyBindingName(name)
    
    local newName = name
    for i=1, #kSpaceAdditions do
        newName, _ = string.gsub(newName, kSpaceAdditions[i], kSpaceAdditions[i]..' ')
    end
    
    return newName
    
end

local function GetXYDistanceSquared(coords, origin)
    
    local diff = origin - coords.origin
    local x = diff:DotProduct(coords.xAxis)
    local y = diff:DotProduct(coords.yAxis)
    return x*x + y*y
    
end

local _xyCompareCoords
local function CompareXYDistance(a, b)
    local dist1 = GetXYDistanceSquared(_xyCompareCoords, a:GetOrigin())
    local dist2 = GetXYDistanceSquared(_xyCompareCoords, b:GetOrigin())
    return dist1 < dist2
end

function SortEntitiesBasedOn2DXYDistance(viewCoords, list)
    _xyCompareCoords = viewCoords -- ugh... but no other way without creating a new sort function every time :(
    table.sort(list, CompareXYDistance)
end

local function ReadOnlyToString(self)
    return "read-only table."
end

-- Returns a read-only copy of the given table.
function ReadOnly(tbl)
    return (setmetatable({},
    {
        __index = tbl,
        __tostring = getmetatable(tbl) and getmetatable(tbl).__tostring or nil,
        __newindex = function(t, key, value)
           error("attempting to change constant " .. tostring(key) .. " to " .. tostring(value), 2)
        end,
    }))
end

-- Returns a string representation of a function containing enough information to (hopefully)
-- figure out where a function was defined.
function DebugFunctionToString(func)
    
    assert(type(func) == "function")
    
    local infoTable = debug.getinfo(func, "nS")
    local result
    if infoTable.namewhat == "" then
        result = string.format("function defined at line %s of %s", infoTable.linedefined, infoTable.short_src)
    else
        result =  string.format("%s function named %s, defined at line %s of %s", infoTable.namewhat, infoTable.name, infoTable.linedefined, infoTable.short_src)
    end
    
    return result
end

-- Returns true if the given substring is found inside the given string.  Does not need to be
-- contiguous, just needs to be in the same order.  Case insensitive by default, can be changed.
-- Example:
--  SubStringInString("hello", "H-E-L-asdfasdf-L-O") -- returns true.
--
function SubStringInString(substr, str, caseSensitive)
    
    if not caseSensitive then
        str = string.UTF8Lower(str)
        substr = string.UTF8Lower(substr)
    end
    
    local uStr = string.UTF8Encode(str)
    local uSubstr = string.UTF8Encode(substr)
    
    if #str < #substr then
        return false
    end
    
    -- Search for the substring inside the string..  Don't assume the string will be in one piece
    -- either.  Someone could name their server "M Y   A W E S O M E   S E R V E R"... People can
    -- be stupid like that... :(
    local j = 1 -- substr index
    for i=1, #uStr do
        if uStr[i] == uSubstr[j] then
            j = j + 1
        end
        
        if #uSubstr - (j-1) > (#uStr - i) then
            return false -- not enough characters left to match substring.
        end
        
        if j > #uSubstr then
            return true -- all characters of substring matched up to string.
        end
    end
    
    return false

end

-- from http://stackoverflow.com/questions/10768142/verify-if-point-is-inside-a-cone-in-3d-space
---@param point Vector coordinates  of point to be tested
---@param coneOrigin Vector coordinates of apex point of cone
---@param coneDir Vector coordinates of center of cone's basement circle
---@param angle Angle cone's aperture in radians
function IsPointInCone(point, coneOrigin, coneDir, angle)

    -- Vector pointing to camera point from cone point
    local apexToXVect = coneOrigin - point;

    -- Vector pointing from apex to circle-center point.
    local axisVect = - coneDir;

    -- X is lying in cone only if it's lying in 
    -- infinite version of its cone -- that is, 
    -- not limited by "round basement".
    -- We'll use Math.DotProduct() to 
    -- determine angle between apexToXVect and axis.
    local isInInfiniteCone = Math.DotProduct(apexToXVect, axisVect)
            / apexToXVect:GetLength() / axisVect:GetLength()
            >
            -- We can safely compare cos() of angles 
            -- between vectors instead of bare angles.
            math.cos(angle);


    return isInInfiniteCone;
end

function VectorIsFinite(vec)
    return vec.x == vec.x and vec.y == vec.y and vec.z == vec.z
end

-- %%% New CBM Functions %%% --
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
