local monitor = peripheral.find("monitor")
local speaker = peripheral.find("speaker")
local printer = peripheral.find("printer")
local modem = peripheral.find("modem")
local relay = peripheral.find("redstone_relay")

local safe = peripheral.wrap("minecraft:barrel_3")
local output = peripheral.wrap("minecraft:barrel_4")

local inService = true

local defaultTextScale = monitor.getTextScale()

if (not monitor or not speaker or not printer or not safe or not output or not modem or not relay) then
    monitor.clear()
    monitor.setCursorPos(3,6)
    monitor.write("Out Of Order")
    inService = false
end

relay.setOutput("front", true)
modem.open(6770)

if (not inService) then
	return
end

function getBalance(acc)
    local payload = {
        method="get",
        acc=acc
    }
    modem.transmit(6769, 6770, payload)
    local t = os.startTimer(2)
    local e, s, c, r, m, d
    repeat
        e, s, c, r, m, d = os.pullEvent()
    until (e == "modem_message") or (e == "timer" and s == t)
    if (e == "modem_message") then
        if (m ~= "Invalid") then
            return m
        end
    end
    return "Invalid"
end

function setBalance(acc, balance)
    local payload = {
        method="get",
        account=acc,
        balance=balance
    }
    modem.transmit(6769, 6770, payload)
end

function openOutput()
    relay.setOutput("front", false)
end

function closeOutput()
    relay.setOutput("front", true)
end

function KeyPad(msg)

    local pressed = ""
    monitor.setTextScale(0.7)

    while true do
        monitor.setBackgroundColour(512)
        monitor.clear()

        monitor.setCursorPos(3, 1)
        monitor.write(msg)

        monitor.setCursorPos(5, 3)
        monitor.write(pressed)
        monitor.setCursorPos(12, 3)
        monitor.write(">")

        monitor.setBackgroundColour(128)
        monitor.setCursorPos(6, 5)
        monitor.write("1 2 3")
        monitor.setCursorPos(6, 6)
        monitor.write("4 5 6")
        monitor.setCursorPos(6, 7)
        monitor.write("7 8 9")
        monitor.setCursorPos(6, 8)
        monitor.write("  0  ")

        local e, s, x, y = os.pullEvent("monitor_touch")

        if (x == 12 and y == 3 and string.len(pressed) == 4) then
            speaker.playNote("bit")
            return pressed
        else
            speaker.playNote("snare")
        end

        if (x == 6) then
            if (y == 5) then
                if (string.len(pressed) ~= 4) then
                    pressed = pressed .. "1"
                    speaker.playNote("bit")
                end
            elseif (y == 6) then
                if (string.len(pressed) ~= 4) then
                    pressed = pressed .. "4"
                    speaker.playNote("bit")
                end
            elseif (y == 7) then
                if (string.len(pressed) ~= 4) then
                    pressed = pressed .. "7"
                    speaker.playNote("bit")
                end
            end
        elseif (x == 8) then
            if (y == 5) then
                if (string.len(pressed) ~= 4) then
                    pressed = pressed .. "2"
                    speaker.playNote("bit")
                end
            elseif (y == 6) then
                if (string.len(pressed) ~= 4) then
                    pressed = pressed .. "5"
                    speaker.playNote("bit")
                end
            elseif (y == 7) then
                if (string.len(pressed) ~= 4) then
                    pressed = pressed .. "8"
                    speaker.playNote("bit")
                end
            elseif (y == 8) then
                if (string.len(pressed) ~= 4) then
                    pressed = pressed .. "0"
                    speaker.playNote("bit")
                end
            end
        elseif (x == 10) then
            if (y == 5) then
                if (string.len(pressed) ~= 4) then
                    pressed = pressed .. "3"
                    speaker.playNote("bit")
                end
            elseif (y == 6) then
                if (string.len(pressed) ~= 4) then
                    pressed = pressed .. "6"
                    speaker.playNote("bit")
                end
            elseif (y == 7) then
                if (string.len(pressed) ~= 4) then
                    pressed = pressed .. "9"
                    speaker.playNote("bit")
                end
            end
        end
    end
end


function InvalidScreen(text)
    monitor.clear()
    monitor.setCursorPos(3,3)
    monitor.write(item)
    os.sleep(2)
    -- Remove Card
end

function IdleScreen()
    monitor.clear()
    monitor.setBackgroundColour(512)
    monitor.setTextScale(0.7)
    monitor.setCursorPos(2, 2)
    monitor.setBackgroundColour(2)
    monitor.write(" ")
    monitor.setBackgroundColour(512)
    monitor.setCursorPos(5, 2)
    monitor.write("ATM")
    monitor.setCursorPos(3, 2)
    monitor.write("Insert Card")
    os.pullEvent("disk")
    speaker.playNote("chime")
end

function OptionsScreen()
    monitor.setBackgroundColour(512)
    monitor.clear()
    monitor.setCursorPos(2, 2)
    monitor.write("Select:")
    monitor.setCursorPos(3, 4)
    monitor.write("Withdraw")
    monitor.setCursorPos(3, 6)
    monitor.write("Deposit")
    monitor.setCursorPos(3, 8)
    monitor.write("Check Balance")
    local e, s, x, y
    repeat
        e, s, x, y = os.pullEvent("monitor_touch")
    until y == 4 or y == 6 or y == 8
    if (y == 4) then
        speaker.playNote("bit")
        return "W"
    elseif (y == 6) then
        speaker.playNote("bit")
        return "D"
    elseif (y == 8) then
        speaker.playNote("bit")
        return "B"
    end
end

function RemoveCard()
    monitor.clear()
    monitor.setCursorPos(3,3)
    monitor.write("Remove Card")
    os.pullEvent("disk_eject")
end

while inService do
    IdleScreen()

    local pin = 0000
    local invalid = false
    local acc = ""

    if (fs.exists("disk/pin")) then
        local pinf = fs.open("disk/pin", "r")
        pin = pinf.readAll():gsub("%s+", "")
        pinf.close()
    end

    local pinInput = KeyPad("Your Pin")

    if (pin ~= pinInput) then
        invalid = true
    end

    if (not invalid) then
        local option = OptionsScreen()

        local accf = fs.open("disk/acc", "r")
        acc = accf.readAll():gsub("%s+", "")
        accf.close()

        if (option == "W") then
            local amount = KeyPad("Amount: ")
            local balance = getBalance(acc)
            if (tonumber(balance) >= tonumber(amount)) then
                local newBal = tonumber(balance) - tonumber(amount)
                setBalance(acc, newBal)
            else
                InvalidScreen("Insufficient Funds!")
            end
            safe.pushItems(peripheral.getName(output), 1, tonumber(amount))
        end
    end

    RemoveCard()
end
