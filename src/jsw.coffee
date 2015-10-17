###
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
###  
     
log     = require('debug') 'jsw'
fs      = require 'fs'
util    = require 'util'
cst     = require 'cst'
args    = require './args'
_ = require 'underscore'
_.mixin require 'underscore.string'
_.mixin require 'underscore.inspector'
  
for file in args.files   
  pfx = 'test/' + file + '-'
     
  if args.parse
    jsIn = fs.readFileSync pfx + 'in.js', 'utf8'
    jsInAst = (new cst.Parser).parse jsIn
    # fs.writeFileSync pfx + 'in-ast.txt', _.inspect jsInAst
    fs.writeFileSync pfx + 'in-ast.js', jsInAst.sourceCode
  # else
    # jsInAst = JSON.parse fs.readFileSync pfx + 'in-ast.json', 'utf8'
    
  # if args.gen
  #   jsOut = codegen.generate jsInAst, 
  #     comment:  true
  #     # verbatim: 'x-verbatim-property'
  #     
  #   fs.writeFileSync pfx + 'out.js', jsOut
