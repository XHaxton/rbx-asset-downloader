local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local task = require("@lune/task")

local infoTmpl = "https://economy.roblox.com/v2/developer-products/"

local assetTypes = {
    [1] = {astType=1,"Image",".png"},
    [2] = {astType=2,"TeeShirt",".xml"},
    [3] = {astType=3,"Audio",".xml"},
    [4] = {astType=4,"Mesh",".mesh"},
    [5] = {astType=5,"Lua",""},
    [6] = {astType=8,"Hat",".xml"},
    [7] = {astType=9,"Place",".rbxl"},
    [8] = {astType=10,"Model",".rbxm"},
    [9] = {astType=11,"Shirt",".xml"},
    [10] = {astType=12,"Pants",".xml"},
    [11] = {astType=13,"Decal",".xml"},
    [12] = {astType=17,"Head",".xml"},
    [13] = {astType=18,"Face",".xml"},
    [14] = {astType=19,"Gear",".xml"},
    [15] = {astType=21,"Badge",""},
    [16] = {astType=24,"Animation",".xml"},
    [17] = {astType=27,"Torso",".xml"},
    [18] = {astType=28,"RightArm",".xml"},
    [19] = {astType=29,"LeftArm",".xml"},
    [20] = {astType=30,"LeftLeg",".xml"},
    [21] = {astType=31,"RightLeg",".xml"},
    [22] = {astType=32,"Package",".xml"},
    [23] = {astType=33,"YouTubeVideo",""},
    [24] = {astType=34,"GamePass",".xml"},
    [25] = {astType=38,"Plugin",".xml"},
    [26] = {astType=39,"SolidModel",".xml"},
    [27] = {astType=40,"MeshPart",".rbxm"},
    [28] = {astType=41,"HairAccessory",".xml"},
    [29] = {astType=42,"FaceAccessory",".xml"},
    [30] = {astType=43,"NeckAccessory",".xml"},
    [31] = {astType=44,"ShoulderAccessory",".xml"},
    [32] = {astType=45,"FrontAccessory",".xml"},
    [33] = {astType=46,"BackAccessory",".xml"},
    [34] = {astType=47,"WaistAccessory",".xml"},
    [35] = {astType=48,"ClimbAnimation",""},
    [36] = {astType=49,"DeathAnimation",""},
    [37] = {astType=50,"FallAnimation",""},
    [38] = {astType=51,"IdleAnimation",""},
    [39] = {astType=52,"JumpAnimation",""},
    [40] = {astType=53,"RunAnimation",""},
    [41] = {astType=54,"SwimAnimation",""},
    [42] = {astType=55,"WalkAnimation",""},
    [43] = {astType=56,"PoseAnimation",""},
    [44] = {astType=57,"EarAccessory",".xml"},
    [45] = {astType=58,"EyeAccessory",".xml"},
    [46] = {astType=61,"EmoteAnimation",""},
    [47] = {astType=62,"Video",""},
}

local assetList = {}

local function getAssetMeta(id)
    local response = net.request({
        url = infoTmpl..tostring(id).."/info",
        method = "GET",
        headers = {
            ["Content-Type"] = "application/json",
        },
        body = net.jsonEncode()
    })
    if response.ok then
        local product = net.jsonDecode(response.body)
        return product
    else
        return nil
    end
end

local function downloadAsset(id)
    local assetMeta = getAssetMeta(id)
    local assetType = assetMeta.AssetTypeId
    for _,v in ipairs(assetTypes) do
        if v.astType == assetType then
            print(v[1].."\n","format:",v[2])
        end
    end
end

local function idList2Tbl(file,tbl)
    local urlFile = fs.readFile(file)
    for d in string.gmatch(urlFile,"%d+") do
        if d ~= "1" then
            table.insert(tbl,d)
        end
    end
end

local function initialize()
    print("Roblox Asset Downloader (v1.0)")
    print("Programmed by SkylarZYX")
    print("")
    if #process.args > 1 then
        error("Too many arguments!")
    elseif #process.args > 0 then
        if string.find(process.args[1],".txt") then
            idList2Tbl(process.args[1],assetList)
            for _,v in ipairs(assetList) do
                downloadAsset(v)
            end
        end
    else
        print("If you have not figured out how to use this, enter in a list of roblox assetdelivery urls into a specific text file, or use the roblox plugin to gather the list of urls for you!")
        print("")
        print("Usage Example:")
        print("lune run astDL assetUrls.txt")
    end
end

initialize()