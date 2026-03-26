--local tableList = require('lib.tableList')
local M = {}

local mq = require('mq')
local imgui = require("ImGui")


function M.setDefaultAugs(tableName)
    -- FUTURE: This needs uppdating, logic is confusing and may be wrong
    -- FUTURE: Druid level 90 is probably wrong at least. i believe i changed some of the lists so that invalidated the hard coded indicies here. 
    --           Need to review
    tableName.myLevel = mq.TLO.Me.Level()
    tableName.myClass = mq.TLO.Me.Class.ShortName()
--     local myClassGroup = 'Tank'

    for _, class in ipairs(tableName.classType.priestClass) do
        if class == tableName.myClass then
            tableName.myClassGroup = 'Priest'
        end
    end

    for _, class in ipairs(tableName.classType.casterClass) do
        if class == tableName.myClass then
            tableName.myClassGroup = 'Caster'
        end
    end

    for _, class in ipairs(tableName.classType.meleeClass) do
        if class == tableName.myClass then
            tableName.myClassGroup = 'Melee'
        end
    end

    for _, class in ipairs(tableName.classType.hybridClass) do
        if class == tableName.myClass then
            tableName.myClassGroup = 'Hybrid'
        end
    end

    for _, class in ipairs(tableName.classType.plateClass) do
        if class == tableName.myClass then
            tableName.usePlate = true
        end
    end

    for _, class in ipairs(tableName.classType.knightClass) do
        if class == tableName.myClass then
            tableName.useRune = true
        end
    end

    -- Set default type 9 according to Almar's Guide
    if tableName.myClassGroup == 'Hybrid' or tableName.myClassGroup == 'Caster' then
        tableName.type9Index_armor= 4
    elseif tableName.myClassGroup == 'Melee' then
        tableName.type9Index_armor= 6
    elseif tableName.myClassGroup == 'Priest' then
        tableName.type9Index_armor= 3
    elseif tableName.myClassGroup == 'Tank' then
        tableName.type9Index_armor= 2
    end

    -- Set default type 5
    if tableName.myClassGroup == 'Hybrid' or tableName.myClassGroup == 'Tank' or tableName.myClassGroup == 'Melee' then
        tableName.type5Index = 4
    elseif tableName.myClassGroup == 'Priest' then
        tableName.type5Index = 7
    elseif tableName.myClassGroup == 'Caster' then
        tableName.type5Index = 6
    end

--     -- Set default weapon augs according to class and weapon type
    if tableName.myClassGroup == 'Priest' and mq.TLO.Me.Inventory('mainhand').Type():find('1H Blunt') then
        tableName.type6Index = 2
        tableName.wep9Index = 2
    elseif tableName.myClassGroup == 'Priest' and mq.TLO.Me.Inventory('mainhand').Type():find('2H') then
        tableName.type6Index = 11 -- this seems to be beyond the bounds...
        tableName.wep9Index = 1
    elseif tableName.myClassGroup == 'Caster' and mq.TLO.Me.Inventory('mainhand').Type():find('1H Blunt') then
        tableName.type6Index = 7
        tableName.wep9Index = 2
    elseif tableName.myClassGroup == 'Caster' and mq.TLO.Me.Inventory('mainhand').Type():find('Piercing') then
        tableName.type6Index = 10
        tableName.wep9Index = 2
    elseif tableName.useRune and mq.TLO.Me.Inventory('mainhand').Type():find('1H') then
        tableName.type6Index = 8
        tableName.wep9Index = 2
    elseif tableName.usePlate and mq.TLO.Me.Inventory('mainhand').Type():find('1H') then
        tableName.type6Index = 4
        tableName.wep9Index = 2
    elseif mq.TLO.Me.Inventory('mainhand').Type():find('1H Slash') then
        tableName.type6Index = 5
        tableName.wep9Index = 2
    elseif mq.TLO.Me.Inventory('mainhand').Type():find('1H Blunt') then
        tableName.type6Index = 9
        tableName.wep9Index = 2
    elseif mq.TLO.Me.Inventory('mainhand').Type():find('Piercing') then
        tableName.type6Index = 3
        tableName.wep9Index = 2
    elseif mq.TLO.Me.Inventory('mainhand').Type():find('Martial') then
        tableName.type6Index = 6
        tableName.wep9Index = 2
    elseif mq.TLO.Me.Inventory('mainhand').Type():find('2H') then
        tableName.type6Index = 1
        tableName.wep9Index = 1
    end

    -- Set aug level and change type 9 if needed
    if tableName.myLevel >= 105 then
        tableName.augPrefixIndex = 7
        if tableName.myClassGroup == 'Melee' then
            tableName.type9Index_armor= 1
        elseif tableName.myClassGroup == 'Caster' then
            tableName.type9Index_armor= 6
        elseif tableName.myClassGroup == 'Priest' then
            tableName.type9Index_armor= 5
        end
    elseif tableName.myLevel >= 100 then
        tableName.augPrefixIndex = 6
        if tableName.myClassGroup == 'Caster' or tableName.myClassGroup == 'Hybrid' then
            tableName.type9Index_armor= 4
        end
    elseif tableName.myLevel >= 95 then
        tableName.augPrefixIndex = 5
    elseif tableName.myLevel >= 90 then
        tableName.augPrefixIndex = 4
    elseif tableName.myLevel >= 85 then
        tableName.augPrefixIndex = 3
    elseif tableName.myLevel >= 80 then
        tableName.augPrefixIndex = 2
    elseif tableName.myLevel >= 75 then
        tableName.augPrefixIndex = 1
    end
    return tableName -- return updated data
end

-- helper functions -- FUTURE: MOve to another module for better maintainability
function M.printDebug(s,doPrintFlag)
    if doPrintFlag then
        print(s)
    end
end
function M.isEmpty(s)
    return s == nil or s == ""
end
function M.moveToVendor(typeId)
    -- moves to a spot where we can access all the necessary vendors
    print('DEBUG: moveToVendor: typeID is ',typeId)
    print('DEBUG: moveToVendor: Montelio distance is ' .. mq.TLO.Spawn('Montelio').Distance())
    print('DEBUG: moveToVendor: Dabowe distance is ' .. mq.TLO.Spawn('Dabowe').Distance())
    print('DEBUG: moveToVendor: Shirlell distance is ' .. mq.TLO.Spawn('Shirlell').Distance())

    if mq.TLO.Spawn('Montelio').Distance() > 20 or mq.TLO.Spawn('Dabowe').Distance() > 20 or mq.TLO.Spawn('Shirlell').Distance() > 20 then
        mq.cmd('/easyfind nav locyxz 1331.81, 135.05, 63.49')
    end
end

function M.countAugNeeded(tableName,isArmor)
    -- iterate through table data and count the needed augs
    -- allows app to proceed to buying the needed augs
    -- Will set the tableName.currentAugmentNumNeeded feild in the table data
    local debugFlag = tableName.debugPrintFlag -- tableName.doMockAction -- false
    local dynamicKey_isCheckedType = 'isCheckedType' .. tableName.currentAugType -- dynamically create the table key (field) using concatenated strings with '..' concatenator command
    local dynamicKey_flagForRemovalType = 'flagForRemovalType' .. tableName.currentAugType -- dynamically create the table key (field) using concatenated strings with '..' concatenator command
    local dynamicKey_flagForInsertType = 'flagForInsertType' .. tableName.currentAugType -- dynamically create the table key (field) using concatenated strings with '..' concatenator command
    local dynamicKey_nameType = 'nameType' .. tostring(tableName.currentAugType) -- dynamically create the table key (field)
    local dynamicKey_isValid = 'isValid' .. tostring(tableName.currentAugType)

    -- M.printDebug(string.format('DEBUG dynamicKey_isCheckedType: ' .. dynamicKey_isCheckedType),debugFlag)
    -- M.printDebug(string.format('DEBUG dynamicKey_nameType: ' .. dynamicKey_nameType),debugFlag)
    -- M.printDebug(string.format('DEBUG dynamicKey_nameType: ' .. dynamicKey_isValid),debugFlag)
    print('DEBUG: countAugNeeded: currentTab is ' .. tableName.currentTab) -- filterTerm
    local slotList = tableName.slotName
    if M.isEmpty(tableName.currentTab) or isArmor then
        slotList = tableName.slotName
    else
        slotList = {tableName.currentTab}
    end
    

    tableName.currentAugmentNumNeeded = 0 -- reset counter    
    for _, slot in ipairs(slotList) do        
        local testVar = tableName.InventoryDataTable[slot]        
        -- M.printDebug(string.format('   DEBUG tableName.InventoryDataTable[slot].dynamicKey_isCheckedType: ' .. tostring(tableName.InventoryDataTable[slot].dynamicKey_isCheckedType)),debugFlag)
        -- Note on lua dynamic key indexing: using table[key1][key2] is a method to get access using dynamically assigned key values which can be strings or integers, etc
        if tableName.InventoryDataTable[slot].isArmor == isArmor and tableName.InventoryDataTable[slot][dynamicKey_isCheckedType] and tableName.InventoryDataTable[slot][dynamicKey_isValid] then
            -- type 9, need to check if its the desired name or else flag for replacement
            -- if tableName.InventoryDataTable[slot].itemtype ~= nil then
            --     M.printDebug('DEBUG: countAugNeeded: ' .. 'slot - ' .. slot .. ', type - ' .. tableName.InventoryDataTable[slot].itemtype, debugFlag)
            -- else
            --     M.printDebug('DEBUG: countAugNeeded: ' .. 'slot - ' .. slot .. ', type - ' .. 'nil', debugFlag)

            -- end
            M.printDebug('DEBUG: countAugNeeded: ' .. 'slot - ' .. slot .. ' - installed aug name is -- <' .. tableName.InventoryDataTable[slot][dynamicKey_nameType] .. '> - current Desired aug is <' .. tableName.currentAugName .. '>', debugFlag)
            -- Check if we need to insert a new aug
            -- FUTURE: Clean up this logic. its confusing and probably could be streamlined...
            if tableName.InventoryDataTable[slot][dynamicKey_nameType] ~= tableName.currentAugName or M.isEmpty(tableName.InventoryDataTable[slot][dynamicKey_nameType]) then
                tableName.currentAugmentNumNeeded = tableName.currentAugmentNumNeeded + 1
                tableName.InventoryDataTable[slot][dynamicKey_flagForRemovalType] = false -- init or reset
                tableName.InventoryDataTable[slot][dynamicKey_flagForInsertType] = true -- flag for insert new aug
                M.printDebug('DEBUG: countAugNeeded: ' .. 'slot - ' .. slot .. ' -- flagged for Insert',debugFlag)
            elseif tableName.InventoryDataTable[slot][dynamicKey_nameType] == tableName.currentAugName then
                tableName.InventoryDataTable[slot][dynamicKey_flagForInsertType] = false -- flag for insert new aug
                M.printDebug('DEBUG: countAugNeeded: ' .. 'slot - ' .. slot .. ' -- NOT flagged for Insert',debugFlag)
            end

            -- also check to see if we need to remove an old aug
            if tableName.InventoryDataTable[slot][dynamicKey_nameType] ~= tableName.currentAugName and not M.isEmpty(tableName.InventoryDataTable[slot][dynamicKey_nameType]) then
                tableName.InventoryDataTable[slot][dynamicKey_flagForRemovalType] = true -- set
                M.printDebug('DEBUG: countAugNeeded: ' .. 'slot - ' .. slot .. ' -- flagged for removal',debugFlag)
                -- tableName.InventoryDataTable[slot][dynamicKey_flagForInsertType] = true -- flag for insert new aug
            else
                tableName.InventoryDataTable[slot][dynamicKey_flagForRemovalType] = false -- set
                -- tableName.InventoryDataTable[slot][dynamicKey_flagForInsertType] = false -- 
                M.printDebug('DEBUG: countAugNeeded: ' .. 'slot - ' .. slot .. ' -- NOT flagged for removal',debugFlag)
                

            end
        else
            tableName.InventoryDataTable[slot][dynamicKey_flagForRemovalType] = false
            tableName.InventoryDataTable[slot][dynamicKey_flagForInsertType] = false
            -- M.printDebug('DEBUG: countAugNeeded: ' .. 'slot - ' .. slot .. ' -- NOT flagged for removal or insert',debugFlag)
            

        end
        
    end

    M.printDebug(string.format('DEBUG countAugNeeded: current num aug needed: ' .. tableName.currentAugmentNumNeeded),debugFlag)

    return tableName -- return the object
