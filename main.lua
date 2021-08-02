-- Exports frame data from Aseprite to a .txt file used in my game
local dlg = Dialog()
local sprite = app.activeSprite
local name = sprite.filename
local destName, fileName

-- sliceToLastSubstr
-- Arguments: str is the string to slice
--            substr is the string to slice to
-- Implementation: Find the index of the last substr in str and then return a string that omits all characters following that substr
-- Purpose: Return a string that omits all characters following the last found substr in str
function sliceToLastSubstr(str, substr)
    assert(type(str) == "string", "Passed argument str to sliceToLastSubstr is not a string.")
    assert(type(substr) == "string", "Passed argument substr to sliceToLast is not a string.")
    
    local lastIndex, index = 1, 0
    
    while (index ~= nil) do -- Keep finding leading '\' until there are no more - the last found index is the index of the last '\' in str
        lastIndex = index
        index, _ = string.find(str, substr, index + 1)
    end

    -- Slice the sprite name to include the last character in the last substr 
    slicedStr = string.sub(str, 1, lastIndex)
    return slicedStr
end

-- formFrameTable
-- Arguments: dur is the duration of a 1s frame
--            maxHold is the maximum held duration 
-- Implementation: Create a new table containing numbers corresponding to... index * 1s frame  
-- Purpose: The table is used for calculating the hold durations of frames
function formFrameTable(dur, maxHold)
    assert(type(dur) == "number", "1s frame duration passed to formFrameTable is not a number.")
    assert(type(maxHold) == "maxHold", "Max hold frame duration passed to formFrameTable is not a number.")

    frameTable = {}

    local i, maxHoldFrames = 1, maxHold / dur
    while (i <= maxHoldFrames) do -- Keep adding more frame durations (ms) to the table until the maximum is surpassed or reached
        frameTable[i] = i * dur
        i = i + 1
    end

    return frameTable
end

-- closestTableNumber
-- Arguments: myNum is the number being compared to the table's numbers
--            table is a table of numbers 
-- Implementation: Iterate through the table until the difference between sequential comparisons increases
-- Purpose: Find the closest hold duration in frames
function closestTableNumber(myNum, table)
    assert(type(myNum) == "number", "Passed argument myNum to closestTableNumber is not a number.")
    assert(type(table) == "table", "Passed argument table to closestTableNumber is not a table.")
    assert(type(table) ~= "nil", "Passed argument table to closestTableNumber is nil.")

    local difference, i = 0, 1
    repeat 
        difference = math.abs(myNum - table[i])
        i = i + 1
    until (i < #table and math.abs(myNum - table[i]) > difference)
    return i - 1
end

dlg:entry {
    id = "dest",
    label = "Folder path",
    text = ""
}

dlg:entry {
    id = "file",
    label = "File name (.txt)",
    text = ""
}

dlg:number {
    id = "ones",
    label = "Duration of 1s frame (ms): ",
    text = "16.66", -- Default 1s duration matches that of a 60 fps animation
    decimals = 2
}

dlg:number {
    id = "maxHold",
    label = "Maximum duration of a held frame (ms): ",
    text = "1000",  -- Default maximum duration of a held frame matches that of a 1 fps animation (or 60 times the duration of the default 1s duration)
    decimals = 2
}

dlg:button {
    id = "export",
    text = "EXPORT",
    onclick = function()
        local data = dlg.data

        local destData = data.dest
        
        if (destData ~= "") then -- If the user has inputted a destination in the dialog entry, set that as the directory of output
            destName = destData
            if (string.byte(destName, -1) ~= string.byte("\\")) then -- In case the destination entered does not end with a backslash, append one
                destName = destName.."\\"
            end
        else -- If the user has left the dialog entry blank, set the default directory as the same directory the active sprite has 
            destName = sliceToLastSubstr(name, "\\")
        end

        local fileData = data.file
        
        if (fileData ~= "") then -- If the user has inputted a name in the dialog entry, set that as the output file name
            fileName = fileData..".txt"
        else -- If the user has lef tthe dialog entry blank, set the default name as the same name the active sprite has
            fileName = sliceToLastSubstr(name, ".").."txt"
        end

        -- Destination folder should exist
        file = assert(io.open(destName..fileName, "w+"), "Failed to write to file.")
        io.output(file)

        -- Write: obtain and write # of animations to output file
        io.write(#sprite.tags)

        -- Each tag symbolizes a separate animation
        for tagNo, tag in ipairs(sprite.tags) do
            -- Write: animation name in style "<n_NAME|", where n is the animation # and NAME is the animation name
            io.write("\n<"..tagNo.."_"..tag.name.."|")

            -- Write: animation # of frames in style "[n]", where n is the # of frames
            io.write("\n["..tag.frames.."]")

            -- Comment A: in style "i1,i2,i3,...,i;h1,h2,h3,...,h"
            -- Write: comma separated list of integers representing which source index (i in comment A) to use in animation 
            
            local startFrame, endFrame = tag.fromFrame, tag.toFrame
            local currFrame = startFrame
            repeat 
                io.write((currFrame.frameNumber - 1)..",")
                currFrame = currFrame.next
            until (currFrame == nil or currFrame.frameNumber > endFrame.frameNumber) -- To test: 1-frame tags
            
            -- Write: separating ';' character
            io.write(";")

            -- Write: comma separated list of integers representing how many frames each source index is held for (h in comment A)
            currFrame = startFrame
            
            -- maxHold value should be greater than or equal to ones value
            local onesData = data.ones
            local maxHoldData = data.maxHold
            assert(onesData <= maxHoldData, "Duration of a 1s frame exceeds the maximum hold duration specified.")

            local frameTable = formFrameTable(onesData, maxHoldData)
            repeat
                -- Convert duration (s) to (ms)
                io.write(closestTableNumber(currFrame.duration * 1000, frameTable)..",")
                currFrame = currFrame.next
            until (currFrame == nil or currFrame.frameNumber > endFrame.frameNumber)
        end
        io.close(file)
    end
}

dlg:button {
    id = "cancel",
    text = "CANCEL",
    onclick = function()
        dlg:close()
    end
}

dlg:show { 
    wait = false 
}