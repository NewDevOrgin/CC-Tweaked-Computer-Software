local modem = peripheral.find("modem")
local NM = require("NetworManager")

local ia_range_base = 999
local ia_range_end = 10

function loop()
    local request, referer = NM.Serve()

    for i=1, ia_range_end, 1 do
        local current_ia = i + ia_range_base
        modem.transmit(current_ia, NM.myIA(), request)
        local response = NM.AwaitResponse(current_ia)
        if (response == "Timeout" and i == ia_range_end) then
            modem.transmit(referer, NM.myIA(), "Unmatched")
        end
        if (response ~= "Timeout") then
            modem.transmit(referer, NM.myIA(), current_ia)
            break
        end
    end
end