end -- countAugNeeded

-- function M.sleep(t) -- this doesnt work
--     local socket = require("socket")
--     print("Waiting for " .. t  .. " second...")
--     socket.sleep(t) -- Sleeps for exactly 1 second (supports fractional seconds)
--     print("Finished waiting.")
-- end

-- This function is used to set appropriate flags so that buying actions are initiated
function M.initiateBuyItem(tableName,buyTargetName)
    if buyTargetName == 'solvent' then
        if tableName.currentSolvNumNeeded > 0 then
            print('initiateBuyItem: Need to purchase solvents')
            tableName.doBuySolventFlag = true
        else
            print('initiateBuyItem: Do not Need to purchase solvents')
            tableName.doBuySolventFlag = false
        end

    elseif buyTargetName == 'aug' then
        if tableName.currentAugmentNumNeeded > 0 then
            print('initiateBuyItem: Need to purchase Aug')
            tableName.doBuyAugFlag = true
        else
            print('initiateBuyItem: Do not Need to purchase Aug')
            tableName.doBuyAugFlag = false
        end

    end
end

function M.initiateRemoveAug(tableName)
    tableName.doRemoveOldAugFlag = true
end
function M.initiateInsertNewAug(tableName)
    tableName.doInstallNewAugFlag = true
end
function M.initiateSellOldAug(tableName)
    tableName.doSellOldAugFlag = true
end

function M.buySolventNeeded(tableName)
    local totalOnHandL = 0
    local totalToBuyL = 0
    -- check that we in right zone -- FUTURE
    -- check we at right location -- FUTURE
    -- check we got money? -- FUTURE
    -- open window and buy stuff -- DONE
    -- update flags on what we bought -- ???
    

    -- Purchase solvents if we dont have enough already
    if tableName.currentSolvNumNeeded > 0 then
        -- mq.cmdf('/echo Need to purchase solvents!')
        print('buySolventNeeded: Need to purchase solvents')

        
        mq.delay(1000)
        -- tableName.doMockAction = false -- future: toggle with the checkbox in gui
        -- FUTURE: Add distance check from merchant
        if not mq.TLO.Window('Merchant').Open() and not tableName.doMockAction then
            mq.cmdf('/tar Dabowe')
            mq.delay(500)
            mq.cmdf('/usetarget')
            mq.delay(2500) -- wait for items to populate in the merchante window
        else
            print(' Debug mock actions - open vendor window')
        end

        -- iterate through the list of solvents and buy whatever number are needed
        for solv, scount in pairs(tableName.currentSolventNameList) do
            totalOnHandL = mq.TLO.FindItemCount(solv)() -- check inventory
            totalToBuyL = scount - totalOnHandL -- compute amount needed
            if not tableName.doMockAction then
                if totalToBuyL < 0 then
                    totalToBuyL = 0
                    print(' Skipping: Already Have enough <' .. solv .. '>') -- FUTURE: Make debug statement only
                else
                    print(' Now buying <' .. scount .. '> ' .. ' <' .. solv .. '>') -- FUTURE: Make debug statement only
                    
                    mq.cmdf('/invoke ${Merchant.SelectItem[=%s]}', solv)
                    mq.delay(1500)
                    mq.cmdf('/invoke ${Merchant.Buy[%s]}', scount)
                    mq.delay(1500)
                    totalOnHandL = mq.TLO.FindItemCount(solv)() -- check inventory
                    if totalOnHandL ~= tableName.currentSolventNameList[solv] then
                        print(' Debug: we didnt buy enough or something went wrong')
                    else
                        -- FUTURE: Set some kind of flag to indicate we have the solvenets to remove the desired augs from equip
                    end
                    
                end
            else
                print('mock buying <' .. scount .. '> ' .. ' <' .. solv .. '>') -- FUTURE: Make debug statement only
            end
        end
        if not tableName.doMockAction then
            mq.cmdf('/notify MerchantWnd MW_Done_Button leftmouseup') -- close merch window
            mq.delay(1000)
        end
        
    else
        printf('\tHave enought solvents already. Not purchasing more')
    end
    


    return tableName -- FUTURE: Is this necessary?
end

-- mq.delay can not be used from 'unyeildable' threads. this below can be called from the main thread and will work
function M.testDelay() -- this can be called from the 'while' loop in init gui and it will work
    printf('test delay')
    mq.delay(1000)
    printf('... delayed 1 second extra')
end


function M.buyAugNeeded(tableName,isArmor)
    
    -- check that we in right zone
    -- check we at right location
    -- check we got remnants
    -- open window and buy stuff
    -- update flags on what we bought
    -- FUTURE: Check bag space

    local totalOnHandL = 0
    local packIdWhereFoundL = 0
    local slotIdWhereFoundL = 0
    local totalToBuyL = 0
    local dynamicKey_vendor = ''

-- Purchase solvents if we dont have enough already
    if tableName.currentAugmentNumNeeded > 0 then
        print('buyAugNeeded: Need to purchase aug')

        print('   buyAugNeeded: WIP need to check Remnants')
        

        print('buyAugNeeded: tableName.currentAugName' .. tableName.currentAugName)
        -- totalOnHandL = mq.TLO.FindItemCount(tableName.currentAugName)() -- check inventory
        totalOnHandL, packIdWhereFoundL, slotIdWhereFoundL = M.countiteminpack(tableName.currentAugName)
        print('buyAugNeeded: totalOnHandL' .. totalOnHandL)
        totalToBuyL = tableName.currentAugmentNumNeeded - totalOnHandL -- calculate number we need to buy
        print('buyAugNeeded: totalToBuyL' .. totalToBuyL)
        dynamicKey_vendor = 'type' .. tableName.currentAugType .. 'Vendor'
        print('buyAugNeeded: tableName[dynamicKey_vendor]: ' .. tableName[dynamicKey_vendor])
        if totalToBuyL > 0 then -- if we need to buy some

            -- open vendor window
            mq.delay(1000)
            -- tableName.doMockAction = false -- future: toggle with the checkbox in gui        
            if not mq.TLO.Window('Merchant').Open() and not tableName.doMockAction then
                M.moveToVendor(tableName.currentAugType)
                -- mq.cmdf('/tar Montelio') -- FUTURE: Make this use isArmor flag to switch between Montelio and Shirril(sp?)                
                mq.cmdf('/tar ' .. tableName[dynamicKey_vendor])
                mq.delay(500)
                mq.cmdf('/usetarget')
                mq.delay(3500) -- wait for items to populate in the merchante window
            else
                print('buyAugNeeded: Debug mock actions - open vendor window')
            end
        
        
            -- iterate until totalToBuyL == 0
            for iNum = 1,totalToBuyL do
                if not tableName.doMockAction then -- and we are not mock acting
                    print('buyAugNeeded: Now buying <' .. totalToBuyL .. '> ' .. ' <' .. tableName.currentAugName .. '>') -- FUTURE: Make debug statement only
                    printf('DEBUG: buyAugNeeded: cmdf is [ /invoke ${Merchant.SelectItem[=%s]} ]', tableName.currentAugName)
                    
                    mq.cmdf('/invoke ${Merchant.SelectItem[=%s]}', tableName.currentAugName) -- select the item
                    mq.delay(2000)
                    for iVal = 1,totalToBuyL do
                        mq.cmdf('/notify MerchantWnd MW_Buy_Button leftmouseup')
                        mq.delay(1200)

                        if mq.TLO.Window('ConfirmationDialogBox').Open() then
                            mq.cmdf('/notify ConfirmationDialogBox CD_Yes_Button leftmouseup')
                            mq.delay(1500)
                        end
                    end

                    
                    mq.cmdf('/notify MerchantWnd MW_Done_Button leftmouseup') -- close merch window
                    mq.delay(1100)

                    
                    
                else
                    printf('buyAugNeeded: mock buying <' .. totalToBuyL .. '><' .. tableName.currentAugName)
                end
            end
            -- check success                    
            totalOnHandL, packIdWhereFoundL, slotIdWhereFoundL = M.countiteminpack(tableName.currentAugName)
            if totalOnHandL ~= tableName.currentAugmentNumNeeded then
                print(' buyAugNeeded: we didnt buy enough or something went wrong')
            else
                -- FUTURE: Set some kind of flag to indicate we have the solvenets to remove the desired augs from equip
            end
        else
            printf(' buyAugNeeded: have enough augs in inventory already, not buying anything')
        end

        
        
    else
        printf('\tHave enought augs already. Not purchasing more') -- FUTURE Make debug statement
    end



