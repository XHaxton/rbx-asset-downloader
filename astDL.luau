-- Originally Scripted by SkylarZYX / XYZ Studio
-- Last Updated: 2024/07/21

-- Get lune libraries
local datetime = require("@lune/datetime")::any
local fs = require("@lune/fs")::any
local net = require("@lune/net")::any
local process = require("@lune/process")::any
local task = require("@lune/task")::any

-- Version
local dlVer = "1.0a"

-- Log file
local logs = "astDL.log"
-- Clear previous logs on start
local clrdLogs = false

-- Roblox open cloud API key
local apiKey
-- Asset Downloads Directory Variable (Optional)
local spDir = nil
-- Asset Version Specification (Optional)
local spVer = nil

-- Roblox API url templates
local assetUrlTmpl = "https://assetdelivery.roblox.com/v1/asset/?id="
local cloudTmpl = "https://apis.roblox.com/assets/v1/assets/"

-- Table for types of Roblox assets (may be out of date)
local assetTypes = {
    [1] = {astTypeId=1,astType="Image",astFormat=".png"},
    [2] = {astTypeId=2,astType="TeeShirt",astFormat=".xml"},
    [3] = {astTypeId=3,astType="Audio",astFormat=".xml"},
    [4] = {astTypeId=4,astType="Mesh",astFormat=".mesh"},
    [5] = {astTypeId=5,astType="Lua",astFormat=""},
    [6] = {astTypeId=8,astType="Hat",astFormat=".xml"},
    [7] = {astTypeId=9,astType="Place",astFormat=".rbxl"},
    [8] = {astTypeId=10,astType="Model",astFormat=".rbxm"},
    [9] = {astTypeId=11,astType="Shirt",astFormat=".xml"},
    [10] = {astTypeId=12,astType="Pants",astFormat=".xml"},
    [11] = {astTypeId=13,astType="Decal",astFormat=".xml"},
    [12] = {astTypeId=17,astType="Head",astFormat=".xml"},
    [13] = {astTypeId=18,astType="Face",astFormat=".xml"},
    [14] = {astTypeId=19,astType="Gear",astFormat=".xml"},
    [15] = {astTypeId=21,astType="Badge",astFormat=""},
    [16] = {astTypeId=24,astType="Animation",astFormat=".xml"},
    [17] = {astTypeId=27,astType="Torso",astFormat=".xml"},
    [18] = {astTypeId=28,astType="RightArm",astFormat=".xml"},
    [19] = {astTypeId=29,astType="LeftArm",astFormat=".xml"},
    [20] = {astTypeId=30,astType="LeftLeg",astFormat=".xml"},
    [21] = {astTypeId=31,astType="RightLeg",astFormat=".xml"},
    [22] = {astTypeId=32,astType="Package",astFormat=".xml"},
    [23] = {astTypeId=33,astType="YouTubeVideo",astFormat=""},
    [24] = {astTypeId=34,astType="GamePass",astFormat=".xml"},
    [25] = {astTypeId=38,astType="Plugin",astFormat=".xml"},
    [26] = {astTypeId=39,astType="SolidModel",astFormat=".xml"},
    [27] = {astTypeId=40,astType="MeshPart",astFormat=".rbxm"},
    [28] = {astTypeId=41,astType="HairAccessory",astFormat=".xml"},
    [29] = {astTypeId=42,astType="FaceAccessory",astFormat=".xml"},
    [30] = {astTypeId=43,astType="NeckAccessory",astFormat=".xml"},
    [31] = {astTypeId=44,astType="ShoulderAccessory",astFormat=".xml"},
    [32] = {astTypeId=45,astType="FrontAccessory",astFormat=".xml"},
    [33] = {astTypeId=46,astType="BackAccessory",astFormat=".xml"},
    [34] = {astTypeId=47,astType="WaistAccessory",astFormat=".xml"},
    [35] = {astTypeId=48,astType="ClimbAnimation",astFormat=""},
    [36] = {astTypeId=49,astType="DeathAnimation",astFormat=""},
    [37] = {astTypeId=50,astType="FallAnimation",astFormat=""},
    [38] = {astTypeId=51,astType="IdleAnimation",astFormat=""},
    [39] = {astTypeId=52,astType="JumpAnimation",astFormat=""},
    [40] = {astTypeId=53,astType="RunAnimation",astFormat=""},
    [41] = {astTypeId=54,astType="SwimAnimation",astFormat=""},
    [42] = {astTypeId=55,astType="WalkAnimation",astFormat=""},
    [43] = {astTypeId=56,astType="PoseAnimation",astFormat=""},
    [44] = {astTypeId=57,astType="EarAccessory",astFormat=".xml"},
    [45] = {astTypeId=58,astType="EyeAccessory",astFormat=".xml"},
    [46] = {astTypeId=61,astType="EmoteAnimation",astFormat=""},
    [47] = {astTypeId=62,astType="Video",astFormat=""},
    [48] = {astTypeId=0,astType="Unknown",astFormat=""},
}

