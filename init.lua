-- Version 2.0


local mq = require('mq')
---@type ImGui
local imgui = require("ImGui")
local tableList = require("lib.tableList") -- really need to give this a more descriptive name. its the table with EVERYTHING in it. definitions and configs for execution. Future: Split for better organization
local Module = require("lib.module")

local versionInfo = "TBM Aug Swap V 2.0"


print(' \ag--- Begin TBM Swap log --- ')

local setFlags = true -- if true, then boxes will be checked
-- update the gear table from the char inventory
tableList.InventoryDataTable = Module.loadgeartable(tableList.InventoryDataTable,tableList.slotName,setFlags)


print(' --- gear table loaded --- ')
tableList = Module.setDefaultAugs(tableList)
print(' -- loaded defaults configs')




-- function to run the window
function TbmAugSwapRender(open,tableList) -- FUTURE: redefined locala tableList, this method is bad... did we want a global or something? - may just need to have a different name here...
    local testThingsFlag = false
    -- We specify a default position/size in case there's no data in the .ini file.
    -- We only do it to make the demo applications a little more welcoming, but typically this isn't required.
    local main_viewport = imgui.GetMainViewport()
    imgui.SetNextWindowPos(main_viewport.WorkPos.x + 650, main_viewport.WorkPos.y + 20, ImGuiCond.FirstUseEver) -- sets initial position
    -- imgui.SetNextWindowPos(main_viewport.WorkPos.x + 650, main_viewport.WorkPos.y + 20) -- sets position always

    -- change the window size
    imgui.SetNextWindowSize(1000, 780, ImGuiCond.FirstUseEver) -- sets initial size
    -- imgui.SetNextWindowSize(1000, 780) -- sets size always

    local show = true
    open, show = imgui.Begin("TBM Aug Swap", open) -- names window. whatever this is will store the overlay values for the window position in mqoverlay ini

    if not show then
        ImGui.End()
        -- print('chageMe: did we get here - when we minimize we get here') -- FUTURE: Need to fix this so that we dont lose tableList -- solution was to return tableList
        return open, tableList
    end

    if tableList == nil then
        -- Note: Should not happen since we return tableList when gui is minimuzed (above) and also when its normal (below)
        --  Might be a better way to handle this
        print('DEBUG: TbmSwapRender: table is gone...')
    end

    --ImGui.PushItemWidth(ImGui.GetFontSize() * -12);
    imgui.PushItemWidth(imgui.GetFontSize() * -12);

    -- Main window element area --    

    -- Beginning of window elements
    imgui.Text(versionInfo)
    --imgui.Text("\n") -- To create a new line

    if testThingsFlag then
        if imgui.Button("Test Button") then
            -- What you want the button to do
            print('Button pressed') -- an example. Can run functions
            local a,b = Module.lookupinstalledaugandsolvent("head",9)
            print('Result: a = ' .. a .. ', b = ' .. b)
            -- mq.cmdf('/removeaug "%s" "%s"', "blah", "Crypt-Hunter's Soulrender Vambraces")
            -- mq.cmdf('/removeaug "%s" "%s"', "Glorious Sulstone of the Sturdy", "Crypt-Hunter's Soulrender Vambraces")
            -- tableList.InventoryDataTable = Module.loadgeartable(tableList.InventoryDataTable,tableList.slotName,setFlags)
            -- print('delaying 1 s...')
            -- mq.delay(1000)
            -- print('...delayed 1 s')
        end
        -- imgui.SameLine()
    end
    
    imgui.Separator()
    
    -- End of main window element area --

    -- Add the elements to the UI
    Module.drawPlayerInfo()

    -- Draw the tab bar
    if imgui.BeginTabBar('Items') then

        
        tableList = Module.drawEquipmentTab(tableList,true,'armor')
        tableList = Module.drawEquipmentTab(tableList,false,'ranged')
        tableList = Module.drawEquipmentTab(tableList,false,'mainhand')
        tableList = Module.drawEquipmentTab(tableList,false,'offhand')
        Module.drawAugSellTab()
        

        imgui.EndTabBar()
    end

    


    -- Required for window elements
    imgui.Spacing()
    imgui.PopItemWidth()
    imgui.End()


    

    return open, tableList
end

local openGUI = true -- could change value in future to shut down?

-- bind the <function> to imgui so that it runs
imgui.Register('TBM Aug Swap', function() -- what is difference between imgui.Register and imgui.init ?
    openGUI, tableList = TbmAugSwapRender(openGUI,tableList) -- note: tableList.<> is used to set run flags and return to main thread
end)

-- stuff to do while the gui is open
while openGUI do
    mq.delay(1000) -- equivalent to '1s', this is the 'refresh' wait time

    -- Use flags to initiate routines to perform operations that require interaction with the main thread
    --  There is probably much better ways to do this, but I'm currently ignorant and this way seems to work
    --  The issue was that the mq.delay() command could not be called from "unyeildable" threads, so it seems
    --  that these things need to be called directly from this main thread (?)
    --  Done - FUTURE: Need a way to make sure tableList is initialized if the window is minimized. otherwise it will crash and is difficult to recover
    -- if <do remove flag> then stuff
    -- if <do install new aug flag> then stuff
    -- if <sell old augs flag > then stuff
    if tableList ~= nil then -- prevent crashing if we lose the table data for some reason (ie bad code)
        if tableList.doBuySolventFlag then -- if the flag was set by the push button callback, we will do this action            
            Module.buySolventNeeded(tableList)
            tableList.doBuySolventFlag = false -- after action is done, set flag to false to end routine
        end

        if tableList.doBuyAugFlag then            
            Module.buyAugNeeded(tableList,true) -- future: Need isArmor flag
            tableList.doBuyAugFlag = false
        end

        if tableList.doRemoveOldAugFlag then
            Module.funremoveaug(tableList)
            tableList.doRemoveOldAugFlag = false
            
        end

        if tableList.doInstallNewAugFlag then
            Module.insertNewAug(tableList)
            tableList.doInstallNewAugFlag = false
        end

        if tableList.doSellOldAugFlag then
            Module.sellOldAug(tableList)
            tableList.doSellOldAugFlag = false
        end

    
    end

end