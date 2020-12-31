

-- addComma()
-- Adds a comma every 3 digits to format the cash value
-- @param
function addComma(str)
	return #str % 3 == 0 and str:reverse():gsub("(%d%d%d)","%1,"):reverse():sub(2) or str:reverse():gsub("(%d%d%d)", "%1,"):reverse()
end


function CopRankFormula(n)
  if not n then n = 1 end
  return (((n * (n + 1)) / 2) * 100)
end


function CivRankFormula(n)
  if not n then n = 1 end
  return (((n * (n + 1)) / 2) * 100)
end


function Round(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end


-- A functional ternary helper function for Lua
function ternary (cond, T, F)
  if cond then return T else return F end
end


-- Returns TRUE if 'a' contains 'b' (a&b)
function bitoper(a, b)
  local matched = b
  local r, m, s = 0, 2^52
  repeat
     s,a,b = a+b+m, a%m, b%m
     r,m = r + m*4%(s-a-b), m/2
  until m < 1
  return (math.floor(r) == matched)
end


-- Splits a string into table separated by 'sep' character
-- If 'sep' is nil, assumes comma
function splitstring(inputstr, sep)
  if (not sep) then sep = "," end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end


-- Removes special characters and spaces
function ValidatePlate(plate)
  return (string.gsub(plate, "[^A-Za-z0-9]",""))
end


-- Converts HTML date to MM/DD/YYYY
function FormatHTMLDate(dateString)
  local temp = splitstring(dateString, "-")
  if temp[1] then 
    return (temp[2].."/"..temp[3].."/"..temp[1])
  end
  return dateString
end

