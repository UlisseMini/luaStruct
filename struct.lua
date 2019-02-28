-- typecheck returns nothing, works because tables operate via pointers.
-- typecheck DOES NOT need to deal with defaults
local function typecheck (t, types)
    assert(type(t) == "table",
      string.format("bad argument #1 to 'typecheck' (table expected, got %s)", type(t))
    )

    for key, wantType in pairs(types) do
      -- if the expected type is a table call ourselves on it.
      if type(wantType) == "table" then
        typecheck(t[key], wantType)
      else
        -- make sure it is the type we expect
        assert(type(t[key]) == wantType,
          string.format("key '%s' want type '%s' got type '%s'", key, wantType, type(t[key]))
        )
      end
    end

    -- check for unwanted fields being filled,
    -- ignore functions because methods are okay.
    for key, val in pairs(t) do
        -- if it is not a function then go boom
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

-- returns an updated table
function setDefaults (t, defaults)
  -- if t is nil then set it to an empty table.
  t = t or {}

  -- iterate over the defaults and set them if they are not supplied
  for key, default in pairs(defaults) do
    -- if the default is a table then run it on the subtable in t.
    if type(default) == "table" then
      t[key] = setDefaults(t[key], default)
    else
      -- otherwise just set it to the default if t[key] is nil
      if t[key] == nil then
        t[key] = default
      end
    end
  end

  return t
end

-- struct creates a new struct data structure from a table,
-- it is type safe.
local function struct (t)
  assert(type(t) == "table",
    string.format("bad argument #1 to 'struct' (table expected, got %s)", type(t))
  )

  local types = allTypes(t)

  -- return a metatable that typechecks the values it gets, but
  -- sets defaults when they are nil.
  local mt = {}
  -- calling the table returns the table with defaults (after typechecking it)
  mt.__call = function (self, o)
    -- Using setDefaults because when i use __index it does not set
    -- defaults correctly if o is {}, only when o is nil.
    -- (maybe applying __index recursively?)
    o = setDefaults(o, self)

    -- typecheck the values (ignores extra functions)
    typecheck(o, types)

    -- return the new instance
    return o
  end

  return setmetatable(t, mt)
end

return struct
