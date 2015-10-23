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
  
  if args.tojsw 
    [fileNoExt, fileBase] = utils.checkFileExt file, '.js'
    codeIn = fs.readFileSync file, 'utf8'
    ast = UglifyT.parse codeIn
    utils.dumpAst ast, 'test/ast-dump.json'
    fs.writeFileSync 'test/ast.json', JSON.stringify ast
       
    opts = beautify:yes, indent_level: 2
    if args.map
      jswMappings = []
      opts.node_map = add: (node_gen_map) -> jswMappings.push node_gen_map
    codeOut = ast.print_to_string opts
    metaStr = (if args.map then meta.encode codeIn, codeOut, jswMappings else '')
    fs.writeFileSync fileNoExt + '.jsw', codeOut + metaStr

  if args.beautifyjs 
    [fileNoExt, fileBase] = utils.checkFileExt file, '.js'
    codeIn = fs.readFileSync file, 'utf8'
    ast = Uglify.parse codeIn
    utils.dumpAst ast, 'test/ast-dump' + fileBase + '.json'
    fs.writeFileSync 'test/b-ast.json', JSON.stringify ast
    codeOut = ast.print_to_string beautify:yes
    fs.writeFileSync 'test/b-out.js', codeOut
      
  if args.fromjsw
    [fileNoExt, fileBase] = utils.checkFileExt file, '.jsw'
    codeIn = fs.readFileSync file, 'utf8'
    if args.map
      [codeIn, metaObj] = meta.decode codeIn
      if not codeIn
        throw 'jsw metadata is missing, corrupted, or unknown version'
    ast = UglifyF.parse codeIn
    utils.dumpAst ast, 'test/ast-dump.json'
    fs.writeFileSync 'test/ast.json', JSON.stringify ast
       
    opts = beautify:yes, indent_level: 2
    codeOut = ast.print_to_string opts
    fs.writeFileSync 'test/meta.json', JSON.stringify metaObj ? {}
    fs.writeFileSync fileNoExt + '.js', codeOut

  chlklin.blue()      
    