return tableName -- FUTURE: Is this necessary?
end --- end buyAugNeeded()


function M.funremoveaug(tableName) --gearForAugsTable,augName,iType,doDebugFlag)


    local debugFlag = tableName.doMockAction -- local override for debug of function
    local dynamicKey_isCheckedType = 'isCheckedType' .. tableName.currentAugType -- dynamically create the table key (field) using concatenated strings with '..' concatenator command
    local dynamicKey_flagForRemovalType = 'flagForRemovalType' .. tableName.currentAugType -- dynamically create the table key (field) using concatenated strings with '..' concatenator command
    local dynamicKey_nameType = 'nameType' .. tostring(tableName.currentAugType) -- dynamically create the table key (field)
    local dynamicKey_solventType = 'solventType' .. tostring(tableName.currentAugType) -- dynamically create the table key (field)
    local dynamicKey_isValid = 'isValid' .. tostring(tableName.currentAugType)

    for _,slotName in ipairs(tableName.slotName) do
        -- printf('DEBUG: funremoveaug: ' .. dynamicKey_flagForRemovalType .. ' is ' .. tostring(tableName.InventoryDataTable[slotName][dynamicKey_flagForRemovalType]))
        if tableName.InventoryDataTable[slotName][dynamicKey_flagForRemovalType] then
            if tableName.doMockAction then
                -- print('DEBUG: MOCK removing aug from slot ' .. slotName)
                print('DEBUG: funremoveaug: MOCK removing <' .. tableName.InventoryDataTable[slotName][dynamicKey_nameType] .. '> from <' .. tableName.InventoryDataTable[slotName].itemName)
            else
                print('DEBUG: funremoveaug: ACTUALLY removing <' .. tableName.InventoryDataTable[slotName][dynamicKey_nameType] .. '> from <' .. tableName.InventoryDataTable[slotName].itemName)
                -- FUTURE: CHeck that we have the augment solvent that is needed (for robustness)
                -- printf('/removeaug "%s" "%s"', tableName.InventoryDataTable[slotName][dynamicKey_nameType], tableName.InventoryDataTable[slotName].itemName)
                mq.cmdf('/removeaug "%s" "%s"', tostring(tableName.InventoryDataTable[slotName][dynamicKey_nameType]), tostring(tableName.InventoryDataTable[slotName].itemName))
                mq.delay(1000)
                if mq.TLO.Window('ConfirmationDialogBox').Open() then
                    mq.cmdf('/notify ConfirmationDialogBox Yes_Button leftmouseup')
                    mq.delay(1000)
                end
                mq.cmdf('/autoinventory')
                mq.delay(1000)

                tableName.InventoryDataTable[slotName][dynamicKey_nameType] = "" -- its gone now
                tableName.InventoryDataTable[slotName][dynamicKey_solventType] = "" -- its gone now
                tableName.InventoryDataTable[slotName][dynamicKey_flagForRemovalType] = false -- reset flag

                -- FUTURE: CHeck that we actually removed the aug and stop if it didnt work for some reason (ie no solvent)

            end
            

            -- FUTURE: Add to list of augs to sell -- actually might want to just have a routine that finds and lists stuff in the bags (on the new tab for sell augs we created)
            
        end
    end


end -- end funremoveaug()

function M.finditeminpack(itemName)
    -- look through all bags to find a specific item
    -- used to ensure we have the aug or solvent we need for a particular operation
    local isItemFound = false
    local packIdWhereFound = -1
    local slotIdWhereFound = -1
    local pack = ''
    for i=1, mq.TLO.Me.NumBagSlots() do        
        pack = mq.TLO.Me.Inventory('pack' .. i)
        
        
        if not isItemFound then
            if pack.ID() and pack.Name() ~= itemName then
                for j=1, pack.Container() do
                    if pack.Item(j).Name() == itemName then
                        packIdWhereFound = i
                        slotIdWhereFound = j
                        mq.delay(500)
                        isItemFound = true
                    end
                end
            elseif pack.Name() == itemName then
            -- found in top level inventory
            -- FUTURE: This needs to be tested
                packIdWhereFound = i
                slotIdWhereFound = 0
            end
        end
    end
    print('DEBUG: finditeminpack: isItemFound - ' .. tostring(isItemFound) .. ', packIdWhereFound - ' .. packIdWhereFound .. ', slotIdWhereFound - ' .. slotIdWhereFound)
    return isItemFound, packIdWhereFound, slotIdWhereFound
end

function M.countiteminpack(itemName)
    -- look through all bags to find a specific item and count it
    -- also store the location for future use
    local isItemFound = false
    local packIdWhereFound = {}
    local slotIdWhereFound = {}
    local pack = ''
    local numFoundInPack = 0
    local iCount = 0

    for i=1, mq.TLO.Me.NumBagSlots() do        
        pack = mq.TLO.Me.Inventory('pack' .. i)

        if pack.ID() and pack.Name() ~= itemName then
            for j=1, pack.Container() do
                if pack.Item(j).Name() == itemName then
                    iCount = iCount + 1
                    packIdWhereFound[iCount] = i
                    slotIdWhereFound[iCount] = j
                end
            end
        elseif pack.Name() == itemName then -- what is this doing?
        -- found in top level inventory
        -- FUTURE: This needs to be tested
            iCount = iCount + 1
            packIdWhereFound[iCount]  = i
            slotIdWhereFound[iCount]  = 0
        end
    end
    numFoundInPack = iCount
    return numFoundInPack, packIdWhereFound, slotIdWhereFound
end

function M.insertNewAug(tableName)
    print('DEBUG: insertNewAug: inserting augs now...')    
    
    -- FUTURE: Better handle all the flags and stuff. this is messy

    local debugFlag = tableName.doMockAction -- local override for debug of function
    local dynamicKey_isCheckedType = 'isCheckedType' .. tableName.currentAugType -- dynamically create the table key (field) using concatenated strings with '..' concatenator command
    local dynamicKey_flagForRemovalType = 'flagForRemovalType' .. tableName.currentAugType -- dynamically create the table key (field) using concatenated strings with '..' concatenator command
    local dynamicKey_flagForInsertType = 'flagForInsertType' .. tableName.currentAugType
    local dynamicKey_nameType = 'nameType' .. tostring(tableName.currentAugType) -- dynamically create the table key (field)
    local dynamicKey_solventType = 'solventType' .. tostring(tableName.currentAugType) -- dynamically create the table key (field)
    local dynamicKey_isValid = 'isValid' .. tostring(tableName.currentAugType)
    local isItemFound = false
    local packIdWhereFound = -1
    local slotIdWhereFound = -1

    for _,slotName in ipairs(tableName.slotName) do
        
        M.printDebug('DEBUG: insertNewAug: slotName is ' .. slotName .. ', flagForInsert is ' .. tostring(tableName.InventoryDataTable[slotName][dynamicKey_flagForInsertType]), tableName.debugPrintFlag)
        
        if tableName.InventoryDataTable[slotName][dynamicKey_isCheckedType] and tableName.InventoryDataTable[slotName][dynamicKey_flagForInsertType] then
            -- first check that we have the augment in inventory
            
            if tableName.doMockAction and not debugFlag then                
                print('DEBUG: funinsertnewaug: MOCK inserting <' .. tableName.currentAugType .. '> to <' .. tableName.InventoryDataTable[slotName].itemName)
            else
                
                -- FUTURE: CHeck that we have the augment solvent that is needed (for robustness)
                print('DEBUG: funinsertnewaug: looking in pack for <' .. tableName.currentAugName .. '> to insert in <' .. tableName.InventoryDataTable[slotName].itemName)
                isItemFound = false -- initialize
                packIdWhereFound = -1
                slotIdWhereFound = -1
                isItemFound, packIdWhereFound, slotIdWhereFound = M.finditeminpack(tableName.currentAugName)

                if isItemFound then
                    print('DEBUG: funinsertnewaug: ACTUALLY inserting <' .. tableName.currentAugName .. '> to <' .. tableName.InventoryDataTable[slotName].itemName)
                    -- Pick up item from pack                    
                    if packIdWhereFound > 0 and slotIdWhereFound > 0 then
                        mq.cmdf('/itemnotify in %s %d leftmouseup', 'pack' .. packIdWhereFound, slotIdWhereFound)
                    elseif packIdWhereFound > 0 and slotIdWhereFound == 0 then
                        mq.cmdf('/itemnotify pack%d leftmouseup', packIdWhereFound)
                    else
                        printf('DEBUG: funinsertnewaug: something wrong, bad pack or slot id')
                    end
                    mq.delay(500)
                    -- insert the aug into the equipment                    
                    -- mq.cmdf('/insertaug %s', tableName.InventoryDataTable[slotName].itemName) -- 3-6-26: Item Name does not seem to work, possible /insertaug bug
                    M.printDebug(string.format('DEBUG: funinsertnewaug: command is /insertaug %d', tableName.InventoryDataTable[slotName].itemID), tableName.debugPrintFlag)
                    mq.cmdf('/insertaug %d', tableName.InventoryDataTable[slotName].itemID) -- ID seems to work though...
                    mq.delay(2000)

                    -- if success then -- FUTURE: AAdd a check condition
                    tableName.InventoryDataTable[slotName][dynamicKey_flagForInsertType] = false -- reset flag



                    -- FUTURE: Update the table data with the new aug name and type
                    -- FUTURE: Render the UI table with new data
                    -- mq.TLO.Me.Inventory[slotName]
                    local a,b = M.lookupinstalledaugandsolvent(slotName,tableName.currentAugType)
                    tableName.InventoryDataTable[slotName][dynamicKey_nameType] = a -- tableName.currentAugName
                    tableName.InventoryDataTable[slotName][dynamicKey_solventType] = b -- "needs to be updated in insertNewAug function"

                else
                    printf('DEBUG: funinsertnewaug: something wrong, didnt find the augment in inventory')
                end

                


            end
            

            -- FUTURE: Add to list of augs to sell
            
        end
    end

