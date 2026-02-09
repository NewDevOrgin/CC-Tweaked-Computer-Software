local modem = peripheral.find("modem")
modem.open(6769)

function getBalance(acc)
    local db_file = fs.open("DATABASE/" .. acc .. ".entry", "r")
    local balance = db_file.readAll():gsub("%s+", "")
    db_file.close()
    return balance
end

function setBalance(acc, newBalance)
    local db_file = fs.open("DATABASE/" .. acc .. ".entry", "w")
    local balance = db_file.write(newBalance)
    db_file.close()
end

while true do
    local e, s, channel, replyChannel, message, distance
    repeat
        e, s, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until channel == 6769
    if (type(message) == "table") then
        if (message.method == "get") then
            local balance = getBalance(message.account)
            modem.transmit(replyChannel, 6769, balance)
        elseif (message.method == "set") then
            setBalance(message.account, message.balance)
        end
    end
end
