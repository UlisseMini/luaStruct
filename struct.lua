local function typecheck (t, types)
    for key, wantType in pairs(types) do
      -- if its a table check it
      if type(t[key]) == "table" then
        typecheck(t[key], wantType)

      elseif type(t[key]) ~= wantType then
        if wantType == nil then
          error(string.format("key '%s' is not part of the struct", key))
        end

        error(string.format("key '%s' want type '%s' got type '%s'",
          key, wantType, type(t[key])))
      end
    end
end

-- allTypes returns every type in a 'key = key; value = type' table.
local function allTypes (t)
  local types = {}

  for key, val in pairs(t) do
    if type(val) == "table" then
      types[key] = allTypes(val)
    else
      types[key] = type(val)
    end
  end

  return types
end

-- struct creates a new struct data structure from a table,
-- it is type safe.
local function struct (t)
  if type(t) ~= "table" then
    error(string.format("bad argument #1 to 'struct' (table expected, got %s)", type(t)))
  end

  local types = allTypes(t)

  -- return a function that typechecks the table it gets.
  return function(t)
    typecheck(t, types)
    return t
  end
end

return struct