end

function M.sellOldAug(tableName)
    if tableName.userSelectedSellOldAugFlag then
        print('DEBUG: sellOldAug: selling old aug')
        print('   sellOldAug: Not yet defined')
    else
        print('DEBUG: sellOldAug: NOT selling old aug (because you didnt tell me you wanted to)')
    end
    
end





-- This will generate the agument name using the combo box selections
-- expected to be called from the GUI panel function
function M.genAugNames(tableName,isArmor)
    -- tableName is the table data from tableList.lua -- not great naming
    -- augType is the type 5|9|6
    -- isArmor is a boolean for if we are on the armor or weapon tab of the gui
    local augName
    local dynamicKey_typeSuffixA = 'type' .. tableName.currentAugType .. 'SuffixA_' .. tableName.currentTab
    -- print('DEBUG: genAugNames: dynamicKey_typeSuffixA - ',dynamicKey_typeSuffixA)

    -- build the aug names. assumes that the proper global prefix and suffix indicies have been set already!
    -- if tableName.currentAugType == 5 then
    --     augName = tableName.fixType.augPrefixA[tableName.augPrefixIndex] .. ' Sulstone of ' .. tableName.fixType.type5SuffixA[tableName.augSuffixIndex]
    -- elseif tableName.currentAugType == 6 then
    --     augName = tableName.fixType.augPrefixA[tableName.augPrefixIndex] .. ' Sulstone of ' .. tableName.fixType.type6SuffixA[tableName.augSuffixIndex]
    -- elseif tableName.currentAugType == 9 and isArmor then --gear == 'armor' then
    --     augName = tableName.fixType.augPrefixA[tableName.augPrefixIndex] .. ' Sulstone of ' .. tableName.fixType.type9SuffixA[tableName.augSuffixIndex]
    -- elseif tableName.currentAugType == 9 and not isArmor then --gear == 'weps' then
    --     augName = tableName.fixType.augPrefixA[tableName.augPrefixIndex] .. ' Sulstone of ' .. tableName.fixType.wep9SuffixA[tableName.augSuffixIndex]
    -- end

    augName = tableName.fixType.augPrefixA[tableName.augPrefixIndex] .. ' Sulstone of ' .. tableName.fixType[dynamicKey_typeSuffixA][tableName.augSuffixIndex]
    print('DEBUG: genAugNames: Aug Name is <' .. augName .. '>')

    return augName
end




function M.countSolventsNeeded(tableName,isArmor,typeNum)
    -- count the number of sovents needed
    local solvNameL, augNameL
    local augCount, solvCount, augCost = 0,0,0
    local augList = {}
    local solvList = {}
    local totalOnHand = 0
    local totalToBuy = 0
    --solvList['this one']=100
    print('DEBUG: countSolventsNeeded: currentTab is ' .. tableName.currentTab) -- filterTerm
    local slotList = tableName.slotName
    if M.isEmpty(tableName.currentTab) or isArmor then
        slotList = tableName.slotName
    else
        slotList = {tableName.currentTab} -- filterTerm
    end

    -- go count the solvents needed by quantity of each type


    -- FUTURE: This is very cumbersome logic and there has to be better ways to do this
    -- FUTURE: Need to make this use generic dynamic variable names and eliminate the redundancy (see other places in module.lua for examples)

    for _, slot in ipairs(slotList) do
        -- Future: Make helper function since this is repeatedly used
        -- check type 9
        if typeNum == 9 then
            -- printf('-> slot %s, isCheckedTYpe9 %d',slot,tableName.InventoryDataTable[slot].isCheckedType9)
            if tableName.InventoryDataTable[slot].isArmor == isArmor and tableName.InventoryDataTable[slot].isCheckedType9 then
                augNameL = tableName.InventoryDataTable[slot].nameType9
                solvNameL = tableName.InventoryDataTable[slot].solventType9
                
                if not M.isEmpty(solvNameL) then
                    printf('    counted one: %s',solvNameL)
                    tableName.InventoryDataTable[slot].flagForRemovalType9 = true
                    if solvList[solvNameL] then
                        solvList[solvNameL] = solvList[solvNameL] + 1
                    else
                        solvList[solvNameL] = 1
                    end
                else
                    tableName.InventoryDataTable[slot].flagForRemovalType9 = false
                end
            end
        end -- end type 9 counting
        -- FUTURE: Make these elseif....
        -- FUTURE: really need to just use dynamic generated keys and use 1 condition statement
        if typeNum == 5 then
            -- printf('-> slot %s, isCheckedTYpe9 %d',slot,tableName.InventoryDataTable[slot].isCheckedType9)
            if tableName.InventoryDataTable[slot].isArmor == isArmor and tableName.InventoryDataTable[slot].isCheckedType5 then
                augNameL = tableName.InventoryDataTable[slot].nameType5
                solvNameL = tableName.InventoryDataTable[slot].solventType5
                
                if not M.isEmpty(solvNameL) then
                    printf('    counted one: %s',solvNameL)
                    if solvList[solvNameL] then
                        solvList[solvNameL] = solvList[solvNameL] + 1
                    else
                        solvList[solvNameL] = 1
                    end
                end
            end
        end -- end type 5 counting

        if typeNum == 6 then
            -- printf('-> slot %s, isCheckedTYpe9 %d',slot,tableName.InventoryDataTable[slot].isCheckedType9)
            if tableName.InventoryDataTable[slot].isArmor == isArmor and tableName.InventoryDataTable[slot].isCheckedType6 then
                augNameL = tableName.InventoryDataTable[slot].nameType6
                solvNameL = tableName.InventoryDataTable[slot].solventType6
                
                if not M.isEmpty(solvNameL) then
                    printf('    counted one: %s',solvNameL)
                    if solvList[solvNameL] then
                        solvList[solvNameL] = solvList[solvNameL] + 1
                    else
                        solvList[solvNameL] = 1
                    end
                end
            end
        end -- end type 6 counting

        


    end

    tableName.currentSolventNameList = solvList -- future: Streamline this, use table.insert() above

    for sName,sCount in pairs(solvList) do
        totalOnHand = mq.TLO.FindItemCount(sName)() -- Note: This will count stuff in bank too. not great.
        printf('\agDebug: \t\axcheckSolvents: Need \at%s \ao%s', sCount, sName)
        printf('\agDebug: \t\axcheckSolvents: have: invSolv = \at%d \ao%s', totalOnHand,sName)
        if totalOnHand >= sCount then
            --scount = tonumber(scount) - invSolv
            totalToBuy = 0;
        else
            totalToBuy = totalToBuy + tonumber(sCount) - totalOnHand;
        end
        printf('\agDebug: \t\axcheckSolvents: must buy = \at%d \ao%s', totalToBuy,sName)
    end

    tableName.currentSolvNumNeeded = totalToBuy

    
    return tableName -- solvCount, solvList, totalToBuy
end -- end countSolventsNeeded

-- deprecated - old version of function that has been replaced
-- -- look through inventory and determine if we need to buy augments and solvents and how many of each type
-- function M.checkAugs(gearTable, type, level, suffix)
--     -- First, go count the augs in the gear using countAugs() function
--     local count, name, cost, gearForAugs, removedAugs, solvNames --= countAugs(gearTable, type, level, suffix)
--     --local totalSolvToBuy = checksolvents(solvNames)
--     local origCount = count
--     local found = 0

--     for i=1, mq.TLO.Me.NumBagSlots() do
--         local pack = 'pack' .. i

--         if mq.TLO.Me.Inventory(pack)() ~= nil then
--             if mq.TLO.Me.Inventory(pack).Container() > 0 then
--                 for j=1, mq.TLO.Me.Inventory(pack).Container() do
--                     if mq.TLO.Me.Inventory(pack).Item(j).Name() == name then
--                         count = count - 1
--                         found = found + 1
--                     end
--                 end
--             elseif mq.TLO.Me.Inventory(pack)() == name then
--                 count = count - 1
--                 found = found + 1
--             end
--         elseif mq.TLO.Me.Inventory(pack).Name() == name then
--             count = count - 1
--             found = found + 1
--         end
--     end

