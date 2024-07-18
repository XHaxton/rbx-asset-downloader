local net = require("@lune/net")

local astTmpl = "https://economy.roblox.com/v2/developer-products/"

local function getMeta(id,specific)
    local response = net.request({
        url = astTmpl..tostring(id).."/info",
        method = "GET",
        headers = {
            ["Content-Type"] = "application/json",
        },
        body = net.jsonEncode()
    })
    if response.ok then
        local product = net.jsonDecode(response.body)
        return product[specific]
    else
        return nil
    end
end

local astId = getMeta(9015582070,"AssetTypeId")
print(astId)