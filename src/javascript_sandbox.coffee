
_ = require 'lodash'
uuid = require 'node-uuid'

gen_jail_api = (cb) ->
  log: console.log.bind console
  __finished__: cb

snippetsDefinition = (api) ->
  _.reduce api.snippets, ((acc, i, fname) ->
    "#{acc}\nvar #{fname} = #{i}"), ""

allRemotes = (api) ->
  (_.map (api.remote || {}), (api,key) -> "var #{key}=application.remote.#{key}").join ";"

Sandbox = {
  run: (code, customApi = {}) ->
    id = uuid.v4()

    snippets = snippetsDefinition customApi
    remotes = allRemotes customApi

    remoteApi = customApi.links
    snippetsApi = _.keys customApi.snippets

    apiArgs = (_.union remoteApi, snippetsApi).join ","

    evalCode = """
      var runTests = function(#{apiArgs}){#{code}};
      var start = function(application){ #{remotes};#{snippets};runTests(#{apiArgs})};
      start
    """

    # create "sandboxed" function
    try
      runner = eval evalCode
      # call it!
      runner customApi

      # is synchronous so.. its finished here
      customApi.remote?.finished?()
    catch e
      customApi.remote?.failed? e

  debug: (code, customApi, cbs) ->
    debugApi = _.union [(code) -> "debugger;\n#{code}"], customApi
    Sandbox.run code, debugApi, cbs

}

module.exports = Sandbox
