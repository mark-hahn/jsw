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
    fs.writeFileSync 'test/tojsw-ast.json', JSON.stringify ast
       
    jswMappings = []
    node_map = add: (node_gen_map) -> jswMappings.push node_gen_map
    streamOpts = {
      beautify:yes, 
      indent_level: 2, 
      node_map
    } 
    jswCodeStream  = Uglify.OutputStream streamOpts
    ast.print jswCodeStream
    jswCode = jswCodeStream.toString()
    metaStr = meta.encode jsCode, jswCode, jswMappings
    fs.writeFileSync 'test/jswCode.jsw', jswCode + metaStr
      
  console.log "^^^^^^^^^^^^^^^^^^\n" 
    
