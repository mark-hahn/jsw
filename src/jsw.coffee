###
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
###  

log    = require('debug') 'jsw'
fs     = require 'fs'
util   = require 'util'
args   = require './args'
Uglify = require "uglify-js2"
crypto = require 'crypto'
zlib   = require 'zlib'

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
  jsCode = fs.readFileSync file, 'utf8'
     
  if args.tojsw 
    ast = Uglify.parse jsCode
    dumpAst ast
    fs.writeFileSync pfx + 'tojsw-ast.json', JSON.stringify ast
       
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
     
    addContexts = (map) ->
      addOneCtx = (key, pos, dir) ->
        ctx = ''
        for i in [1..100]
          pos += i * dir
          if not (chr = jswCode[pos])? then break
          ctx += chr
        map[key] = ctx.replace /[\x00-\x1f]/g, '~'
      addOneCtx 'topCtx', map.gen_start_pos, -1
      addOneCtx 'botCtx', map.gen_end_pos-1, +1
      map
       
    meta = {}
    for jswMap in jswMappings then do ->
      {type, orig_start_pos, orig_end_pos, gen_start_pos, gen_end_pos} = jswMap
      jswCodeNode = jswCode[gen_start_pos...gen_end_pos]
      hash = crypto.createHash 'md5'
      hash.update jswCodeNode
      key = type + '-' + hash.digest 'hex'
      metaMap = {orig_start_pos, orig_end_pos, gen_start_pos, gen_end_pos}
      if (val = meta[key])
        if not Array.isArray val
          meta[key] = [ addContexts val ]
        meta[key].push addContexts metaMap
      else
        meta[key] = metaMap
    for key, val of meta
      if not Array.isArray val
        delete val.gen_start_pos
        delete val.gen_end_pos
      else
        for val2 in val
          delete val2.gen_start_pos
          delete val2.gen_end_pos
    base64 = zlib.deflateSync(JSON.stringify meta).toString 'base64'
    metaLines = ''
    for idx in [0..9e9] by 80 when idx < base64.length
      metaLines += '#' + base64[idx...idx+80] + '\n'
    metaBase64 = '\n\n### metadata to translate jsw to js losslessly ###\n' + metaLines          
    
    fs.writeFileSync pfx +   'meta.json', JSON.stringify meta
    fs.writeFileSync pfx + 'jswCode.jsw', jswCode + metaBase64
      
  console.log "^^^^^^^^^^^^^^^^^^\n" 
    
