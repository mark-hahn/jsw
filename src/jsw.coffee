###
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
### 
  
log     = require('debug') 'jsw'
fs      = require 'fs'
util    = require 'util'
args    = require './args'
uglify  = require "uglify-js2"

for file in args.files   
  pfx = 'test/'
  jsIn = fs.readFileSync file, 'utf8'

  if args.parse 
    jsInAst = uglify.parse jsIn
    fs.writeFileSync pfx + 'in-ast.json', JSON.stringify jsInAst
    
    # fs.writeFileSync pfx + 'final.jsw', generated.code
    
  else
    log 'not parse'
    jsInAst = JSON.parse fs.readFileSync pfx + 'in-ast.json', 'utf8'
    
  if args.gen
    jsOut = ''
    fs.writeFileSync pfx + 'mirror.js', jsOut
