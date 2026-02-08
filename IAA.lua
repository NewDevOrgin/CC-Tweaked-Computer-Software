local modem = peripheral.find("modem")
local NM = require("NetworManager")

function lastIA()
    local File = fs.open("LastIA", "r")
    local LastIA = tonumber(File.readAll())
    File.close()
    return LastIA
end

function writeIA(IA)
    local File = fs.open("LastIA", "w")
    File.write(tostring(IA))
    File.close()
end

function loop()
    local request, referer = NM.Serve()
    if (request.method == "assign") then
        local LastIA = lastIA()
        local NewIA = LastIA + 1
        writeIA(NewIA)
        modem.transmit(referer, NM.myIA(), NewIA)
    end
end


while true do
	loop()
end
