###
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
###  

log       = require('debug') 'jsw'
fs        = require 'fs'
util      = require 'util'
args      = require './args'
Uglify    = require "uglify-js2"
   
dumpAst = (ast) ->
  tt = new Uglify.TreeTransformer null, (node) ->
    node.startPos = node.start.pos
    node.endPos = node.end.pos
    delete node.start
    delete node.end
    node.type = node.TYPE
    if not node.body? or node.body.length is 0
      delete node.body
    node
  fs.writeFileSync pfx + 'dump.json', JSON.stringify ast.transform tt
  ast
      
for file in args.files  
  console.log "\nvvvvvvvvvvvvvvvvvv"
      
  pfx = 'test/'
  jsIn = fs.readFileSync file, 'utf8'
     
  if args.tojsw 
    ast = dumpAst Uglify.parse jsIn
    fs.writeFileSync pfx + 'in-ast.json', JSON.stringify ast
       
    node_map = add: (type, origStart, origEnd, genStart, genEnd) ->
      log 'node_mapping', {type, origStart, origEnd, genStart, genEnd}
      
    streamOpts = {
      beautify:yes, 
      indent_level: 2, 
      node_map
    } 
     
    if args.map
      source_map = Uglify.SourceMap()
      streamOpts.source_map = source_map
      
    out  = Uglify.OutputStream streamOpts
    ast.print out
    log util.inspect ast
    fs.writeFileSync pfx + 'out.js', out.toString()
     
    # streamOpts = beautify:yes, indent_level: 2
    # ast.walk new Uglify.TreeWalker (node, descend) ->
    #   if node instanceof Uglify.AST_Statement
    #     fs.appendFileSync pfx + 'stmt.js', JSON.stringify(node.TYPE) + '\n\n'
    # fs.writeFileSync pfx + 'out.js', out.toString()
    
    # out.push_node ast
    # out.print JSON.stringify out.stack()
    # fs.writeFileSync pfx + 'out.json', out.toString()
    
    # ast.print stream
    # 
    # fs.writeFileSync pfx + 'final.js', stream.toString()
       
    if args.map
      fs.writeFileSync pfx + 'map.json', source_map.toString()
    
  console.log "^^^^^^^^^^^^^^^^^^\n" 
    
