
log    = require('debug') 'utils'
fs     = require 'fs'
path   = require 'path'
Uglify = require "uglify-js2-tojsw"

exports.checkFileExt = (file, ext) ->
  if path.extname(file).toLowerCase() isnt ext
    throw "jsw error: #{file} is not a #{ext} file"
  fileBase = path.basename file, ext
  [path.dirname(file) + '/' + fileBase, fileBase]

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
  fs.writeFileSync file, JSON.stringify ast.transform tt
  ast
