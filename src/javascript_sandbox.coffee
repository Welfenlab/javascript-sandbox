
_ = require 'lodash'
uuid = require 'node-uuid'

gen_jail_api = (cb) ->
  log: console.log.bind console
  __finished__: cb

interalDefinition = (api) ->
  _.reduce api.internal, ((acc, i, fname) ->
    "#{acc}\nvar #{fname} = #{i}"), ""

allRemotes = (api) ->
  (_.map (api.remote || {}), (api,key) -> "var #{key}=application.remote.#{key}").join ";"

Sandbox = {
  run: (code, customApi = {}) ->
    id = uuid.v4()

    internals = interalDefinition customApi
    remotes = allRemotes customApi

    remoteApi = customApi.links
    internalApi = _.keys customApi.internal

    apiArgs = (_.union remoteApi, internalApi).join ","

    evalCode = """
      var runTests = function(#{apiArgs}){#{code}};
      var start = function(application){ #{remotes};#{internals};runTests(#{apiArgs})};
      start
    """

    # create "sandboxed" function
    try
      runner = eval evalCode
      # call it!
      runner customApi

      # is synchronous so.. its finished here
      customApi.remote?.private?.finished?()
    catch e
      customApi.remote?.private?.failed? e

  debug: (code, customApi, cbs) ->
    debugApi = _.union [(code) -> "debugger;\n#{code}"], customApi
    Sandbox.run code, debugApi, cbs

}

module.exports = Sandbox
