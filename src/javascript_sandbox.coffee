
_ = require 'lodash'
uuid = require 'node-uuid'

gen_jail_api = (cb) ->
  log: console.log.bind console
  __finished__: cb

Sandbox = {
  createApi: () ->
    []
  generateApiMethod: (name) ->
    process: (code) -> "var #{name}=function(){application.remote.#{name}.apply(null,arguments)}\n#{code}"
    name: name
  createRunner: (customApi = [], cbs = {}) ->
    run: _.partial Sandbox.run, _, customApi, cbs
    debug: _.partial Sandbox.run, _, customApi, cbs
  run: (code, customApi) ->
    id = uuid.v4()

    # generate api link similar to jailed
    api = remote: customApi

    evalCode = "var fn = function(application){#{code}};fn";

    # create "sandboxed" function
    try
      runner = eval evalCode
      # call it!
      runner api

      # is synchronous so.. its finished here
      customApi.finished?()
    catch e
      customApi.failed? e

  debug: (code, customApi, cbs) ->
    debugApi = _.union [(code) -> "debugger;\n#{code}"], customApi
    Sandbox.run code, debugApi, cbs

}

module.exports = Sandbox
