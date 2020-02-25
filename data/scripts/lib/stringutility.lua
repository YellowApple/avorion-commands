-- levenshtein fuzzy string matching
function levenshtein(s, t)
	local s, t = tostring(s), tostring(t)
	if type(s) == 'string' and type(t) == 'string' then
		local m, n, d = #s, #t, {}
		for i = 0, m do d[i] = { [0] = i } end
		for j = 1, n do d[0][j] = j end
		for i = 1, m do
			for j = 1, n do
				local cost = s:sub(i,i) == t:sub(j,j) and 0 or 1
				d[i][j] = math.min(d[i-1][j]+1, d[i][j-1]+1, d[i-1][j-1]+cost)
			end
		end
		return d[m][n]
	end
end
