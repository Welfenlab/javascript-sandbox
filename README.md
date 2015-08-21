![](https://travis-ci.org/Welfenlab/javascript-sandbox.svg)
# javascript-sandbox
This package creates an unreliable sandbox for running javascript code. It is compatible to the tutor jailed-sandbox and you can exchange it  any time.

# Installation
Install it via `npm` (at least npm version 2)

```
npm install @tutor/javascript-sandbox
```

# Usage
This sandbox exports a simple `run` command that takes the code and an optional API.

## API
You can pass an API object to the run function that allows the execution of external code in your sandbox. The API consists of three different parts:
- `snippets`: An object that defines snippets that are defined in the sandbox environment.
- `remote`: Object consisting of functions. Those remote functions are available in the snippets but not in the sandbox script.
- `links`: Links remote functions to the sandbox script, those are available in the sandbox environment.


## Example

```js
var sandbox = require('@tutor/javascript-sandbox');

sandbox.run("log('test');logIt('test2')", {
    remote: {
      log: console.log.bind(console),
      logSecure: console.log.bind(console)
    },
    snippets: {
      logIt: "function(msg) { logSecure(msg) }"
    }
    links: ["log"]
  })
```
