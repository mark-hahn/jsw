  
log    = require('debug') 'meta'
fs     = require 'fs'
crypto = require 'crypto'
zlib   = require 'zlib'
  
exports.encode = (jsCode, jswCode, jswMappings) ->
  
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
      
  meta = {vers: 1, code: jsCode}
  for jswMap in jswMappings then do ->
    {type, orig_start_pos, orig_end_pos, gen_start_pos, gen_end_pos} = jswMap
    hash = crypto.createHash 'md5'
    hash.update jswCode[gen_start_pos...gen_end_pos]
    key = type + '-' + hash.digest 'hex'
    metaMap = {start: orig_start_pos, end: orig_end_pos, gen_start_pos, gen_end_pos}
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
  metaJson = JSON.stringify meta
  fs.writeFileSync 'test/meta.json', metaJson
  
  base64 = zlib.deflateSync(metaJson).toString 'base64'
  metaLines = ''
  for idx in [0..9e9] by 80 when idx < base64.length
    metaLines += '#' + base64[idx...idx+80] + '\n'
  '\n\n### metadata to translate jsw to js losslessly (vers 1) ###\n' + metaLines     
     