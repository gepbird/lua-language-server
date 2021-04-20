local files    = require 'files'
local searcher = require 'core.searcher'
local lang     = require 'language'
local define   = require 'proto.define'

return function (uri, callback)
    local state = files.getAst(uri)
    if not state then
        return
    end

    local mark = {}
    searcher.eachSourceType(state.ast, 'break', function (source)
        local list = source.parent
        if mark[list] then
            return
        end
        mark[list] = true
        for i = #list, 1, -1 do
            local src = list[i]
            if src == source then
                if i == #list then
                    return
                end
                callback {
                    start   = list[i+1].start,
                    finish  = list[#list].range or list[#list].finish,
                    tags    = { define.DiagnosticTag.Unnecessary },
                    message = lang.script.DIAG_CODE_AFTER_BREAK,
                }
            end
        end
    end)
end
