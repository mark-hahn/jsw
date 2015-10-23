
log    = require('debug') 'utils'
fs     = require 'fs'
Uglify = require "uglify-js2-tojsw"

exports.dumpAst = (ast, file) ->
  tt = new Uglify.TreeTransformer null, (node) ->
    node.startPos = node.start.pos
    node.endPos = node.end.pos
    delete node.start 
    delete node.end
    node.type = node.TYPE
    if not node.body? or node.body.length is 0
      delete node.body
    node
  fs.writeFileSync file + '-ast-dump.json', JSON.stringify ast.transform tt
  ast
       