-- Table of asset ids to download
local assetList = {}

-- Downloaded asset metadata
local OCAPIMeta

-- API Ratelimit Cooldown
local metaCD = 5

-- UTIL Functions

-- Write printed outputs to the log file /w date and time
local function writeLog(file,out)
    local now = datetime.now()
    local prev = fs.readFile("logs/"..file)
    fs.writeFile("logs/"..file,prev.."["..now:toIsoDate().."] "..out.."\n")
end

-- Check if any log directories or files are present. If not, write necessary directories and files, then start writing to the log file
local function log(file,out)
    if fs.isDir("logs") then
    else
        fs.writeDir("logs")
    end

    if fs.isFile("logs/"..file) then
        if clrdLogs == false then -- Clear logs each session
            fs.writeFile("logs/"..file,"")
            clrdLogs = true
        end
    else
        clrdLogs = true
        fs.writeFile("logs/"..file,"")
    end
    writeLog(file,out)
end

-- Make sure there is a downloads directory
local function makeDlDir()
    if fs.isDir("downloads") then
    else
        fs.writeDir("downloads")
    end
end

-- Make a directory within "downloads"
local function makeDir(parentDir,newDir)
    if fs.isDir(parentDir.."/"..newDir) then
        return false
    else
        fs.writeDir(parentDir.."/"..newDir)
        return true
    end
end

-- MAIN Functions

-- Download an asset by its id and version id using assetdelivery v1 API
local function getAsset(id,ver)
    local response = net.request(assetUrlTmpl..id.."&version="..ver)
    print("Downloading asset:",id.."...")

    local assetData
    if response.ok then
        assetData = response.body
        log(logs,"DOWNLOAD SUCCESS")
        print("Successfully downloaded asset:",id.."!")
        print("")
        return assetData
    else
        warn("Status code:",response.statusCode)
        log(logs,"DOWNLOAD FAILED with status code: "..tostring(response.statusCode))
        error("Could not get downloaded asset data!")
        return nil
    end
end

-- Get metadata of an asset with Roblox open cloud API (contains the version number of an asset, along with other information)
local function getAssetOCAPI(id,key)
    local response = net.request({
        url = cloudTmpl..tostring(id),
        method = "GET",
        headers = {
            ["Content-Type"] = "application/json",
            ["x-api-key"] = key
        },
        body = net.jsonEncode()
    })
    -- print(response.headers)
    local remainingRateLimit = tonumber(response.headers["x-ratelimit-remaining"])
    if response.ok then
        local product = net.jsonDecode(response.body)
        -- print(product)
        if remainingRateLimit < 20 then
            task.wait(1.5)
        elseif remainingRateLimit > 20 then
            task.wait(0.75)
        end
        return product
    else
        warn("Status code:",response.statusCode)
        if response.statusCode == 429 then
            print("Your requests to the Open Cloud API are being ratelimited! Retrying in",metaCD,"seconds...")
            task.wait(metaCD)
            return 429
        else
            log(logs,"ASSET METADATA DOWNLOAD FAILED with status code: "..tostring(response.statusCode))
            error("Could not get Open Cloud API data! Did you enter in the correct file with an API key?")
            return nil
        end
    end
end

