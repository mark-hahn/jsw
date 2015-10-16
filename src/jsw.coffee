###
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
### 
 
log     = require('debug') 'jsw'
fs      = require 'fs'
util    = require 'util'
acorn   = require 'acorn'
codegen = require 'escodegen'
args    = require './args'
genJSW  = require './genJSW'
  
for file in args.files   
  pfx = 'test/' + file + '-'
  comments = tokens = null
   
  if args.parse
    jsIn = fs.readFileSync pfx + 'in.js', 'utf8'
    comments = []
    tokens   = []
    jsInAst = acorn.parse jsIn,
      ecmaVersion:       6
      sourceType:       'script' # 'module'
      allowHashBang:     yes
      preserveParens:    yes
      ranges:            yes 
      onComment:         comments
      onToken:           tokens
    codegen.attachComments jsInAst, comments, tokens
    fs.writeFileSync pfx + 'in-ast.json', JSON.stringify jsInAst
    
    generated = genJSW.generate jsInAst, {}
    
    fs.writeFileSync pfx + 'generated.jsw', generated
    
  else
    jsInAst = JSON.parse fs.readFileSync pfx + 'in-ast.json', 'utf8'
    
  if args.comments then fs.writeFileSync pfx + 'comments', util.inspect comments, depth: null
  if args.tokens   then fs.writeFileSync pfx + 'tokens',   util.inspect tokens,   depth: null

  if args.gen
    jsOut = codegen.generate jsInAst, 
      comment:  true
      # verbatim: 'x-verbatim-property'
      
    fs.writeFileSync pfx + 'out.js', jsOut
