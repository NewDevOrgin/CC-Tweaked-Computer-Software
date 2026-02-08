local modem = peripheral.find("modem")
local IA = 111

local NM = {}

local IAFile = fs.open("IA.txt", "r")
IA = tonumber(IAFile.readAll())
IAFile.close()

function NM.myIA()
    return IA
end

function NM.AwaitResponse()
    local timer = os.startTimer(2)
    local event, side, channel, replyChannel, message, distance
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent()
    until (event == "timer" and side == timer) or (event == "modem_message" and channel == IA)
    if (event == "timer") then
        return "Timeout"
    end
    return message, replyChannel
end

function NM.Serve()
    local event, side, channel, replyChannel, message, distance
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until channel == IA

    return message, replyChannel
end

function NM.Ping(Address)
    modem.transmit(Address, IA, "ping")
    local response = NM.AwaitResponse()
    if (response == "pong") then
        return "Awake"
    else
        return "Asleep"
    end
end

function NM.SetIA()
    local payload = {}
    payload["method"] = "assign"
    modem.transmit(999, IA, payload)
    local response = NM.AwaitResponse()
    if (response ~= "Timeout") then
        IA = tonumber(response)
        local File = fs.open("IA.txt", "w")
        File.write(tostring(IA))
        File.close()
    else
        error("Error Getting IA From 999")
    end
end

return NM