-- Save a downloaded asset to in a filesystem directory
local function saveAsset(assetData,dir,ext,id,ver)
    local fileName

    if spVer ~= nil then
        fileName = id.."_"..ver..ext
    else
        fileName = id..ext
    end

    local _saveFile

    makeDlDir()
    if spDir ~= nil then
        makeDir("downloads",dir)
        _saveFile = fs.writeFile("downloads/"..dir.."/"..fileName,assetData)
    else
        makeDir("downloads/misc",dir)
        _saveFile = fs.writeFile("downloads/misc/"..dir.."/"..fileName,assetData)
    end
end

-- Start downloading asset information and asset data
local function downloadAsset(id)
    repeat OCAPIMeta = getAssetOCAPI(id,apiKey) until OCAPIMeta ~= 429

    local assetVer

    if spVer ~= nil then
        assetVer = spVer
    else
        assetVer = OCAPIMeta.revisionId
    end

    local assetType = OCAPIMeta.assetType
    local _assetExtension
    
    local assetCreatorId = OCAPIMeta.creationContext.creator.userId
    local displayName = OCAPIMeta.displayName
    local description = OCAPIMeta.description
    local verCreate = OCAPIMeta.revisionCreateTime

    for _,v in ipairs(assetTypes) do
        if v.astType == assetType then
            _assetExtension = v.astFormat
        end
    end
    if _assetExtension == nil then
        _assetExtension = assetTypes[48].astFormat
    end

    log(logs,"-- Asset Info --")
    print("assetId: "..id)
    log(logs,"assetId: "..id)
    print("assetType: "..assetType)
    log(logs,"assetType: "..assetType)
    print("assetExtension: ".._assetExtension)
    log(logs,"assetExtension: ".._assetExtension)
    print("creatorId: "..assetCreatorId)
    log(logs,"creatorId: "..assetCreatorId)
    print("displayName: "..displayName)
    log(logs,"displayName: "..displayName)
    log(logs,"description: "..description)
    if spVer ~= nil then
        print("specifiedAssetVer: "..assetVer)
        log(logs,"specifiedAssetVer: "..assetVer)
    else
        print("assetVer: "..assetVer)
        log(logs,"assetVer: "..assetVer)
    end
    log(logs,"verCreateTime: "..verCreate)
    print("")

    local assetData = getAsset(id,assetVer)

    if spDir ~= nil then
        saveAsset(assetData,spDir,_assetExtension,id,assetVer)
    else
        saveAsset(assetData,assetType,_assetExtension,id,assetVer)
    end
end

-- Get individual asset IDs from a txt file with roblox assetdelivery URLs
local function idList2Tbl(file,tbl)
    local urlFile = fs.readFile(file)
    if urlFile ~= "" then
        for d in string.gmatch(urlFile,"%d+") do
            if d ~= "1" then
                table.insert(tbl,d)
            end
        end
    else
        error(".txt file is empty!")
    end
end

-- Main program controller, handles arguments and primary functions
local function initialize()
    print("Roblox Asset Downloader (v"..dlVer..")")
    print("Scripted by SkylarZYX")
    print("")
    if #process.args > 6 then
        error("Too many arguments!")
    elseif #process.args > 0 then -- Argument parsing... fun
        apiKey = fs.readFile(process.args[1])
        if process.args[2] ~= nil then
            if string.find(process.args[2],".txt") then
                idList2Tbl(process.args[2],assetList)
                if process.args[3] ~= nil then
                    if string.find(process.args[3],"--outDir") and spDir == nil then
                        spDir = process.args[4]
                    elseif string.find(process.args[3],"--spVer") and spVer == nil then
                        spVer = process.args[4]
                    end
                    if process.args[5] ~= nil then
                        if string.find(process.args[5],"--outDir") and spDir == nil then
                            spDir = process.args[6]
                        elseif string.find(process.args[5],"--spVer") and spVer == nil then
                            spVer = process.args[6]
                        end
                    end
                end
                for _,v in ipairs(assetList) do
                    downloadAsset(v)
                end
            else
                error("2nd argument must be a .txt file!")
            end
        else
            error("2nd argument is empty!")
        end
    else
        print("If you have not figured out how to use this, enter in a list of roblox assetdelivery urls into a specific text file, or use the roblox plugin to gather the list of urls for you!")
        print("")
        print("Command Syntax/Usage:")
        print([[lune run astDL -- key.txt astUrls.txt [optional args: --outDir specificDirectory --spVer (number)]].."]")
    end
end

initialize()