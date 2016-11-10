compile = require('slm').compile
path = require('path')
fs = require('fs')
html = require("html")

_typeof = if typeof Symbol == 'function' and typeof Symbol.iterator == 'symbol' then ((obj) ->
  typeof obj
) else ((obj) ->
  if obj and typeof Symbol == 'function' and obj.constructor == Symbol and obj != Symbol.prototype then 'symbol' else typeof obj
)

# Allows modules included by slm-brunch to be overwritten by
# a module in the current working directory's ./node_modules.
localRequire = (module) ->
  try
    modulePath = path.join process.cwd(), 'node_modules', module
    return require modulePath

  catch userError
    throw userError unless userError.code is 'MODULE_NOT_FOUND'

    try
      return require module

    catch localError
      throw localError

clone = (obj) ->
  if null == obj or 'object' != (if typeof obj == 'undefined' then 'undefined' else _typeof(obj))
    return obj
  copy = obj.constructor()
  for attr of obj
    if obj.hasOwnProperty(attr)
      copy[attr] = clone(obj[attr])
  copy

module.exports = class SlmCompiler
  brunchPlugin: yes
  type: 'template'
  staticTargetExtension: 'html'
  pattern: /\.(?:slim|slm)$/

  setup: (config) ->
    @options = clone(config) || {}
    @options.locals = config.locals || {}
   
  constructor: (config) ->
    @setup(config)

  compileStatic: (data, path, callback) ->
    options = @options
    filepath = data.path
    return new Promise (resolve, reject) ->
      try
        fs.readFile filepath, 'utf8', (err, data) ->
          if err 
            throw err
          result = compile(String(data), options)(options.locals)
          prettyResult = html.prettyPrint(result, {indent_size: 2})
          resolve(prettyResult)
      catch err
        error = reject(err)

