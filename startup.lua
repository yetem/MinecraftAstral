limitMap = {
    ["create:zinc_ingot"]=2047,
    ["minecraft:gold_ingot"]=2047,
    ["minecraft:glowstone_dust"]=511,
    ["minecraft:iron_ingot"]=2047,
    ["minecraft:copper_ingot"]=2047,
    ["minecraft:emerald"]=511,
    ["minecraft:lapis_lazuli"]=2047,
    ["techreborn:lazurite_dust"]=2047,
    ["techreborn:silver_ingot"]=2047,
    ["techreborn:tin_ingot"]=2047,
    ["tconstruct:cobalt_ingot"]=2047,
    ["minecraft:prismarine_crystals"]=511,
}

function printElem(elem)
    for key, value in pairs(elem) do
        print(key, value)
    end
end

function string:startswith(start)
    return self:sub(1, #start) == start
end

function fillOutputsTable(outputs, name)
    local elem = peripheral.wrap(name)
    local items = elem.items()
    for _, item in pairs(items) do
        if item.name ~= nil then
            outputs[item.name] = elem
        end
    end
    return outputs
end

function fillIInputsTable(inputs, name)
    local elem = peripheral.wrap(name)
    local items = elem.items()
    for _, item in pairs(items) do
        if item.name ~= nil then
            inputs[item.name] = elem
        end
    end
    return inputs
end

function buildInputsAndOutputs()
    local inputs = {}
    local outputs = {}
    local buffer = nil
    for _, name in pairs(peripherals) do
        if string.startswith(name, "extended_drawers:quad_drawer") then
            inputs = fillIInputsTable(inputs, name)
        elseif string.startswith(name, "extended_drawers:single_drawer") then
            output = fillOutputsTable(outputs, name)
        elseif string.startswith(name, "minecraft:barrel") then
            buffer = name
        end
    end
    return inputs, outputs, buffer
end

function push(queue, value)
    for _, v in pairs(queue) do
        if v == value then
            return
        end
    end
    table.insert(queue, value)
end

function pop(queue)
    if #queue == 0 then
        return nil
    end
    local value = table.remove(queue)
    return value
end

function isToLowItems(drawer)
    return drawer.items()[1].count < 2000
end

function printOnMonitor(monitor, queue, inputs)
    displayMap = {
        ["create:asurine"]="Asurine",
        ["create:crimsite"]="Crimsite",
        ["create:scorchia"]="Scorchia",
        ["create:ochrum"]="Ochrum",
        ["create:limestone"]="Limestone",
        ["create:veridium"]="Veridium"
    }
    monitor.setCursorPos(1, 1)
    local printNames = ""
    for name, _ in pairs(inputs) do
        monitor.clearLine()
        local isSuccess = true
        for _, queueName in pairs(queue) do
            if queueName == name then
                printNames = printNames .. "," .. name
                monitor.setBackgroundColor(colors.red)
                monitor.write(displayMap[name])
                monitor.setBackgroundColor(colors.black)
                isSuccess = false
                break
            end
        end
        if isSuccess == true then
            monitor.setBackgroundColor(colors.green)
            monitor.write(displayMap[name])
            monitor.setBackgroundColor(colors.black)
        end
        local x, y = monitor.getCursorPos()
        monitor.setCursorPos(1, y+1)
    end
    print("Wrzucam: " .. printNames)
end

function main(inputs, outputs, buffer, blockMap)
    local monitor = peripheral.wrap("left")
    monitor.setCursorBlink(false)
    while true do
        local queue = {}
        for name, output in pairs(outputs) do
            if isToLowItems(output) then
                push(queue, blockMap[name])
            end
        end
        printOnMonitor(monitor, queue, inputs)
        while #queue > 0 do
            local item = pop(queue)
            local inputPeripheral = inputs[item]
            inputPeripheral.pushItem(buffer, item, 64)
        end
        
        os.sleep(10)
    end
end

peripherals = peripheral.getNames()
inputs, outputs, buffer = buildInputsAndOutputs()
blockMap = {
    ["create:zinc_ingot"]="create:scorchia",
    ["minecraft:gold_ingot"]="create:ochrum",
    ["minecraft:glowstone_dust"]="create:ochrum",
    ["minecraft:iron_ingot"]="create:crimsite",
    ["minecraft:copper_ingot"]="create:veridium",
    ["minecraft:emerald"]="create:veridium",
    ["minecraft:lapis_lazuli"]="create:asurine",
    ["techreborn:lazurite_dust"]="create:asurine",
    ["techreborn:silver_ingot"]="create:limestone",
    ["techreborn:tin_ingot"]="create:limestone",
    ["tconstruct:cobalt_ingot"]="create:asurine",
    ["minecraft:prismarine_crystals"]="create:asurine",
}

main(inputs, outputs, buffer, blockMap)
