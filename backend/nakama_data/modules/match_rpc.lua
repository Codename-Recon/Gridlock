local nk = require("nakama")

local function create_match(context, payload)
  local modulename = "match_handler"
  local setupstate = { initialstate = payload }
  local matchid = nk.match_create(modulename, setupstate)

  return nk.json_encode({ matchid = matchid })
end

nk.register_rpc(create_match, "create_match_rpc")
