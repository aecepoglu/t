package = "t"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/aecepoglu/t.git"
}
description = {
   homepage = "http://todo",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1, < 5.4",
	"luafilesystem",
}
build = {
   type = "builtin",
   modules = {},
	install = {
		bin = { "t" }
	}
}
