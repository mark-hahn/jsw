###
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
###  

log     = require('debug') 'jsw'
fs      = require 'fs'
utils   = require './utils'
args    = require './args'
UglifyT = require "uglify-js2-tojsw"
UglifyF = require "uglify-js2-fromjsw"
meta    = require './meta'
 
for file in args.files  
  console.log "\nvvvvvvvvvvvvvvvvvv"
     
  if args.tojsw 
    codeIn = fs.readFileSync file + '.js', 'utf8'
    ast = UglifyT.parse codeIn
    utils.dumpAst ast
    fs.writeFileSync 'test/ast.json', JSON.stringify ast
       
    opts = beautify:yes, indent_level: 2
    if args.map
      jswMappings = []
      opts.node_map = add: (node_gen_map) -> jswMappings.push node_gen_map
    codeOut = ast.print_to_string opts
    metaStr = (if args.map then meta.encode codeIn, codeOut, jswMappings else '')
    fs.writeFileSync file + '.jsw', codeOut + metaStr
      
  if args.fromjsw
    codeIn = fs.readFileSync file + '.jsw', 'utf8'
    ast = UglifyF.parse codeIn
    utils.dumpAst ast
    fs.writeFileSync 'test/ast.json', JSON.stringify ast
       
    opts = beautify:yes, indent_level: 2
    # if args.map
    #   jswMappings = []
    #   opts.node_map = add: (node_gen_map) -> jswMappings.push node_gen_map
    codeOut = ast.print_to_string opts
    # metaStr = (if args.map then meta.encode codeIn, codeOut, jswMappings else '')
    fs.writeFileSync file + '.js', codeOut
      
  console.log "^^^^^^^^^^^^^^^^^^\n" 
    
