
-- client vehicle config

local sporty = {
  
}

--- AlwaysLocked()
-- Checks if the model given should always be locked if unoccupied
function AlwaysLocked(model)
  if not model then return false end
  if not sporty[model] then return false end
  return sporty[model]
end