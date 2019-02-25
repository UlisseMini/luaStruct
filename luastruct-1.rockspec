package = "luastruct"
version = "1.0"
source = {
   url = "git+https://github.com/UlisseMini/luastruct",
   tag = "v1.0"
}
description = {
   summary = "Type safe data structures in pure lua",
   detailed = [[
   This package provides type safe data structures in pure lua,
   inspired by golang structs.
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
