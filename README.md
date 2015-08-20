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
- `snippets`: Defines a snippet that 
