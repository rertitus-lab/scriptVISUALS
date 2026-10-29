-- Platform: Roblox client / Luau; target: Extazz protected runtime.
local source = game:HttpGet("https://raw.githubusercontent.com/rertitus-lab/scriptVISUALS/refs/heads/main/extazz_runtime/loader-e1d8afe3de4b0954.luau")
assert(type(source)=="string" and #source==812781, "[Extazz] Incomplete runtime download")
local program, reason = loadstring(source, "@extazz_runtime")
assert(program, reason)
return program(...)