--     if count < 0 then
--         count = 0
--     end

--     -- if found > 0 and found == origCount then
--     --     printf('You have \at%d \axof \at%d \ao%s. \n\agNo need to purchase more.', found, origCount, name)
--     -- elseif found > 0 and found < origCount then
--     --     printf('You have \at%d \axof \at%d \ao%s. \n\ax\axYou need to purchase %d more.', found, origCount, name, count)
--     -- elseif count == 0 then
--     --     printf('You do not need to purchase any \ao%s', name)
--     -- else
--     --     printf('Need to purchase \at%d \ao%s \ax\axfor \at%d \axRemnants.', count, name, cost)
--     -- end




--     -- -- Note: This should be some kind of seperate funciton call, copied here to get answer quickly until then
--     -- if level == 1 then
--     --     cost = count * 50
--     -- elseif level == 2 then
--     --     cost = count * 90
--     -- elseif level == 3 then
--     --     cost = count * 190
--     -- elseif level == 4 then
--     --     cost = count * 380
--     -- elseif level == 5 then
--     --     cost = count * 630
--     -- elseif level == 6 then
--     --     cost = count * 940
--     -- elseif level == 7 then
--     --     cost = count * 1250
--     -- end

--     --printf('checkAugs() Info - name is \at%s',name)
--     --printf('checkAugs() Info - found is \at%d',found)
--     --printf('checkAugs() Info - count is \at%d',count)
--     --printf('checkAugs() Info - origCount is \at%d',origCount)
--     --printf('checkAugs() Info - cost is \at%d',cost)
--     --printf('checkAugs() Info - cost is \at%d',cost)


--     -- 1/30/25: added these returns
--     return origCount, found, count, cost
-- end

function M.lookupinstalledaugandsolvent(slotName,slotType)
    local gear = mq.TLO.Me.Inventory(slotName)
    local solventName = ""
    local installedAugName = ""
    -- if gear.Name() ~= nil -- FUTURE: CHeck for nil for robustness
    print('DEBUG lookupinstalledaugandsolvent: name is ' .. gear.Name())
    for iSlot = 1,4 do
        if not gear.AugSlot(iSlot).Empty() then
            if gear.AugSlot(iSlot).Type() == slotType then
                installedAugName = gear.AugSlot(iSlot).Name()
                solventName = gear.AugSlot(iSlot).Solvent.Name()
            end
        end
    end
    return installedAugName, solventName
end

-- Get the gear tables from inventory
function M.loadgeartable(tableName,slotList,setFlags)
    --local gearTable = tableList.InventoryDataTable -- assign using object in tables.lua
    -- FUTURE: Change the input tableName to be the .InventoryList table from tables...
    -- FUTURE: Need to really clean up the tableName variable usage as its ambiguous all over the place
    --          sometimes its the tableList() and sometimes its tableList.inventoryTable
    local gearTable = 'did it work'
    print('doing stuff to load inventory')
    

    -- Loop through all the desired slots in slotList
    -- Note: We used to seperate stuff by vis vs nonvis but now we just seperate by armor, main/offhand, and ranged slot
    --        The logic for all the seperatino is done on the UI tab rendoring using flags for filtering
    for _, slot in ipairs(slotList) do
        --table.insert(VisGear, mq.TLO.Me.Inventory(slot))
        --printf('   VisGear list: %s',mq.TLO.Me.Inventory(slot).Name())
        -- Populate the data table with information
        local gear = mq.TLO.Me.Inventory(slot)
        --DataTableVis[slot].itemName = mq.TLO.Me.Inventory(slot).Name()
        tableName[slot].itemName = gear.Name()
        tableName[slot].itemType = gear.Type()
        tableName[slot].itemID = gear.ID()

        -- TO DO: Add a check to set an armor or weapon flag for filtering by tab
        if slot == 'mainhand' or slot == 'offhand' or slot == 'ranged' then
            tableName[slot].isArmor = false
        else
            tableName[slot].isArmor = true
        end

    
        -- Debug Print the info that we want in the DataTableVis
        if gear.Name() ~= nil then
            -- printf('-Item Name: %s, %s',slot, gear.Name()); -- debug print
            tableName[slot].itemName = gear.Name()
            tableName[slot].isValid = true
        
            for iSlot = 1,5 do -- for loop for index 1 to 5 -- ranged bows have 5 slots...
            
                -- set defaults
                if iSlot == 1 then -- need names to be empty if there is nothing there, so set defaults
                tableName[slot].nameType9 = ""
                tableName[slot].solventType9 = ""
                tableName[slot].nameType5 = ""
                tableName[slot].solventType5 = ""
                tableName[slot].isValid5 = false
                tableName[slot].isValid9 = false
                end
            
                -- FUTURE: Replace this stuff below with the simpler function lookupinstalledaugandsolvent()
                -- use some logic to set table entries -- future: Streamline this logic so its not redundant
                if not gear.AugSlot(iSlot).Empty() then -- if this slot is not empty
                    if gear.AugSlot(iSlot).Type() == 5 then
                        -- printf('    ---> occupied slot %d, type %d',iSlot, gear.AugSlot(iSlot).Type()) -- debug print
                        -- printf('         ---> Aug Name: %s ',gear.AugSlot(iSlot).Name());
                        -- printf('             ---> Solvent: %s ',gear.AugSlot(iSlot).Solvent.Name())

                        tableName[slot].nameType5 = gear.AugSlot(iSlot).Name()
                        tableName[slot].solventType5 = gear.AugSlot(iSlot).Solvent.Name()
                        tableName[slot].isValid5 = true

                    elseif gear.AugSlot(iSlot).Type() == 9 then
                        -- printf('    ---> occupied slot %d, type %d',iSlot, gear.AugSlot(iSlot).Type()) -- debug print
                        -- printf('         ---> Aug Name: %s ',gear.AugSlot(iSlot).Name());
                        -- printf('             ---> Solvent: %s ',gear.AugSlot(iSlot).Solvent.Name())

                        tableName[slot].nameType9 = gear.AugSlot(iSlot).Name()
                        tableName[slot].solventType9 = gear.AugSlot(iSlot).Solvent.Name()
                        tableName[slot].isValid9 = true
                    elseif gear.AugSlot(iSlot).Type() == 6 then
                        
                        tableName[slot].nameType6 = gear.AugSlot(iSlot).Name()
                        tableName[slot].solventType6 = gear.AugSlot(iSlot).Solvent.Name()
                        tableName[slot].isValid6 = true
                    end
                elseif gear.AugSlot(iSlot).Empty() then
                    if gear.AugSlot(iSlot).Type() == 5 then                        
                        tableName[slot].nameType5 = ""
                        tableName[slot].solventType5 = ""
                        tableName[slot].isValid5 = true
                    elseif gear.AugSlot(iSlot).Type() == 9 then                        
                        tableName[slot].nameType9 = ""
                        tableName[slot].solventType9 = ""
                        tableName[slot].isValid9 = true
                    elseif gear.AugSlot(iSlot).Type() == 6 then                        
                        tableName[slot].nameType6 = ""
                        tableName[slot].solventType6 = ""
                        tableName[slot].isValid6 = true
                    
                    end -- check for empty aug slot
                end -- check for empty
            end -- iSlot loop
        else
            printf('------- no item here: %s, %s',slot,gear.Name());
            tableName[slot].isValid = false
        end
    end
    return tableName
end -- end M.loadgeartable

