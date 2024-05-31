-- -*- mode: lua; -*-
-- A sample custom reader that just parses text into blankline-separated
-- paragraphs with space-separated words.

-- For better performance we put these functions in local variables:
local P, S, R, Cf, Cc, Ct, V, Cs, Cg, Cb, B, C, Cmt =
	lpeg.P, lpeg.S, lpeg.R, lpeg.Cf, lpeg.Cc, lpeg.Ct, lpeg.V, lpeg.Cs, lpeg.Cg, lpeg.Cb, lpeg.B, lpeg.C, lpeg.Cmt

local whitespacechar = S(" \t\r\n")
local linebreakchar = S("\r\n")
local wordchar = (1 - linebreakchar)
local properchar = (1 - whitespacechar)
local spacechar = S(" \t")
local newline = (P("\r") ^ -1 * P("\n"))
local commentchar = P("#")
local shebang = P("#!") * wordchar ^ 0 * linebreakchar
local noncommentwordchar = (wordchar - commentchar)
local noncommentlines = (((wordchar - commentchar) * (wordchar ^ 0)) ^ -1 * newline) ^ 1
local noncommentlineswithstart = newline * noncommentlines
local ignoredlines = newline ^ -1 * (commentchar * ((properchar * wordchar ^ 0) + spacechar ^ 0) * newline) ^ 1
local endline = newline

local function ListItem(lev, ch)
	local start
	if ch == nil then
		start = S("*#")
	else
		start = P(ch)
	end
	local subitem = function(c)
		if lev < 6 then
			return ListItem(lev + 1, c)
		else
			return (1 - 1) -- fails
		end
	end
	local parser = whitespacechar ^ 0
		* commentchar
		* (spacechar ^ 2)
		* start ^ lev
		* #-start
		* spacechar ^ 0
		* Ct((V("Inline") - newline) ^ 1)
		* newline ^ -1
		* ((#(commentchar * spacechar ^ 2) * Ct(subitem("*") ^ 1) / pandoc.BulletList) + (#(commentchar * spacechar ^ 2) * Ct(
			subitem("#") ^ 1
		) / pandoc.OrderedList) + Cc(nil))
		/ function(ils, sublist)
			return { pandoc.Plain(ils), sublist }
		end
	return parser
end

-- Grammar
G = P({
	"Pandoc",
	Pandoc = shebang ^ -1 -- There can be shebang at the beginning
		* Ct(V("Block") ^ 0) -- Then, the header documentation comes
		* 1 ^ 0 -- Finally, anything can come, but ignored
		/ function(blocks)
			local meta = pandoc.Meta({
				date = pandoc.MetaString(os.date("%B %d, %Y")),
			})
			return pandoc.Pandoc(blocks, meta)
		end,
	Block = ignoredlines ^ 0 -- There can be blank lines at the beginning
		* #commentchar -- Each block must start with #
		* (V("Header") + V("List") + V("Para")),
	Header = commentchar
		* spacechar -- There must be a space after #
		* #properchar -- There must not be a space to be a header
		* Ct((V("Inline") - newline) ^ 1) -- The inline part comes
		* newline -- and each header ends with a newline
		/ function(x)
			return pandoc.Header(1, x)
		end, -- All headers are level 1
	Para = commentchar
		* (spacechar ^ 2) -- There must be at least two spaces after #
		* #(1 - S("*#")) -- This must not be a list
		* Ct(V("Inline") ^ 1) -- The inline part comes
		* newline ^ -1 -- and each paragraph ends with a newline if possible
		/ pandoc.Para,
	List = #(commentchar * spacechar ^ 2) -- There must be at least two spaces after #
		* (V("BulletList") + V("OrderedList")),
	BulletList = Ct(ListItem(1, "*") ^ 1) / pandoc.BulletList,
	OrderedList = Ct(ListItem(1, "#") ^ 1) / pandoc.OrderedList,
	Inline = V("Str") + V("Space") + V("SoftBreak"),
	Str = wordchar ^ 1 / pandoc.Str,
	Space = spacechar ^ 1 / pandoc.Space,
	SoftBreak = (endline * (commentchar * spacechar ^ 2 * #(1 - S("*#")))) / pandoc.SoftBreak,
})

function Reader(input, options)
	return lpeg.match(G, tostring(input))
end
