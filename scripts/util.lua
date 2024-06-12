local util = {}

function util.signalToRichTextImg(signal)
    local richText = "[img="

    if signal.type == "item" then
        richText  = richText .. "item/"
    elseif signal.type == "fluid" then
        richText  = richText .. "fluid/"
    elseif signal.type == "virtual" then
        richText  = richText .. "virtual-signal/"
    end

    return richText .. signal.name .. "]"
end

return util