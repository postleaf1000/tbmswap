-- Module object for holding data tables
local M = {}

-- print('This got done here')

M.debugPrintFlag = false
M.logLevel = 1 -- 1 = info only, 2 = + status, 3 = debug, 4 = detailed -- FUTURE: Need to figure out how to manage global log level vs log level input arg of print statement
M.doMockAction = false -- used to mock the buying, selling, remove/replace scripting for debug purposes
M.printOnceFlag = true
M.showSolventInTable = false -- flag to include solvent in gear table or not

-- add tabld data properties that can be accessed and set by other functions
M.augPrefixIndex = 1 -- set default here
M.augSuffixIndex = 1 -- set global default here
M.type5Index_armor = 1
M.type6Index_armor = 1 -- unused
M.type9Index_armor= 1
M.wepType9Index = 1 -- deprecated
M.type9Index_ranged = 1
M.type9Index_mainhand = 1
M.type9Index_offhand = 1
M.type6Index_ranged = 1
M.type6Index_mainhand = 1
M.type6Index_offhand = 1
M.type5Index_ranged = 1
M.type5Index_mainhand = 1
M.type5Index_offhand = 1
M.myClassGroup = 'Tank' -- Default value. WAR, PAL, and SHD
M.myLevel = 1
M.myClass = 'SHD'
M.usePlate = false
M.useRune = false
M.currentAugName = "" -- string name of augment needed
M.currentAugType = 0 -- integer
M.currentSolvNumNeeded = 0 -- integer
M.currentSolventNameList = {}
M.currentAugmentNumNeeded = 0-- integer
M.currentTab = ''
M.sellAugList = {} -- list of augments to sell if we get that far and its desired
M.type5Vendor = 'Montelio'
M.type6Vendor = 'Shirlell'
M.type9Vendor = M.type5Vendor
M.solventVendor = 'Dabowe'

-- user selection options
M.userSelectedSellOldAugFlag = false

-- Main listerner flags to initiate routines from button callbacks
M.doBuySolventFlag = false
M.doBuyAugFlag = false
M.doRemoveOldAugFlag = false
M.doInstallNewAugFlag = false
M.doSellOldAugFlag = false



-- Lists of tables useful for the app
local classType = {}
classType.priestClass = {'DRU', 'SHM', 'CLR'}
classType.casterClass = {'ENC', 'MAG', 'NEC', 'WIZ'}
classType.meleeClass = {'BER', 'MNK', 'ROG'}
classType.hybridClass = {'BRD', 'RNG', 'BST'}
classType.knightClass = {'PAL', 'SHD'}
classType.plateClass = {'PAL', 'SHD', 'WAR', 'BRD'}
classType.classType = {}

local fixType = {}
fixType.augPrefix = {
    '75: Elegant',
    '80: Stalwart',
    '85: Extravagant',
    '90: Glorious',
    '95: Regal',
    '100: August',
    '105: Resplendent'
}
fixType.type5Suffix = {
    'Stability: All', --1
    'Courage: STR',
    'Resilience: STA',
    'Deftness: DEX', --4
    'Swiftness: AGI',
    'Scholarship: INT',
    'Foresight: WIS',
    'Allure: CHA' --8
}
fixType.type5Suffix_armor = fixType.type5Suffix
fixType.type5Suffix_ranged = fixType.type5Suffix
fixType.type5Suffix_mainhand = fixType.type5Suffix
fixType.type5Suffix_offhand = fixType.type5Suffix

