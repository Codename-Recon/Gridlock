local nk = require("nakama")
local M = {}

function M.match_init(context, initial_state)
        local state = {
                presences = {},
                empty_ticks = 0
        }
        local tick_rate = 1 -- 1 tick per second = 1 MatchLoop func invocations per second
        local label = initial_state.initialstate

        return state, tick_rate, label
end

-- When someone tries to join the match. Checks if someone is already logged in and blocks them from
-- doing so if so.
function M.match_join_attempt(_, _, _, state, presence, _)
    if state.presences[presence.user_id] ~= nil then
        return state, false, "User already logged in."
    end
    return state, true
end

function M.match_join(context, dispatcher, tick, state, presences)
        for _, presence in ipairs(presences) do
                state.presences[presence.session_id] = presence
        end

        return state
end

function M.match_leave(context, dispatcher, tick, state, presences)
        for _, presence in ipairs(presences) do
                state.presences[presence.session_id] = nil
        end

        return state
end

function M.match_loop(context, dispatcher, tick, state, messages)
  -- Get the count of presences in the match
  local totalPresences = 0
  for k, v in pairs(state.presences) do
    totalPresences = totalPresences + 1
  end

        -- If we have no presences in the match according to the match state, increment the empty ticks count
        if totalPresences == 0 then
                state.empty_ticks = state.empty_ticks + 1
        end

        -- If the match has been empty for more than 5 ticks, end the match by returning nil
        if state.empty_ticks > 5 then
                return nil
        end

        -- Broadcast messages to all clients
        for _, message in ipairs(messages) do
                local op_code = message.op_code
                local data = message.data
                local sender = message.sender

                dispatcher.broadcast_message(op_code, data)
        end

        return state
end

-- Server is shutting down.
function M.match_terminate(_, _, _, state, _)
    return state
end

-- Called when the match handler receives a runtime signal.
function M.match_signal(_, _, _, state, data)
        return state, data
end

return M