
var chai = require('chai');
chai.should();
var sandbox = require('../lib/javascript_sandbox');

describe("Javascript Sandbox", function(){
  
  it("should run simple code", function(){
    sandbox.run("var fn = function(){return 1;}");
  });
  it("should prevent exceptions", function(){
    (function(){sandbox.run("throw 'exc'");}).should.not.throw();
  });
  it("should call a linked remote function", function(done){
    sandbox.run("done()",{
      remote: { done: done },
      links: ["done"]
    });
  });
  it("should call finished after successful termination", function(done){
    sandbox.run("", {
      remote: { finished: done }
    });
  });
  it("should not expose remote functions", function(done){
    sandbox.run("finished()",{
      remote: {
        finished:function(){ throw "Remote function called"},
        failed: function(){done();}
      }
    });
  });
  it("should expose remotes to snippets", function(done){
    sandbox.run("snippet()",{
      remote: {
        done: done
      },
      snippets: {
        snippet: "function(){done();}"
      }
    });
  });
});
