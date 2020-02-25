-- Serialize any table to a string format
function table_to_string(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..tostring(v).."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "" and result ~= "{" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

-- Serialize table keys to array format
function table_key_to_string(tbl)
    local entries = ""
    for v,_ in pairs(tbl) do
        entries = entries .. ", " .. v
    end
    if entries ~= "" then
        entries = entries:sub(3, entries:len())
        return "[ " .. entries .. " ]"
    else
        return "[]"
    end
end

-- wrapper to try catch access something in a table - return nil if there's an error
function try_catch_table(table, ref)
	if table then
		if ref then
			local value, err = pcall(function() return table[ref] end)
			if value then
				return table[ref], "Success"
			else
				return nil, err
			end
		else
			return nil, "Missing Ref"
		end
	else
		return nil, "Missing Table"
	end
end

-- wrapper to see if table is empty
function table_empty(table)
    for k,v in pairs(table) do
        return false
    end
    return true
end