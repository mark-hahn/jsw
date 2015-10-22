###
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
###  

log    = require('debug') 'jsw'
fs     = require 'fs'
utils  = require './utils'
args   = require './args'
Uglify = require "uglify-js2"
meta   = require './meta'

for file in args.files  
  console.log "\nvvvvvvvvvvvvvvvvvv"
      
  jsCode = fs.readFileSync file, 'utf8'
     
  if args.tojsw 
    ast = Uglify.parse jsCode
    utils.dumpAst ast
    fs.writeFileSync 'test/ast.json', JSON.stringify ast
       
    opts = beautify:yes, indent_level: 2
    if args.map
      jswMappings = []
      opts.node_map = add: (node_gen_map) -> jswMappings.push node_gen_map
      
    jswCodeStream  = Uglify.OutputStream opts
    ast.print jswCodeStream
    jswCode = jswCodeStream.toString()
    
    metaStr = (if args.map then meta.encode jsCode, jswCode, jswMappings else '')
    
    fs.writeFileSync 'test/jswCode.jsw', jswCode + metaStr
      
  console.log "^^^^^^^^^^^^^^^^^^\n" 
    
