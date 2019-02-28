local Lib = {}


function Lib.wraparound(t, start, reverse)
    --[[
    -- Returns an iterator that iterates over integer keys in table `t` from the specified start position, wrapping
    -- around and ending when it reaches `start` again.
    --
    -- `dir` specifies the direction to iterate (negative values for reverse, otherwise forward)
    -- `start` specifies the start location.  If `nil`, the first returned item will be at the at the start of the table
    -- (or the end of the table, if `dir` is negative)
    --
    -- Behavior if the table changes size during iteration is undefined.
     ]]
    local dir = (reverse and -1) or 1
    local len = #t
    local i = start
    start = start or (reverse and len) or 1

    return function()
        if i == nil then
            i = start
            return i, t[i]
        end

        i = i + dir
        if i < 1 then
            i = i + len
        elseif i > len then
            i = i - len
        end

        if i == start then
            return nil
        end
        return i, t[i]
    end
end


return Lib