function M.drawuielements()
    local items = { "Entry 1", "Entry 2", "Entry 3" }
    local selected_item_index = 1 
    imgui.Separator()
    local changed = imgui.Combo("Type 9", selected_item_index, items)
    local changed = imgui.Combo("Type 5", selected_item_index, items)
    -- imgui.Combo(' ', augPrefixIndex, augPrefix, #augPrefix)

end

-- Create a wrapper that can be easily used to create a variet of combo boxes for each type of augment
function M.comboWrapper(idVal,tableName,typeId,isArmor,equipType )
    local width = imgui.GetWindowWidth()
    local combo_width = width * 0.25 
    
    --  inputs: isArmor, idVal, typeId, equipType, tableName
        -- imgui.Text('Type 5: ')
        -- future: isArmor not needed anymore, equipType has the info needed
        local dynamicKey_typeIdIndex = 'type' .. typeId .. 'Index_'
        local dynamicKey_fixType = 'type' .. typeId .. 'Suffix_'
        local isChanged = false


        idVal = idVal + 1
        imgui.PushID(idVal) -- create unique gui object ID
        if imgui.Button('Check All##' .. typeId .. 'A') then
            print('checking all slots for type ' .. typeId)
            local dynamicKey_isCheckedType = 'isCheckedType' .. typeId

            local slotList = tableName.slotName
            if isArmor then
                slotList = tableName.slotName
            else
                slotList = {equipType} -- filterTerm
            end

            for iVal, rowName in ipairs(slotList) do
                if tableName.InventoryDataTable[rowName].isArmor == isArmor then
                    -- print(tableName.InventoryDataTable[rowName][dynamicKey_isCheckedType])
                    tableName.InventoryDataTable[rowName][dynamicKey_isCheckedType] = true
                end
            end
        end
        imgui.PopID() -- goes with PushID()

        imgui.SameLine()
        idVal = idVal + 1
        imgui.PushID(idVal) -- create unique gui object ID
        if imgui.Button('Check None##' .. typeId .. 'A') then
            print('un-checking all slots for type ' .. typeId)
            local dynamicKey_isCheckedType = 'isCheckedType' .. typeId

            local slotList = tableName.slotName
            if isArmor then
                slotList = tableName.slotName
            else
                slotList = {equipType} -- filterTerm
            end

            for iVal, rowName in ipairs(slotList) do
                if tableName.InventoryDataTable[rowName].isArmor == isArmor then
                    -- print(tableName.InventoryDataTable[rowName][dynamicKey_isCheckedType])
                    tableName.InventoryDataTable[rowName][dynamicKey_isCheckedType] = false
                end
            end
        end
        imgui.PopID() -- goes with PushID()
        imgui.SameLine()
        imgui.Text('Type ' .. typeId .. ': ')
        imgui.SameLine()
        idVal = idVal + 1
        imgui.PushID(idVal) -- create unique gui object ID
        
        
        dynamicKey_typeIdIndex = dynamicKey_typeIdIndex .. equipType
        dynamicKey_fixType = dynamicKey_fixType .. equipType

            
        imgui.SetNextItemWidth(combo_width)
        tableName[dynamicKey_typeIdIndex], isChanged = imgui.Combo("", tableName[dynamicKey_typeIdIndex], tableName.fixType[dynamicKey_fixType], #(tableName.fixType[dynamicKey_fixType]))
        imgui.PopID() -- goes with PushID()

        -- imgui.SameLine()
        -- idVal = idVal + 1
        -- imgui.PushID(idVal) -- create unique gui object ID
        -- if imgui.Button('Check All##' .. typeId .. 'A') then
        --     print('checking all slots for type ' .. typeId)
        -- end
        -- imgui.PopID() -- goes with PushID()

        -- imgui.SameLine()
        -- idVal = idVal + 1
        -- imgui.PushID(idVal) -- create unique gui object ID
        -- if imgui.Button('Check None##' .. typeId .. 'A') then
        --     print('un-checking all slots for type ' .. typeId)
        -- end
        -- imgui.PopID() -- goes with PushID()
        

        
        
        imgui.SameLine()
        if imgui.Button('Run Precheck##' .. typeId .. 'A') then
            print('Checking type ' .. typeId .. ' augments and solvents...')
            
            -- print('add type5 script here')
            tableName.currentTab = equipType -- set for filtering slotList in subroutines -- Clunky
            tableName = M.countSolventsNeeded(tableName,isArmor,typeId)
            tableName.augSuffixIndex = tableName[dynamicKey_typeIdIndex] --tableName.type5Index -- set index based on button pressed
            print('DEBUG: comboWrapper: augSuffixIndex = '.. tableName.augSuffixIndex)
            tableName.currentAugType = typeId
            tableName.currentAugName = M.genAugNames(tableName,isArmor) -- FUTURE: set the table.desiredNameType9 and 5 and 6 and...
            
            M.countAugNeeded(tableName,isArmor) -- set flagForRemovalType<>
        end
        imgui.SameLine()
        if imgui.Button('Run the script##' .. typeId .. 'A') then
            print('WARNING: Need to fully test this stuff...')
            print('  3-10-26: have tested: armor type9 and type5')

            print('RUN SCRIPT: Checking type ' .. typeId .. ' augments and solvents...')

            tableName.currentTab = equipType
            tableName = M.countSolventsNeeded(tableName,isArmor,typeId)
            tableName.augSuffixIndex = tableName[dynamicKey_typeIdIndex] --tableName.type5Index -- set index based on button pressed
            tableName.currentAugType = typeId
            tableName.currentAugName = M.genAugNames(tableName,isArmor) -- FUTURE: set the table.desiredNameType9 and 5 and 6 and...            
            M.countAugNeeded(tableName,isArmor) -- set flagForRemovalType<>       


            -- FUTURE: NEed to add some check conditions to stop progress if something goes wrong (like if we didnt buy the aug because the name was spelled wrong...)
            M.initiateBuyItem(tableName,'solvent') -- sets buy flag
            M.initiateBuyItem(tableName,'aug') -- sets buy flag
            M.initiateRemoveAug(tableName) -- will remove old augs if necessary
            M.initiateInsertNewAug(tableName)
            M.initiateSellOldAug(tableName)
            -- M.initiateAllTable(tableName) -- FUTURE: Probably want something to make sure everything is in default state



        end
        return idVal, tableName -- is tableName return needed??
end

function M.drawAugSellTab()
    -- tab to handle selling old augs in inventory
    -- Need a list of all the augs that are ffound, where they are, and a checkbox to allow user to sell them
    -- Need a 'select all' button
    -- Need a 'sell' button
    if imgui.BeginTabItem('Sell Augs') then
        imgui.Text('coming soon...')
        imgui.Text('sell old augs in inventory')
        imgui.EndTabItem()
    end

end

function M.drawEquipmentTab(tableName,isArmor,equipType)
    -- if we are drawing the armor tab, only show type 5 and 9
    --   weapon tab needs to show type 5/6/9
    local idVal = 0
    local dynamicKey_nameType
    -- local equipType = 'None'
    -- if isArmor then
    --     equipType = 'Armor'
    -- else
    --     equipType = 'Weapons'
    -- end

    if tableName == nil then
        return -- future: Added this to keep from crashing when minimized window. need more robust thing to make sure tableName is initialized...
        -- print(' --- gear table loaded --- ')
        -- tableName = M.setDefaultAugs(tableName)
        -- print(' -- loaded defaults configs')
    end

    if imgui.BeginTabItem(equipType) then
        -- FUTURE: this redraws everything every frame. maybe it could be done more efficiently to only redraw if stuff changes or something?

        -- local doVis, doNonVis, augPrefixIndex, augPrefix,
        -- local doVis, doNonVis, sellOldAugs = true,true,true
        -- local makeType = 5
        -- local makeGear = 'armor'
        -- local suffix = 0


        -- imgui.Text('Slots:    ')
        -- imgui.SameLine()
        -- doVis = imgui.Checkbox('Visible', doVis)
        -- imgui.SameLine()
        -- doNonVis = imgui.Checkbox('Nonvisible', doNonVis)
        local ringList = tableName.fixType.augPrefix
        local valInd = tableName.augPrefixIndex
        local isChanged = false
        
        -- valInd, isChanged  = imgui.Combo('test combo',valInd, ringList, #(ringList))
        -- if isChanged then
        --     tableName.augPrefixIndex = valInd
        --     print('something happened  ' .. tostring(isChanged) .. ' - valInd: ' .. valInd)
        --     print(tableName.fixType.augPrefix[valInd])
        -- end

        -- display the level box
        imgui.Text('Level     ')
        imgui.SameLine()
        imgui.SetNextItemWidth(imgui.GetWindowWidth() * 0.35)
        tableName.augPrefixIndex = imgui.Combo(' ', tableName.augPrefixIndex, tableName.fixType.augPrefix, #(tableName.fixType.augPrefix)) -- box id, index, item list, number of items in list
        
        imgui.SameLine()
        tableName.userSelectedSellOldAugFlag = imgui.Checkbox(' Sell Augs', tableName.userSelectedSellOldAugFlag)

        -- ********** Make wrapper
        --  inputs: isArmor, idVal, typeId, equipType, tableName
        idVal, tableName = M.comboWrapper(idVal,tableName,5,isArmor,equipType )
        -- imgui.Text('Type 5: ')
        -- imgui.SameLine()
        -- idVal = idVal + 1
        -- imgui.PushID(idVal) -- create unique gui object ID
        -- -- FUTURE: Make a generic combo box, use indVal. set indVal to currentAugSuffixIndex, currentAugPrefixIndex
        -- --    pass current indicies and the fixType lists to a function to build the name
        -- if isArmor == true then
        --     tableName.type5Index_armor = imgui.Combo("", tableName.type5Index_armor, tableName.fixType.type5Suffix, #(tableName.fixType.type5Suffix))
        -- elseif isArmor == false and equipType == 'ranged' then
        --     tableName.type5Index_ranged = imgui.Combo("", tableName.type5Index_ranged, tableName.fixType.type5Suffix, #(tableName.fixType.type5Suffix))
        -- elseif isArmor == false and equipType == 'mainhand' then
        --     tableName.type5Index_mainhand = imgui.Combo("", tableName.type5Index_mainhand, tableName.fixType.type5Suffix, #(tableName.fixType.type5Suffix))
        -- elseif isArmor == false and equipType == 'offhand' then
        --     tableName.type5Index_offhand = imgui.Combo("", tableName.type5Index_offhand, tableName.fixType.type5Suffix, #(tableName.fixType.type5Suffix))
        -- end
        -- imgui.PopID() -- goes with PushID()
        -- imgui.SameLine()
        -- if imgui.Button('Check Augs##5A') then
        --     print('Checking type 5 augments and solvents...')
        --     print('add type5 script here')
        --     tableName = M.countSolventsNeeded(tableName,isArmor,5)            
        --     tableName.augSuffixIndex = tableName.type5Index -- set index based on button pressed
        --     tableName.currentAugType = 5
        --     tableName.currentAugName = M.genAugNames(tableName,isArmor) -- FUTURE: set the table.desiredNameType9 and 5 and 6 and...
        --     M.countAugNeeded(tableName,isArmor) -- set flagForRemovalType<>
        -- end
        -- imgui.SameLine()
        -- if imgui.Button('Run Script##5A') then
        --     print('add armor type5 script here')
        -- end
        -- ************** end wrapper

        if not isArmor then -- only add this to the weapons tabs
            idVal, tableName = M.comboWrapper(idVal,tableName,6,isArmor,equipType )
            -- imgui.Text('Type 6: ')
            -- imgui.SameLine()
            -- idVal = idVal + 1
            -- imgui.PushID(idVal)
            -- -- tableName.type6Index = imgui.Combo("", tableName.type6Index, tableName.fixType.type6Suffix, #(tableName.fixType.type6Suffix))
            -- if isArmor == false and equipType == 'ranged' then
            --     tableName.type6Index_ranged = imgui.Combo("", tableName.type6Index_ranged, tableName.fixType.type6Suffix, #(tableName.fixType.type6Suffix))
            -- elseif isArmor == false and equipType == 'mainhand' then
            --     tableName.type6Index_mainhand = imgui.Combo("", tableName.type6Index_mainhand, tableName.fixType.type6Suffix, #(tableName.fixType.type6Suffix))
            -- elseif isArmor == false and equipType == 'offhand' then
            --     tableName.type6Index_offhand = imgui.Combo("", tableName.type6Index_offhand, tableName.fixType.type6Suffix, #(tableName.fixType.type6Suffix))
            -- end
            -- imgui.PopID()
            -- imgui.SameLine()
            -- if imgui.Button('Check Augs##6A') then
            --     print('Checking type 6 augments and solvents...')
            --     print('add type6 script here')
            -- end
            -- imgui.SameLine()
            -- if imgui.Button('Run Script##6A') then
            --     print('add armor type6 script here')
            -- end
        end

        idVal, tableName = M.comboWrapper(idVal,tableName,9,isArmor,equipType )
        -- imgui.Text('Type 9: ')
        -- imgui.SameLine()
        -- idVal = idVal + 1
        -- imgui.PushID(idVal)
        -- if isArmor == true then
        --     tableName.type9Index_armor= imgui.Combo("", tableName.type9Index_armor, tableName.fixType.type9Suffix, #(tableName.fixType.type9Suffix))
        -- elseif isArmor == false and equipType == 'ranged' then
        --     tableName.type9Index_ranged = imgui.Combo("", tableName.type9Index_ranged, tableName.fixType.ranged9Suffix, #(tableName.fixType.ranged9Suffix))
        -- elseif isArmor == false and equipType == 'mainhand' then
        --     tableName.type9Index_mainhand = imgui.Combo("", tableName.type9Index_mainhand, tableName.fixType.mainhand9Suffix, #(tableName.fixType.mainhand9Suffix))
        -- elseif isArmor == false and equipType == 'offhand' then
        --     tableName.type9Index_offhand = imgui.Combo("", tableName.type9Index_offhand, tableName.fixType.offhand9Suffix, #(tableName.fixType.offhand9Suffix))
        -- end
        -- imgui.PopID()
        -- imgui.SameLine()
        -- if imgui.Button("Check##9A") then
        --     print('Checking type 9 augments and solvents...')
            
        --     tableName = M.countSolventsNeeded(tableName,isArmor,9) -- counts number of certain type of augs that need solvents to remove
        --     tableName.augSuffixIndex = tableName.type9Index_armor-- set index based on button pressed
        --     tableName.currentAugType = 9
        --     tableName.currentAugName = M.genAugNames(tableName,isArmor) -- FUTURE: set the table.desiredNameType9 and 5 and 6 and...
        --     M.countAugNeeded(tableName,isArmor) -- set flagForRemovalType<>
        -- end -- end check

        -- imgui.SameLine()
        -- if imgui.Button("Run Script##9A") then


        --     print('RUN SCRIPT: Checking type 9 augments and solvents...')

        --     tableName = M.countSolventsNeeded(tableName,isArmor,9)

        --     tableName.augSuffixIndex = tableName.type9Index_armor-- set index based on button pressed
        --     tableName.currentAugType = 9
        --     tableName.currentAugName = M.genAugNames(tableName,isArmor) -- FUTURE: set the table.desiredNameType9 and 5 and 6 and...
        --     M.countAugNeeded(tableName,isArmor) -- set flagForRemovalType<>            


        --     M.initiateBuyItem(tableName,'solvent') -- sets buy flag
        --     M.initiateBuyItem(tableName,'aug') -- sets buy flag
        --     M.initiateRemoveAug(tableName) -- will remove old augs if necessary
        --     M.initiateInsertNewAug(tableName)
        --     M.initiateSellOldAug(tableName)
        --     -- M.initiateAllTable(tableName) -- FUTURE: Probably want something to make sure everything is in default state


        -- end

        
        imgui.Separator()
        -- local isArmor = true
        local displayType = 0 -- 0: all, 1:vis only, 2:non vis only
        -- draw the gear table UI
        -- M.drawGearTablev2(tableName.InventoryDataTable,tableName.slotName,isArmor,displayType)
        -- M.drawGearTablev2(tableName,isArmor,displayType)
        M.drawGearTablev2(tableName,isArmor,equipType)
        imgui.Text('')
        imgui.EndTabItem()
    end
    return tableName
end



-- function to run the window
function M.drawPlayerInfo()
    imgui.Text(mq.TLO.Me.Name() .. '.  Level: ' .. mq.TLO.Me.Level() .. ' ' .. mq.TLO.Me.Class.Name())
    imgui.SameLine(350)

    if imgui.Button('Go to Vendors') then
        -- local command = mq.TLO.Zone.ShortName() == 'pohealth' and '/easyfind nav locyxz 1331.81, 135.05, 63.49' or '/travelto "pohealth" @ nav locyxz 1331.81, 135.05, 63.49'
        -- mq.cmd(command)
        M.moveToVendor(0)
    end

    imgui.SameLine()
    if imgui.Button('Stop Nav') then
        mq.cmd('/nav stop')
    end

    imgui.Text('Remnants of Tranquility: %d', mq.TLO.Me.AltCurrency('Remnants of Tranquility')())
    imgui.SameLine(455)
    doDebug = imgui.Checkbox('Debug', false)
    imgui.Text('\n')
end

function M.drawinteractivecontrols()

end


-- function M.drawGearTablev2(tableName,slotList,isArmor,displayType)
function M.drawGearTablev2(inventoryTable,isArmor,filterTerm)
    -- inputs
    -- tableName: table data with all the stuff in it
    -- slotList: list of the equipment slots by name
    -- isArmor: true if this is the armor tab, false if its the weapon tab
    -- displayType: future?
    local tableName = inventoryTable.InventoryDataTable
    local slotList = inventoryTable.slotName

    -- Use some logic to determine how to print stuff
    -- FUTURE: NEed to get a better method here. this is confusing
    --   we just want to treat armor and weapons tabs differently
    if M.isEmpty(filterTerm) or isArmor then
        slotList = inventoryTable.slotName
    else
        slotList = {filterTerm}
    end


    -- FUTURE: Need to understand how to set default column widths. im missing flags somewhere and dont know how it really works

    local TEXT_BASE_WIDTH, _ = imgui.CalcTextSize("A")

    -- if imgui.BeginTabItem('Test') then
        -- Define table flags (Borders and Alternating Row Backgrounds)
        --local flags = imgui.TableFlags_Borders -- + imgui.TableFlags_RowBg
        -- local flags = bit32.bor(ImGuiTableFlags.BordersV, ImGuiTableFlags.BordersOuterH, ImGuiTableFlags.Resizable)
        -- local tableFlags = bit32.bor(ImGuiTableFlags.ImGuiTableFlags_Resizable,ImGuiTableFlags.ImGuiTableFlags_BordersOuter, ImGuiTableFlags.ImGuiTableFlags_BordersV, ImGuiTableFlags.ImGuiTableFlags_SizingStretchProp, ImGuiTableFlags.ImGuiTableFlags_ScrollFreezeTopRow, ImGuiWindowFlags.AlwaysVerticalScrollbar)
        local tableFlags = bit32.bor(
			ImGuiTableFlags.Resizable,
			--ImGuiTableFlags.Sortable,
			--ImGuiTableFlags.RowBg,
			--ImGuiTableFlags.NoKeepColumnsVisible,
			-- ImGuiTableFlags.SizingFixedFit,
			-- ImGuiTableFlags.MultiSortable, -- MultiSort seems to not work at all.
			ImGuiTableFlags.NoBordersInBodyUntilResize,
			--ImGuiTableFlags.BordersOuter,
			ImGuiTableFlags.Reorderable,
			ImGuiTableFlags.ScrollY,
            ImGuiTableFlags.ScrollX,
			ImGuiTableFlags.Hideable
		)

        -- Define column flags
        local colFixedFlags = bit32.bor(ImGuiTableFlags.ImGuiTableColumnFlags_WidthFixed, ImGuiTableFlags.ImGuiTableColumnFlags_NoResize) -- Optional: prevent manual resizing of the fixed column
        local colStretchFlags = bit32.bor(ImGuiTableFlags.ImGuiTableColumnFlags_WidthStretch, ImGuiTableFlags.ImGuiTableColumnFlags_Resizable)

        local nCol = 7 --10
        local nSolvCol = 0

        local valNew = 0

        if inventoryTable.showSolventInTable then
            nSolvCol = 2
        else
            nSolvCol = 0
        end

        if isArmor then
            nCol = 5
        else
            nCol = 7 -- more columns for weapons due to type 6
            if inventoryTable.showSolventInTable then
                nSolvCol = nSolvCol + 1 -- FUTURE: Need to clean up this bad logic stuff
            end
        end

        nCol = nCol + nSolvCol

        -- Create a table with a unique ID and 3 columns
        if imgui.BeginTable("MyTableID", nCol,tableFlags, ImVec2(0.0, 480.0)) then -- ImVec2(... , Y Extent of table)
             -- Keep the top row/header visible while scrolling the body
            imgui.TableSetupScrollFreeze(0, 1)
            -- 1. Setup Column Headers
            -- for _, slot in ipairs(slotList) do
            --     imgui.TableSetupColumn("ID",imgui.ImGuiTableColumnFlags_NoResize,2.0)
            -- end
            -- imgui.TableSetupColumn("ID",imgui.ImGuiTableColumnFlags_NoResize,2.0)
            -- imgui.TableSetupColumn("Name")
            -- imgui.TableSetupColumn("isChecked")
            -- imgui.TableSetupColumn("Type9")
            -- imgui.TableSetupColumn("Type9Solv")
            -- imgui.TableSetupColumn("Type5")
            -- imgui.TableSetupColumn("Type5Solv")
            -- imgui.TableHeadersRow() -- Renders the actual header row

            
            --imgui.TableSetupColumn("isValid")-- = false, -- true|false, is item equiped or otherwise invalid      
            imgui.TableSetupColumn("9",ImGuiTableColumnFlags.WidthFixed, TEXT_BASE_WIDTH * 3.0) --,colFixedFlags,5.0) -- "isCheckedType9")-- = false, -- boolean 
            if not isArmor then
                imgui.TableSetupColumn("6",ImGuiTableColumnFlags.WidthFixed, TEXT_BASE_WIDTH * 3.0) --,colFixedFlags,5.0) -- isCheckedType5")-- = false,
            end
            imgui.TableSetupColumn("5",ImGuiTableColumnFlags.WidthFixed, TEXT_BASE_WIDTH * 3.0) --,colFixedFlags,15.0) -- isCheckedType5")-- = false,
            imgui.TableSetupColumn("itemName",ImGuiTableColumnFlags.WidthFixed, TEXT_BASE_WIDTH * 22.0) --colFixedFlags,40.0)-- = rowName,
                        
            imgui.TableSetupColumn("nameType9",ImGuiTableColumnFlags.WidthFixed, TEXT_BASE_WIDTH * 22.0)-- = "test9", -- string to hold name of type 9
            if not isArmor then
                imgui.TableSetupColumn("nameType6",ImGuiTableColumnFlags.WidthFixed, TEXT_BASE_WIDTH * 22.0)-- = "test9", -- string to hold name of type 9
            end
            imgui.TableSetupColumn("nameType5",ImGuiTableColumnFlags.WidthFixed, TEXT_BASE_WIDTH * 22.0)-- = "test5",

            if inventoryTable.showSolventInTable then
                imgui.TableSetupColumn("solventType9")-- = "",
                if not isArmor then
                    imgui.TableSetupColumn("solventType6")-- = "test9", -- string to hold name of type 9
                end
                imgui.TableSetupColumn("solventType5")-- = ""
            end
            
            imgui.TableHeadersRow() -- Renders the actual header row

            

            local iVal = 0
            for _, item in ipairs(slotList) do


                
            
            -- Push a unique ID for each checkbox to prevent ID collisions
            
            -- if the item has a type5 slot or a type 9 slot and it matches the tab type (armor tableName[item].isValid9 == trueor or weapon) then print the list table
            

            if (tableName[item].isValid5 == true or tableName[item].isValid9 == true or tableName[item].isValid6 == true) and tableName[item].isArmor == isArmor then
                imgui.TableNextRow()
                -- Conditionally populate the rows for only 'valid' equiepment - ie equipment with a type 5 and/or type 9
                imgui.TableNextColumn()
                iVal = iVal + 1 -- gen unitque ID, Future: Make this an id in the tableName[] table
                imgui.PushID(iVal) -- push unique id for the object to avoid conflict
                -- use this if/then to auto set the table data if the user toggles the check box
                if imgui.Checkbox("", tableName[item].isCheckedType9 ) then -- interactive checkbox with name = "" and val = true/false
                    tableName[item].isCheckedType9  = true -- manage data in table
                    -- print('DEBUG: ' .. 'box checked') -- this will print every frame
                else
                    tableName[item].isCheckedType9 = false
                end
                imgui.PopID() -- needed but not sure why, perhaps an imgui process standard, future: Make a better comment

                if not isArmor then
                    imgui.TableNextColumn()                
                    iVal = iVal + 1 -- update the id so the next checkbox also has a unique value - FUTURE: Use pre defined IDs in the table data
                    imgui.PushID(iVal) -- needed but not sure why, perhaps an imgui process standard, future: Make a better comment                
                    if imgui.Checkbox("", tableName[item].isCheckedType6 ) then -- interactive checkbox with name = "" and val = true/false
                        tableName[item].isCheckedType6  = true -- manage data in table
                    else
                        tableName[item].isCheckedType6 = false
                    end
                    imgui.PopID()
                end

                imgui.TableNextColumn()                
                iVal = iVal + 1 -- update the id so the next checkbox also has a unique value - FUTURE: Use pre defined IDs in the table data
                imgui.PushID(iVal) -- needed but not sure why, perhaps an imgui process standard, future: Make a better comment                
                if imgui.Checkbox("", tableName[item].isCheckedType5 ) then -- interactive checkbox with name = "" and val = true/false
                    tableName[item].isCheckedType5  = true -- manage data in table
                else
                    tableName[item].isCheckedType5 = false
                end
                imgui.PopID()

                -- add the other info for the 'valid' equipment
                imgui.TableNextColumn()
                imgui.TextUnformatted(tableName[item].itemName)

                imgui.TableNextColumn()
                imgui.TextUnformatted(tableName[item].nameType9)

                if not isArmor then
                    imgui.TableNextColumn()
                    imgui.TextUnformatted(tableName[item].nameType6)
                end

                imgui.TableNextColumn()
                imgui.TextUnformatted(tableName[item].nameType5)

                if inventoryTable.showSolventInTable then
                    imgui.TableNextColumn()
                    imgui.TextUnformatted(tableName[item].solventType9)

                    if not isArmor then
                        imgui.TableNextColumn()
                        imgui.TextUnformatted(tableName[item].solventType6)
                    end

                    imgui.TableNextColumn()
                    imgui.TextUnformatted(tableName[item].solventType5)
                end

                -- if tableName[item].isArmor == false then
                --     -- Do something special for weapons tab
                --     -- FUTURE: Make this a less confusing hack job
                --     imgui.TableNextRow()
                --     -- Conditionally populate the rows for only 'valid' equiepment - ie equipment with a type 5 and/or type 9
                --     imgui.TableNextColumn()
                --     imgui.TableNextColumn()
                --     imgui.TableNextColumn()
                --     imgui.TableNextColumn()
                --     imgui.TableNextColumn()
                --     iVal = iVal + 1 -- update the id so the next checkbox also has a unique value - FUTURE: Use pre defined IDs in the table data
                --     imgui.PushID(iVal)
                --     if item == 'ranged' then
                --         inventoryTable.type9Index_ranged = imgui.Combo('   ', inventoryTable.type9Index_ranged, inventoryTable.fixType.ranged9Suffix, #(inventoryTable.fixType.ranged9Suffix))
                --     elseif item == 'mainhand' then
                --         inventoryTable.type9Index_mainhand = imgui.Combo('   ', inventoryTable.type9Index_mainhand, inventoryTable.fixType.mainhand9Suffix, #(inventoryTable.fixType.mainhand9Suffix))
                --     elseif item == 'offhand' then
                --         inventoryTable.type9Index_offhand = imgui.Combo('   ', inventoryTable.type9Index_offhand, inventoryTable.fixType.offhand9Suffix, #(inventoryTable.fixType.offhand9Suffix))
                --     end
                --     imgui.PopID()
                --     -- imgui.TextUnformatted('add suggested combo box type 9 here')
                --     imgui.TableNextColumn()
                --     -- imgui.TextUnformatted('add suggested combo box type 6 here')
                --     iVal = iVal + 1 -- update the id so the next checkbox also has a unique value - FUTURE: Use pre defined IDs in the table data
                --     imgui.PushID(iVal)
                --     if item == 'ranged' then
                --         inventoryTable.type6Index_ranged = imgui.Combo('   ', inventoryTable.type6Index_ranged, inventoryTable.fixType.type6Suffix, #(inventoryTable.fixType.type6Suffix))
                --     elseif item == 'mainhand' then
                --         inventoryTable.type6Index_mainhand = imgui.Combo('   ', inventoryTable.type6Index_mainhand, inventoryTable.fixType.type6Suffix, #(inventoryTable.fixType.type6Suffix))
                --     elseif item == 'offhand' then
                --         inventoryTable.type6Index_offhand = imgui.Combo('   ', inventoryTable.type6Index_offhand, inventoryTable.fixType.type6Suffix, #(inventoryTable.fixType.type6Suffix))
                --     end
                --     imgui.PopID()
                --     imgui.TableNextColumn()
                --     -- imgui.TextUnformatted('add suggested combo box type 5 here')
                --     iVal = iVal + 1 -- update the id so the next checkbox also has a unique value - FUTURE: Use pre defined IDs in the table data
                --     imgui.PushID(iVal)
                --     if item == 'ranged' then
                --         inventoryTable.type5Index_ranged = imgui.Combo('   ', inventoryTable.type5Index_ranged, inventoryTable.fixType.type5Suffix, #(inventoryTable.fixType.type5Suffix))
                --     elseif item == 'mainhand' then
                --         inventoryTable.type5Index_mainhand = imgui.Combo('   ', inventoryTable.type5Index_mainhand, inventoryTable.fixType.type5Suffix, #(inventoryTable.fixType.type5Suffix))
                --     elseif item == 'offhand' then
                --         inventoryTable.type5Index_offhand = imgui.Combo('   ', inventoryTable.type5Index_offhand, inventoryTable.fixType.type5Suffix, #(inventoryTable.fixType.type5Suffix))
                --     end
                --     imgui.PopID()

                -- end



            end


            -- Column 2: Text label
            
        end

            imgui.EndTable()
        end
        -- imgui.EndTabItem()
    -- end
end



return M

-- Determine if anything is already in inventory

-- buy solvents if needed

-- remove old augs if needed

-- sell old augs if user desires

-- buy any needed augs

-- insert augs

-- update gear tables

--loadgeartable()

