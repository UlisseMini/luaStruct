-- typecheck returns nothing, works because tables operate via pointers.
-- typecheck DOES NOT need to deal with defaults
local function typecheck (t, types)
    if t == nil then
      error(string.format("bad argument #1 to 'typecheck' (table expected, got %s)",
        type(t)))
    end

    for key, wantType in pairs(types) do
      -- if we want a table check it
      if type(wantType) == "table" then
        typecheck(t[key], wantType)

      elseif type(t[key]) ~= wantType then
        error(string.format("key '%s' want type '%s' got type '%s'",
          key, wantType, type(t[key])))
      end
    end

    -- check for unwanted fields being filled,
    -- ignore functions because methods okay.
    for key, val in pairs(t) do
        if types[key] == nil and type(val) ~= "function" then
          error(string.format("key '%s' is not part of the struct", key))
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

-- Save copied tables in `copies`, indexed by original table.
-- TODO implement setDefaults
function setDefaults(orig, copies)
  copies = copies or {}
  local orig_type = type(orig)
  local copy

  if orig_type == 'table' then
    if copies[orig] then
      copy = copies[orig]
    else
      copy = {}
      for orig_key, orig_value in next, orig, nil do
        copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
      end
      copies[orig] = copy
      setmetatable(copy, deepcopy(getmetatable(orig), copies))
    end
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

-- struct creates a new struct data structure from a table,
-- it is type safe.
local function struct (t)
  if type(t) ~= "table" then
    error(string.format("bad argument #1 to 'struct' (table expected, got %s)", type(t)))
  end

  local types = allTypes(t)

  -- return a metatable that typechecks the values it gets, but
  -- sets defaults when they are nil.
  local mt = {}
  -- calling the table returns the table with defaults (after typechecking it)
  mt.__call = function (self, o)
    -- TODO: Find a better way then looping, maybe __index
    setDefaults(o, self)

    -- typecheck the values (ignores extra functions)
    typecheck(o, types)

    -- return the new instance
    return o
  end

  return setmetatable(t, mt)
end

return struct
