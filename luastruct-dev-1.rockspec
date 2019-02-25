package = "luastruct"
version = "dev-1"
source = {
   url = "git+https://github.com/UlisseMini/luastruct",
   tag = "v1.0"
}
description = {
   summary = "Type safe data structures in pure lua",
   detailed = [[
I love lua, but i sometimes want to model my ideas in go-style structs,
so i wrote this. here is an example, more are in the readme :)

local struct = require "struct"
local person = struct {
   name = "default name",
   age  = 0
}

local default = person {
   age = 10
}

print(default.name) --> "default name"

local bob = person {
   name = "bob",
   age  = 20
}

print(default.name) --> "bob"

-- causes an error because the types do not match.
local invalid = person {
   name = 10,
   age  = "invalid age"
}
]],
   homepage = "https://github.com/UlisseMini/luastruct",
   license = "MIT"
}
build = {
   type = "builtin",
   modules = {
      struct = "struct.lua",
   }
}
