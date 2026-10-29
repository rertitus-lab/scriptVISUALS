-- Platform: Roblox client / Luau; target: Extazz protected runtime.
local source = game:HttpGet("https://raw.githubusercontent.com/rertitus-lab/scriptVISUALS/refs/heads/main/extazz_runtime/loader-19187a3f251880a1.luau")
assert(type(source)=="string" and #source==779454, "[Extazz] Incomplete runtime download")
local program, reason = loadstring(source, "@extazz_runtime")
assert(program, reason)
return program(...)
