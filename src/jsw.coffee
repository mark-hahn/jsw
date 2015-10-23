###
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
###  

log     = require('debug') 'jsw'
fs      = require 'fs'
utils   = require './utils'
args    = require './args'
Uglify  = require 'uglify-js2'
UglifyT = require 'uglify-js2-tojsw'
UglifyF = require 'uglify-js2-fromjsw'
meta    = require './meta'
chlklin = require 'chalkline'
 
for file in args.files  
  chlklin.magenta()
  # console.log '\nvvvvvvvvvvvvvvvvvv'
  
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

  if args.beautifyjs 
    codeIn = fs.readFileSync file + '.js', 'utf8'
    ast = Uglify.parse codeIn
    utils.dumpAst ast, 'test/b'
    fs.writeFileSync 'test/b-ast.json', JSON.stringify ast
    codeOut = ast.print_to_string beautify:yes
    fs.writeFileSync 'test/b-out.js', codeOut
      
  if args.fromjsw
    codeIn = fs.readFileSync file + '.jsw', 'utf8'
    if args.map
      [codeIn, metaObj] = meta.decode codeIn
      if not codeIn
        throw 'metadata in jsw file is missing or corrupted'
    ast = UglifyF.parse codeIn
    utils.dumpAst ast
    fs.writeFileSync 'test/ast.json', JSON.stringify ast
       
    opts = beautify:yes, indent_level: 2
    codeOut = ast.print_to_string opts
    fs.writeFileSync 'test/meta.json', JSON.stringify metaObj ? {}
    fs.writeFileSync file + '.js', codeOut

  chlklin.blue()      
  # console.log '^^^^^^^^^^^^^^^^^^\n' 
    
