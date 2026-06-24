--- Returns all available versions of chromedriver from Google's API
--- @param ctx table Context provided by vfox
--- @return table Available versions
function PLUGIN:Available(ctx)
    local http = require("http")
    local json = require("json")

    local result = {}

    local resp, err = http.get({
        url = "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json",
        headers = {
            ["Accept"] = "application/json",
        },
    })

    if err ~= nil then
        error("Failed to fetch versions: " .. err)
    end

    if resp.status_code ~= 200 then
        error("Failed to fetch versions, status: " .. resp.status_code)
    end

    local data = json.decode(resp.body)
    if data == nil or data.versions == nil then
        return result
    end

    -- Collect versions that have chromedriver downloads
    for _, v in ipairs(data.versions) do
        if v.downloads and v.downloads.chromedriver then
            table.insert(result, {
                version = v.version,
            })
        end
    end

    table.sort(result, function(a, b)
        return compare_versions(b.version, a.version)
    end)

    return result
end

--- Compare two version strings semantically
--- Returns true if v1 < v2 (for ascending sort)
function compare_versions(v1, v2)
    local parts1 = split_version(v1)
    local parts2 = split_version(v2)

    local max_len = math.max(#parts1, #parts2)
    for i = 1, max_len do
        local p1 = parts1[i] or 0
        local p2 = parts2[i] or 0
        if p1 ~= p2 then
            return p1 < p2
        end
    end
    return false
end

--- Split a version string into numeric parts
function split_version(version)
    local parts = {}
    for part in string.gmatch(version, "([0-9]+)") do
        table.insert(parts, tonumber(part))
    end
    return parts
end
