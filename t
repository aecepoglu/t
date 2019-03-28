#!/usr/bin/env lua5.3

local lfs = require("lfs")

local Mode = {
	list = 0,
	edit = 1,
	count = 2,
}

local function split(str, delim)
	local tokens = {}
	for w in (str .. delim):gmatch("(.-)"..delim) do
		table.insert(tokens, w)
	end

	return tokens
end

local function join(tokens, len, delim)
	local resp = ""
	for i = 1, len do
		resp = resp .. delim .. tokens[i]
	end
	return resp
end

local function quit(msg)
	print(msg)
	os.exit(1)
end

local function find_in_ancestry(filename)
	local tokens = split(lfs.currentdir(), "/")
	local len = #tokens
	local tested = {}

	while len > 0 do
		local path = join(tokens, len, "/") .. "/" .. filename
		table.insert(tested, path)
		if lfs.attributes(path) ~= nil then
			return true, path, tested
		end
		len = len - 1
	end

	return false, nil, tested
end

local function collect_todos(path, regex, f, acc0)
	local acc = acc0
	for line in io.open(path):lines() do
		local x = line:match(regex)
		if x then
			acc = f(acc, x)
		end
	end
	return acc
end

local function main(mode, filename)
	local has_found, path, checked_paths = find_in_ancestry(filename)

	if not has_found then
		return quit(
			"Couldn't find \"" .. filename .. "\" in these locations:\n"
			.. (join(checked_paths, #checked_paths, "\n"))
		)
	end

	if mode == Mode.count then
		print(
			collect_todos(
				path,
				"%sTODO ",
				function(acc, _)
					return acc + 1
				end,
				0
			)
		)
	elseif mode == Mode.list then
		print(
			collect_todos(
				path,
				"%sTODO (.+)",
				function(acc, descr)
					return acc .. (acc == "" and "" or "\n") .. descr
				end,
				""
			)
		)
	else --edit
		local editor = os.getenv("EDITOR") or quit("EDITOR not set")
		os.execute(editor .. " " .. path)
	end
end

local function parse_args(arg)
	local mode = Mode.list

	if (#arg == 1) then
		local x = arg[1]:sub(1, 1)

		if x == "e" then
			mode = Mode.edit
		elseif x == "l" then
			mode = Mode.list
		elseif x == "c" then
			mode = Mode.count
		else
			quit("Unknown mode: \"" .. x .. "\". Valid options are (e|edit|l|list|c|count)")
		end
	end

	return mode
end

main(parse_args(arg), "life.adoc")
