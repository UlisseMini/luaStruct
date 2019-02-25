# struct
> ever want type safe data structures in pure lua? you've came to the right place!

## Installation
Install luarocks then run
`luarocks install luastruct`
then you can use it in your programs via
```lua
local struct = require "struct"
```

## Example
```lua
local struct = require "struct"

-- create a new struct
person = struct {
  name = "default name",
  age  = 21
}

-- add a method (function) to the struct person, this will be added to every new
-- person and can be called with "name:hello()" where "name" is the new person.
function person:hello()
  print(self.name.." says hello")
end

-- create a new person "uli"
local uli = person {
  name = "uli",
  age  = 14
}

-- create a new person "james"
local james = person {
  name = "james",
  age  = 13
}

uli:hello()   --> uli says hello
james:hello() --> james says hello

-- also works with defaults
local default = person {}

default:hello()     --> default name says hello
print(default.age)  --> 21
print(default.name) --> "default name"

-- however, if we supply a wrong type an error will be raised,
local invalid = person {
	name = 10,
	age = "invalid",
}
```

all of this works with nested tables as well :)
