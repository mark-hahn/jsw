###
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
### 

log     = require('debug') 'jsw'

fs      = require 'fs'
util    = require 'util'
acorn   = require 'acorn'
codegen = require 'escodegen'
args    = require './args'
# log args
  
jsIn = fs.readFileSync 'test/js-in.js', 'utf8'

comments = []
tokens   = []
jsInAst = acorn.parse jsIn,
  ecmaVersion:       6
  sourceType:       'script' # or 'module'
  allowHashBang:     yes
  preserveParens:    yes
  ranges:            yes
  onComment:         comments
  onToken:           tokens

fs.writeFileSync 'test/js-comments', util.inspect comments, depth: null
fs.writeFileSync 'test/js-tokens', util.inspect tokens, depth: null
fs.writeFileSync 'test/js-in-ast', util.inspect jsInAst, depth: null

codegen.attachComments jsInAst, comments, tokens
jsOut = codegen.generate jsInAst, comment: true

fs.writeFileSync 'test/js-out.js', jsOut