fixType.type9Suffix = {
    'Fulcrum: All', --1
    'Sturdy: +AC - Less HP/Mana',
    'Valiant: +HP - Less Mana', --3
    'Resourceful: +Mana - Less HP',
    'Beneficent: +Heal',
    'Vengeful: +Spell DMG - +Attack', --6
}
fixType.type6Suffix = {
    'Brawler: 2H', --1
    'Compassionate: 1HB - Priest',
    'Dagger: Piercing',
    'Elements: 1H - Brd/Pal/Shd/War', --5
    'Fighter: 1HS',
    'Fist: H2H',
    'Focused: 1HB - Caster',
    'Knight: 1H - Pal/SK',
    'Tactician: 1HB', --10
    'Thoughtful: Piercing - Caster',
    'Wizened: 2H - Priest', --12
    'Bowyer: Bow - Pal/Rng/Rog/Shd' -- 13
}
fixType.type6Suffix_armor = fixType.type6Suffix -- not neccessary
fixType.type6Suffix_ranged = fixType.type6Suffix
fixType.type6Suffix_mainhand = fixType.type6Suffix
fixType.type6Suffix_offhand = fixType.type6Suffix

fixType.wep9Suffix = {
    'Brute: 2H',
    'Gallant: 1H',
    'Defender: Shields',
    'Hunter: Bow - Pal/Rng/Rog/Shd/War'
}
fixType.ranged9Suffix = {
    'Hunter: Bow - Pal/Rng/Rog/Shd/War',
    'Fulcrum: All', --1
    'Sturdy: +AC - Less HP/Mana',
    'Valiant: +HP - Less Mana', --3
    'Resourceful: +Mana - Less HP',
    'Beneficent: +Heal',
    'Vengeful: +Spell DMG - +Attack'
}
fixType.mainhand9Suffix = {
    'Brute: 2H',
    'Gallant: 1H',
    'Fulcrum: All', --1
    'Sturdy: +AC - Less HP/Mana',
    'Valiant: +HP - Less Mana', --3
    'Resourceful: +Mana - Less HP',
    'Beneficent: +Heal',
    'Vengeful: +Spell DMG - +Attack'
}
fixType.offhand9Suffix = {
    'Gallant: 1H',
    'Defender: Shields',
    'Fulcrum: All', --1
    'Sturdy: +AC - Less HP/Mana',
    'Valiant: +HP - Less Mana', --3
    'Resourceful: +Mana - Less HP',
    'Beneficent: +Heal',
    'Vengeful: +Spell DMG - +Attack'    
}

-- Rename variables to common structure because we use dynamic creation from generics in modules.lua
-- FUTURE: Clean this mess up
fixType.type9Suffix_armor = fixType.type9Suffix -- clean up these next few things to eliminate the confusing renaming
fixType.type9Suffix_ranged = fixType.ranged9Suffix
fixType.type9Suffix_mainhand = fixType.mainhand9Suffix
fixType.type9Suffix_offhand = fixType.offhand9Suffix

