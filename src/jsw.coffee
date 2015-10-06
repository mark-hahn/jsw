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
  
comments = []
tokens   = []

jsIn = fs.readFileSync 'test/js-in.js', 'utf8'

jsInAst = acorn.parse jsIn, 
  ecmaVersion: 6
  sourceType: 'script'
  allowHashBang: yes
  directSourceFile: 'src3'
  preserveParens: yes
  ranges: yes
  onComment: comments
  onToken: tokens

fs.writeFileSync 'test/js-in-ast', util.inspect jsInAst, depth: null

codegen.attachComments jsInAst, comments, tokens

jsOut = codegen.generate jsInAst, comment: true

fs.writeFileSync 'test/js-out.js', jsOut
