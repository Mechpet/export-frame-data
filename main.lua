-- Exports frame data from Aseprite to a .txt file used in my game
local dlg = Dialog()
local sprite = app.activeSprite
local name = sprite.filename

-- Default destination will be the same directory the sprite is in (slice the name to the lastmost backslash)
local destName = name

dlg:entry {
    id = "dest",
    label = "Destination",
    text = ""
}

dlg:number {
    id = "ones",
    label = "Duration of 1s frame: ",
    text = "16.66", -- Default 1s duration matches that of a 60 fps animation
    decimals = 2
}

dlg:number {
    id = "maxHold",
    label = "Maximum duration of a held frame: ",
    text = "1000",  -- Default maximum duration of a held frame matches that of a 1 fps animation (or 60 times the duration of the default 1s duration)
    decimals = 2
}

dlg:button {
    id = "export",
    text = "EXPORT",
    -- Exports the data on button click
    onclick = function()
        local data = dlg.data
        local destData = data.dest

        -- maxHold value should be greater than ones value
        local onesData = data.ones
        local maxHoldData = data.maxHold
        assert(onesData <= maxHoldData, "Duration of a 1s frame exceeds the maximum hold duration specified.")

        -- If the user has inputted a destination in the dialog entry, set that as the directory of output
        if (destData ~= "") then
            destName = destData
            -- In case the destination entered does not end with a backslash, append one
            if (string.byte(destName, -1) ~= string.byte("\\")) then
                destName = destName.."\\"
            end
        end
        -- Destination folder should exist
        file = assert(io.open(destName.."text.txt", "w+"), "Failed to write to file.")
        io.output(file)

        -- Operation: obtain and write # of animations to output file

        io.write("Hello")
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