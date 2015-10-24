###
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
###  

log        = require('debug') 'jsw'
fs         = require 'fs'
utils      = require './utils'
args       = require './args'
UglifyT0   = require '../uglify/tojsw/node'
UglifyFrom = require '../uglify/fromjsw/node'
meta       = require './meta'
chlklin    = require 'chalkline'

for file in args.files  
  chlklin.magenta()
  
  if args.tojsw 
    [fileNoExt, fileBase] = utils.checkFileExt file, '.js'
    jsCode = fs.readFileSync file, 'utf8'
    ast = UglifyT0.parse jsCode
    utils.dumpAst ast, 'test/ast-dump.json'
    fs.writeFileSync 'test/ast.json', JSON.stringify ast
       
    opts = beautify:yes, indent_level: 2
    if args.map
      jswMappings = []
      opts.node_map = add: (node_gen_map) -> jswMappings.push node_gen_map
    jswCode = ast.print_to_string opts
    metaStr = (if args.map then meta.encode jsCode, jswCode, jswMappings else '')
    fs.writeFileSync fileNoExt + '.jsw', jswCode + metaStr

  ## for debug only
  if args.beautifyjs 
    Uglify = require 'uglify-js2'
    [fileNoExt, fileBase] = utils.checkFileExt file, '.js'
    jsCode = fs.readFileSync file, 'utf8'
    ast = Uglify.parse jsCode
    utils.dumpAst ast, 'test/ast-dump' + fileBase + '.json'
    fs.writeFileSync 'test/b-ast.json', JSON.stringify ast
    jsCode = ast.print_to_string beautify:yes
    fs.writeFileSync 'test/b-out.js', jsCode
      
  if args.fromjsw
    [fileNoExt, fileBase] = utils.checkFileExt file, '.jsw'
    jswCode = fs.readFileSync file, 'utf8'
    if args.map
      [jswCode, metaObj] = meta.decode jswCode
      metaObj.jswCode = jswCode
      if not jswCode
        throw 'jsw metadata is missing, corrupted, or unknown version'
      fs.writeFileSync 'test/meta.json', JSON.stringify metaObj ? {}
      
    ast = UglifyFrom.parse jswCode
    utils.dumpAst ast, 'test/ast-dump.json'
    fs.writeFileSync 'test/ast.json', JSON.stringify ast
       
    opts = beautify:yes, indent_level: 2
    if args.map
      opts.jsw_out_meta = metaObj
    jsCode = ast.print_to_string opts
    fs.writeFileSync fileNoExt + '.js', jsCode

  chlklin.blue()      
    
