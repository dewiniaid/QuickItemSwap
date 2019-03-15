-- Support the new blacklist features.
--
-- Hypothetically, we could just nuke all playerdata here since nothing saved by this mod is particularly important.
-- But this is More Correct(tm)

if globals and globals.playerdata then
    for _, data in pairs(global.playerdata) do
        if not data.blacklist then data.blacklist = {} end
    end
end

