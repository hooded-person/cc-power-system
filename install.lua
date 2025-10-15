local data = {
    ["ccryptolib/internal"]={
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/internal/curve25519.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/internal/edwards25519.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/internal/fp.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/internal/fq.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/internal/mp.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/internal/packing.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/internal/sha512.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/internal/util.lua"
    },
    ccryptolib = {
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/aead.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/blake3.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/chacha20.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/ed25519.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/poly1305.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/random.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/sha256.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/util.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/x25519.lua",
        "https://github.com/migeyel/ccryptolib/blob/main/ccryptolib/x25519c.lua"
    },
    ecnet2 = {
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/CipherState.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/Connection.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/HandshakeState.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/Identity.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/Listener.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/Protocol.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/SymmetricState.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/addressEncoder.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/class.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/constants.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/ecnetd.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/init.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/modems.lua",
        "https://github.com/migeyel/ecnet/blob/main/ecnet2/uid.lua"
    }
}
function toRaw(url)
    local rawUrl = url:gsub("github.com", "raw.githubusercontent.com")
        :gsub("blob", "refs/heads")
    return rawUrl
end

local overwriteAll = false
function downloadFile(fileUrl, fileLocation)
    if fs.exists(fileLocation) and not overwriteAll then
        term.setTextColor(colors.orange)
        print("File already exists, overwrite (Y/n/a)")
        term.setTextColor(colors.white)
        local choice = read()
        if choice == "n" then
            print("Skipping file")
            return
        elseif choice == "a" then
            overwriteAll = true
            print("Overwriting all files")
        else
            print("Overwriting file")
        end
    end

    local res, reason, failRes = http.get(fileUrl)
    local data = nil
    if not res then
        term.setTextColor(colors.red)
        print(("Request failed: %s"):format(reason))
        if failRes then
            print(("HTTP %d: %s"):format(
                failRes.getResponseCode(),
                failRes.readAll()
            ))
            failRes.close()
        end
        term.setTextColor(colors.white)
    else
        data = res.readAll()
        res.close()
    end

    local h = fs.open(fileLocation, "w")
    h.write(data)
    h.close()
    return data
end

function padLeft(str, padding, length)
    str = tostring(str)
    if #str > length then
        return str
    else
        return padding:rep(length-#str)..str
    end
end

for dir, files in pairs(data) do
    fs.makeDir(dir)
    local fileCount = #files
    for i, fileUrl in ipairs(files) do
        fileUrl = toRaw(fileUrl) -- ensure (ish) we using the raw urls
        local fileName = fileUrl:sub(fileUrl:find("[^/]+$"))
        local fileLocation = fs.combine(dir, fileName)
        print(("%d/%d Installing '%s'"):format(
            padLeft(i, "0", #tostring(fileCount)),
            fileCount,
            fileLocation
        ))
        downloadFile(fileUrl, fileLocation)
    end
end
