# struct
> ever want type safe data structures in pure lua? you've came to the right place!

## Example
```lua
local struct = require "struct"

person = struct {
  name = "",
  age  = 0,
}

-- this works
uli = person {
  name = "uli",
  age = 14,
}

-- this does not
invalid1 = person {
  not_existing_key = "something",
  name = "invalid",
  age = 0,
}

-- this also fails
invalid2 = person {}

-- annd this fails
invalid3 = person {
	name = 21,
	age = "name",
}
```
also works with nested tables and functions (only make sure it is a function, not the parmaters)
