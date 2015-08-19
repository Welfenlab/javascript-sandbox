
_ = require 'lodash'
uuid = require 'node-uuid'

gen_jail_api = (cb) ->
  log: console.log.bind console
  __finished__: cb

Sandbox = {
  createApi: () ->
    []
  generateApiMethod: (name) ->
    # generate random name
    id = uuid.v4()
    process: (code) -> "var #{name}=function(){application.remote.#{name}.apply(null,arguments)}\n#{code}"
    name: name
  createRunner: (customApi = [], cbs = {}) ->
    run: _.partial Sandbox.run, _, customApi, cbs
    debug: _.partial Sandbox.run, _, customApi, cbs
  run: (code, customApi) ->
    id = uuid.v4()

    internals = _.reduce customApi.internal, ((acc, i, fname) ->
      "#{acc}\nvar #{fname} = #{i}"), ""

    remoteApi = _(customApi.remote).chain()
      .keys()
      .reject (v) -> (v=="finished" or v == "failed")
      .value()
    remotes = (_.map remoteApi, (api) -> "var #{api} = application.remote.#{api}").join ";"
    internalApi = _.keys customApi.internal

    apiArgs = (_.union remoteApi, internalApi).join ","

    evalCode = """
      var runTests = function(#{apiArgs}){#{code}};
      var start = function(application){ #{remotes};#{internals};runTests(#{apiArgs})};
      start
    """

    console.log evalCode

    # create "sandboxed" function
    try
      runner = eval evalCode
      # call it!
      runner customApi

      # is synchronous so.. its finished here
      customApi.remote.finished?()
    catch e
      customApi.remote.failed? e

  debug: (code, customApi, cbs) ->
    debugApi = _.union [(code) -> "debugger;\n#{code}"], customApi
    Sandbox.run code, debugApi, cbs

}

module.exports = Sandbox