-- need shorter versions -- FUTURE: Make a better combo table or have calling function string parse to the ':'
-- note2: 2 D table arrays would be better for this stuff
fixType.augPrefixA = {
    'Elegant',
    'Stalwart',
    'Extravagant',
    'Glorious',
    'Regal',
    'August',
    'Resplendent'
}
fixType.type5SuffixA = {
    'Stability', --1
    'Courage',
    'Resilience',
    'Deftness', --4
    'Swiftness',
    'Scholarship',
    'Foresight',
    'Allure' --8
}
fixType.type9SuffixA = {
    'the Fulcrum', --1
    'the Sturdy',
    'the Valiant', --3
    'the Resourceful',
    'the Beneficent',
    'the Vengeful', --6
}
fixType.type6SuffixA = {
    'the Brawler', --1
    'the Compassionate',
    'the Dagger',
    'the Elements', --5
    'the Fighter',
    'the Fist',
    'the Focused',
    'the Knight',
    'the Tactician', --10
    'the Thoughtful',
    'the Wizened', --12
    'the Bowyer' -- 13
}
fixType.wep9SuffixA = {
    'the Brute',
    'the Gallant',
    'the Defender',
    'the Hunter'
}
fixType.ranged9SuffixA = {
    'the Hunter',
    'the Fulcrum', --1
    'the Sturdy',
    'the Valiant', --3
    'the Resourceful',
    'the Beneficent',
    'the Vengeful'
}
fixType.mainhand9SuffixA = {
    'the Brute',
    'the Gallant',
    'the Fulcrum', --1
    'the Sturdy',
    'the Valiant', --3
    'the Resourceful',
    'the Beneficent',
    'the Vengeful'
}
fixType.offhand9SuffixA = {
    'the Gallant',
    'the Defender',
    'the Fulcrum', --1
    'the Sturdy',
    'the Valiant', --3
    'the Resourceful',
    'the Beneficent',
    'the Vengeful'    
}
-- generics
fixType.type5SuffixA_armor = fixType.type5SuffixA -- not neccessary
fixType.type5SuffixA_ranged = fixType.type5SuffixA
fixType.type5SuffixA_mainhand = fixType.type5SuffixA
fixType.type5SuffixA_offhand = fixType.type5SuffixA
fixType.type6SuffixA_armor = fixType.type6SuffixA -- not neccessary
fixType.type6SuffixA_ranged = fixType.type6SuffixA
fixType.type6SuffixA_mainhand = fixType.type6SuffixA
fixType.type6SuffixA_offhand = fixType.type6SuffixA
fixType.type9SuffixA_armor = fixType.type9SuffixA -- clean up these next few things to eliminate the confusing renaming
fixType.type9SuffixA_ranged = fixType.ranged9SuffixA
fixType.type9SuffixA_mainhand = fixType.mainhand9SuffixA
fixType.type9SuffixA_offhand = fixType.offhand9SuffixA

-- fixType.wep9Suffix




local slotName = {
    'head', -- 1
    'arms',
    'leftwrist',
    'rightwrist',
    'hands',  -- 5
    'chest',
    'legs',
    'feet',  -- 8
    'leftear', -- 1
    'rightear',
    'face',
    'neck',
    'shoulder',  -- 5
    'back',
    'leftfinger',
    'rightfinger',
    'waist',
    'charm',  -- 10    
    'mainhand',
    'offhand',
    'ranged'
}
M.isArmorFlag = {
    true, -- FUTURE: Can just get this from the item Type and set automatically (armor, jewelry, archery, 2h peircing, etc)
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    false,
    false
}
M.isVisFlag = {
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    true,
    true,
    true
}

local InventoryDataTable = {}
-- load table defaults
for iVal, rowName in ipairs(slotName) do
    --DataTableVis[rowName] = false
    InventoryDataTable[rowName] = {
        isValid5 = false, -- true|false, is item equiped or otherwise invalid      
        isValid9 = false,
        isValid6 = false,
        isCheckedType9 = false, -- boolean 
        isCheckedType5 = false,
        isCheckedType6 = false,
        type5SlotIndex = -1,
        type9SLotIndex = -1,
        type6SlotIndex = -1;
        itemName = rowName,
        itemType = "",
        itemID = 0,
        nameType9 = "None", -- string to hold name of type 9
        nameType5 = "None",
        nameType6 = "none",
        solventType9 = "",
        solventType5 = "",
        solventType6 = "",
        isArmor = M.isArmorFlag[iVal],--false,
        isVis = M.isVisFlag[iVal], --false
        flagForRemovalType9 = false, -- 
        flagForRemovalType5 = false,
        flagForRemovalType6 = false,
        flagForInsertType9 = false, -- 
        flagForInsertType5 = false,
        flagForInsertType6 = false,
        desiredNameType9 = "",
        desiredNameType5 = "",
        desiredNameType6 = ""
    }
    -- print('Debug: isArmor =',InventoryDataTable[rowName].isArmor)
end
-- print('init config table stuff complete')

-- Set returns
--   Note: Could just make the variables above us the "M." prefix
M.InventoryDataTable = InventoryDataTable
M.slotName = slotName
M.classType = classType
M.fixType = fixType

return M


