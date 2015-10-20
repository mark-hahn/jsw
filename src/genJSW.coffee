
###
  genJSW.coffee
  generates JSW code from JS AST
  this is a butchered version of escodegen
    https://github.com/estools/escodegen
    commit: fc99fcda78aabf949c1c94c0058bdc1cf0278d8a
###

log    = require('debug') 'genjsw'
fs     = require 'fs'
crypto = require 'crypto'
rimraf = require 'rimraf'

createSrcNodesFile = yes
originalSourceCode = null

Syntax = undefined
Precedence = undefined
BinaryPrecedence = undefined
SourceNode = undefined
estraverse = undefined
esutils = undefined
isArray = undefined
base = undefined
indent = undefined
json = undefined
renumber = undefined
hexadecimal = undefined
quotes = undefined
escapeless = undefined
newline = undefined
space = undefined
parentheses = undefined
semicolons = undefined
safeConcatenation = undefined
directive = undefined
extra = undefined
parse = undefined
sourceMap = undefined
sourceCode = undefined
preserveBlankLines = undefined
FORMAT_MINIFY = undefined
FORMAT_DEFAULTS = undefined
estraverse = require("estraverse")
esutils = require("esutils")
Syntax = estraverse.Syntax
Precedence =
  Sequence: 0
  Yield: 1
  Await: 1
  Assignment: 1
  Conditional: 2
  ArrowFunction: 2
  LogicalOR: 3
  LogicalAND: 4
  BitwiseOR: 5
  BitwiseXOR: 6
  BitwiseAND: 7
  Equality: 8
  Relational: 9
  BitwiseSHIFT: 10
  Additive: 11
  Multiplicative: 12
  Unary: 13
  Postfix: 14
  Call: 15
  New: 16
  TaggedTemplate: 17
  Member: 18
  Primary: 19

BinaryPrecedence =
  "||": Precedence.LogicalOR
  "&&": Precedence.LogicalAND
  "|": Precedence.BitwiseOR
  "^": Precedence.BitwiseXOR
  "&": Precedence.BitwiseAND
  "==": Precedence.Equality
  "!=": Precedence.Equality
  "===": Precedence.Equality
  "!==": Precedence.Equality
  is: Precedence.Equality
  isnt: Precedence.Equality
  "<": Precedence.Relational
  ">": Precedence.Relational
  "<=": Precedence.Relational
  ">=": Precedence.Relational
  in: Precedence.Relational
  instanceof: Precedence.Relational
  "<<": Precedence.BitwiseSHIFT
  ">>": Precedence.BitwiseSHIFT
  ">>>": Precedence.BitwiseSHIFT
  "+": Precedence.Additive
  "-": Precedence.Additive
  "*": Precedence.Multiplicative
  "%": Precedence.Multiplicative
  "/": Precedence.Multiplicative

F_ALLOW_IN = 1
F_ALLOW_CALL = 1 << 1
F_ALLOW_UNPARATH_NEW = 1 << 2
F_FUNC_BODY = 1 << 3
F_DIRECTIVE_CTX = 1 << 4
F_SEMICOLON_OPT = 1 << 5
E_FTT = F_ALLOW_CALL | F_ALLOW_UNPARATH_NEW
E_TTF = F_ALLOW_IN | F_ALLOW_CALL
E_TTT = F_ALLOW_IN | F_ALLOW_CALL | F_ALLOW_UNPARATH_NEW
E_TFF = F_ALLOW_IN
E_FFT = F_ALLOW_UNPARATH_NEW
E_TFT = F_ALLOW_IN | F_ALLOW_UNPARATH_NEW
S_TFFF = F_ALLOW_IN
S_TFFT = F_ALLOW_IN | F_SEMICOLON_OPT
S_FFFF = 0x00
S_TFTF = F_ALLOW_IN | F_DIRECTIVE_CTX
S_TTFF = F_ALLOW_IN | F_FUNC_BODY
isArray = Array.isArray
unless isArray
  isArray = isArray = (array) ->
    Object::toString.call(array) is "[object Array]"

isExpression = (node) ->
  CodeGenerator.Expression.hasOwnProperty node.type
  
isStatement = (node) ->
  CodeGenerator.Statement.hasOwnProperty node.type
  
getDefaultOptions = ->
  indent: null
  base: null
  parse: null
  comment: false
  format:
    indent:
      style: "  "
      base: 0
      adjustMultilineComment: false

    newline: "\n"
    space: " "
    json: false
    renumber: false
    hexadecimal: false
    quotes: "single"
    escapeless: false
    compact: false
    parentheses: true
    semicolons: true
    safeConcatenation: false
    preserveBlankLines: false

  moz:
    comprehensionExpressionStartsWithAssignment: false
    starlessGenerator: false

  sourceMap: null
  sourceMapRoot: null
  sourceMapWithCode: false
  directive: false
  raw: true
  verbatim: null
  sourceCode: null
  
stringRepeat = (str, num) ->
  result = ""
  num |= 0
  while num > 0
    result += str  if num & 1
    num >>>= 1
    str += str
  result
  
hasLineTerminator = (str) ->
  (/[\r\n]/g).test str
  
endsWithLineTerminator = (str) ->
  len = str.length
  len and esutils.code.isLineTerminator(str.charCodeAt(len - 1))
  
merge = (target, override) ->
  key = undefined
  for key of override
    target[key] = override[key]  if override.hasOwnProperty(key)
  target
  
updateDeeply = (target, override) ->
  isHashObject = (target) ->
    typeof target is "object" and target instanceof Object and (target not instanceof RegExp)
  key = undefined
  val = undefined
  for key of override
    if override.hasOwnProperty(key)
      val = override[key]
      if isHashObject(val)
        if isHashObject(target[key])
          updateDeeply target[key], val
        else
          target[key] = updateDeeply({}, val)
      else
        target[key] = val
  target
  
generateNumber = (value) ->
  result = undefined
  point = undefined
  temp = undefined
  exponent = undefined
  pos = undefined
  throw new Error("Numeric literal whose value is NaN")  if value isnt value
  throw new Error("Numeric literal whose value is negative")  if value < 0 or (value is 0 and 1 / value < 0)
  return (if json then "null" else (if renumber then "1e400" else "1e+400"))  if value is 1 / 0
  result = "" + value
  return result  if not renumber or result.length < 3
  point = result.indexOf(".")
  if not json and result.charCodeAt(0) is 0x30 and point is 1
    point = 0
    result = result.slice(1)
  temp = result
  result = result.replace("e+", "e")
  exponent = 0
  if (pos = temp.indexOf("e")) > 0
    exponent = +temp.slice(pos + 1)
    temp = temp.slice(0, pos)
  if point >= 0
    exponent -= temp.length - point - 1
    temp = +(temp.slice(0, point) + temp.slice(point + 1)) + ""
  pos = 0
  --pos  while temp.charCodeAt(temp.length + pos - 1) is 0x30
  if pos isnt 0
    exponent -= pos
    temp = temp.slice(0, pos)
  temp += "e" + exponent  if exponent isnt 0
  result = temp  if (temp.length < result.length or (hexadecimal and value > 1e12 and Math.floor(value) is value and (temp = "0x" + value.toString(16)).length < result.length)) and +temp is value
  result
  
escapeRegExpCharacter = (ch, previousIsBackslash) ->
  if (ch & ~1) is 0x2028
    return (if previousIsBackslash then "u" else "\\u") + (if (ch is 0x2028) then "2028" else "2029")
  else return (if previousIsBackslash then "" else "\\") + (if (ch is 10) then "n" else "r")  if ch is 10 or ch is 13
  String.fromCharCode ch
  
generateRegExp = (reg) ->
  match = undefined
  result = undefined
  flags = undefined
  i = undefined
  iz = undefined
  ch = undefined
  characterInBrack = undefined
  previousIsBackslash = undefined
  result = reg.toString()
  if reg.source
    match = result.match(/\/([^\/]*)$/)
    return result  unless match
    flags = match[1]
    result = ""
    characterInBrack = false
    previousIsBackslash = false
    i = 0
    iz = reg.source.length

    while i < iz
      ch = reg.source.charCodeAt(i)
      unless previousIsBackslash
        if characterInBrack
          characterInBrack = false  if ch is 93
        else
          if ch is 47
            result += "\\"
          else characterInBrack = true  if ch is 91
        result += escapeRegExpCharacter(ch, previousIsBackslash)
        previousIsBackslash = ch is 92
      else
        result += escapeRegExpCharacter(ch, previousIsBackslash)
        previousIsBackslash = false
      ++i
    return "/" + result + "/" + flags
  result
  
escapeAllowedCharacter = (code, next) ->
  hex = undefined
  return "\\b"  if code is 0x08
  return "\\f"  if code is 0x0C
  return "\\t"  if code is 0x09
  hex = code.toString(16).toUpperCase()
  if json or code > 0xFF
    "\\u" + "0000".slice(hex.length) + hex
  else if code is 0x0000 and not esutils.code.isDecimalDigit(next)
    "\\0"
  else if code is 0x000B
    "\\x0B"
  else
    "\\x" + "00".slice(hex.length) + hex
    
escapeDisallowedCharacter = (code) ->
  return "\\\\"  if code is 0x5C
  return "\\n"  if code is 0x0A
  return "\\r"  if code is 0x0D
  return "\\u2028"  if code is 0x2028
  return "\\u2029"  if code is 0x2029
  throw new Error("Incorrectly classified character")
  
escapeDirective = (str) ->
  i = undefined
  iz = undefined
  code = undefined
  quote = undefined
  quote = (if quotes is "double" then "\"" else "'")
  i = 0
  iz = str.length

  while i < iz
    code = str.charCodeAt(i)
    if code is 0x27
      quote = "\""
      break
    else if code is 0x22
      quote = "'"
      break
    else ++i  if code is 0x5C
    ++i
  quote + str + quote
  
escapeString = (str) ->
  result = ""
  i = undefined
  len = undefined
  code = undefined
  singleQuotes = 0
  doubleQuotes = 0
  single = undefined
  quote = undefined
  i = 0
  len = str.length

  while i < len
    code = str.charCodeAt(i)
    if code is 0x27
      ++singleQuotes
    else if code is 0x22
      ++doubleQuotes
    else if code is 0x2F and json
      result += "\\"
    else if esutils.code.isLineTerminator(code) or code is 0x5C
      result += escapeDisallowedCharacter(code)
      continue
    else if not esutils.code.isIdentifierPartES5(code) and (json and code < 0x20 or not json and not escapeless and (code < 0x20 or code > 0x7E))
      result += escapeAllowedCharacter(code, str.charCodeAt(i + 1))
      continue
    result += String.fromCharCode(code)
    ++i
  single = not (quotes is "double" or (quotes is "auto" and doubleQuotes < singleQuotes))
  quote = (if single then "'" else "\"")
  return quote + result + quote  unless (if single then singleQuotes else doubleQuotes)
  str = result
  result = quote
  i = 0
  len = str.length

  while i < len
    code = str.charCodeAt(i)
    result += "\\"  if (code is 0x27 and single) or (code is 0x22 and not single)
    result += String.fromCharCode(code)
    ++i
  result + quote
flattenToString = (arr) ->
  i = undefined
  iz = undefined
  elem = undefined
  result = ""
  i = 0
  iz = arr.length

  while i < iz
    elem = arr[i]
    result += (if isArray(elem) then flattenToString(elem) else elem)
    ++i
  result

jswIndexes = []
origCode = null

toSourceNodeWhenNeeded = (generated, node) ->
  if not sourceMap
    if isArray(generated)
      generated = flattenToString(generated)
    return generated
   
  if not node?
    if generated instanceof SourceNode
      return generated
    else
      node = {} 

  if not node.loc? 
    srcNode = new SourceNode null, null, sourceMap, generated, node.name or null
    srcStr = srcNode.toString()
    if node then node.jswSrc = srcStr
    if node and isStatement(node) and node.type isnt 'Program'
      if createSrcNodesFile
        fs.appendFileSync 'test/srcNodes.txt',  
          '\n##### ' + node.type + ': \n  ~' + 
            originalSourceCode[node.start...node.end] + 
            '~\n  ~' + srcStr + '~\n'
    return srcNode
    
  new SourceNode(node.loc.start.line, node.loc.start.column, 
                 (if sourceMap is true then node.loc.source or null else sourceMap), 
                 generated, node.name or null)
                 
noEmptySpace = ->
  (if (space) then space else " ")
  
join = (left, right) ->
  leftSource = undefined
  rightSource = undefined
  leftCharCode = undefined
  rightCharCode = undefined
  leftSource = toSourceNodeWhenNeeded(left).toString()
  if leftSource.length is 0
    return [ right ]  
  rightSource = toSourceNodeWhenNeeded(right).toString()
  if rightSource.length is 0
    return [ left ]  
  leftCharCode = leftSource.charCodeAt(leftSource.length - 1)
  rightCharCode = rightSource.charCodeAt(0)
  if (leftCharCode is 0x2B or leftCharCode is 0x2D) and leftCharCode is rightCharCode or 
      esutils.code.isIdentifierPartES5(leftCharCode) and esutils.code.isIdentifierPartES5(rightCharCode) or 
      leftCharCode is 0x2F and rightCharCode is 0x69
    return [ left, noEmptySpace(), right ]
  else 
    if esutils.code.isWhiteSpace(leftCharCode)     or 
       esutils.code.isLineTerminator(leftCharCode) or 
       esutils.code.isWhiteSpace(rightCharCode)    or 
       esutils.code.isLineTerminator(rightCharCode)
      return [ left, right ] 
       
  [ left, space, right ]

addIndent = (stmt) ->
  [ base, stmt ]

withIndent = (fn) ->
  previousBase = undefined
  previousBase = base
  base += indent
  fn base
  base = previousBase

calculateSpaces = (str) ->
  i = undefined
  i = str.length - 1
  while i >= 0
    break  if esutils.code.isLineTerminator(str.charCodeAt(i))
    --i
  (str.length - 1) - i

adjustMultilineComment = (value, specialBase) ->
  array = undefined
  i = undefined
  len = undefined
  line = undefined
  j = undefined
  spaces = undefined
  previousBase = undefined
  sn = undefined
  array = value.split(/\r\n|[\r\n]/)
  spaces = Number.MAX_VALUE
  i = 1
  len = array.length

  while i < len
    line = array[i]
    j = 0
    ++j  while j < line.length and esutils.code.isWhiteSpace(line.charCodeAt(j))
    spaces = j  if spaces > j
    ++i
  if typeof specialBase isnt "undefined"
    previousBase = base
    specialBase += " "  if array[1][spaces] is "*"
    base = specialBase
  else
    --spaces  if spaces & 1
    previousBase = base
  i = 1
  len = array.length

  while i < len
    sn = toSourceNodeWhenNeeded(addIndent(array[i].slice(spaces)))
    array[i] = (if sourceMap then sn.join("") else sn)
    ++i
  base = previousBase
  array.join "\n"
generateComment = (comment, specialBase) ->
  if comment.type is "Line"
    if endsWithLineTerminator(comment.value)
      return "//" + comment.value
    else
      result = "//" + comment.value
      result += "\n"  unless preserveBlankLines
      return result
  return adjustMultilineComment("/*" + comment.value + "*/", specialBase)  if extra.format.indent.adjustMultilineComment and (/[\n\r]/).test(comment.value)
  "/*" + comment.value + "*/"
  
addComments = (stmt, result) ->
  i = undefined
  len = undefined
  comment = undefined
  save = undefined
  tailingToStatement = undefined
  specialBase = undefined
  fragment = undefined
  extRange = undefined
  range = undefined
  prevRange = undefined
  prefix = undefined
  infix = undefined
  suffix = undefined
  count = undefined
  if stmt.leadingComments and stmt.leadingComments.length > 0
    save = result
    if preserveBlankLines
      comment = stmt.leadingComments[0]
      result = []
      extRange = comment.extendedRange
      range = comment.range
      prefix = sourceCode.substring(extRange[0], range[0])
      count = (prefix.match(/\n/g) or []).length
      if count > 0
        result.push stringRepeat("\n", count)
        result.push addIndent(generateComment(comment))
      else
        result.push prefix
        result.push generateComment(comment)
      prevRange = range
      i = 1
      len = stmt.leadingComments.length

      while i < len
        comment = stmt.leadingComments[i]
        range = comment.range
        infix = sourceCode.substring(prevRange[1], range[0])
        count = (infix.match(/\n/g) or []).length
        result.push stringRepeat("\n", count)
        result.push addIndent(generateComment(comment))
        prevRange = range
        i++
      suffix = sourceCode.substring(range[1], extRange[1])
      count = (suffix.match(/\n/g) or []).length
      result.push stringRepeat("\n", count)
    else
      comment = stmt.leadingComments[0]
      result = []
      result.push "\n"  if safeConcatenation and stmt.type is Syntax.Program and stmt.body.length is 0
      result.push generateComment(comment)
      result.push "\n"  unless endsWithLineTerminator(toSourceNodeWhenNeeded(result).toString())
      i = 1
      len = stmt.leadingComments.length

      while i < len
        comment = stmt.leadingComments[i]
        fragment = [ generateComment(comment) ]
        fragment.push "\n"  unless endsWithLineTerminator(toSourceNodeWhenNeeded(fragment).toString())
        result.push addIndent(fragment)
        ++i
    result.push addIndent(save)
  if stmt.trailingComments
    if preserveBlankLines
      comment = stmt.trailingComments[0]
      extRange = comment.extendedRange
      range = comment.range
      prefix = sourceCode.substring(extRange[0], range[0])
      count = (prefix.match(/\n/g) or []).length
      if count > 0
        result.push stringRepeat("\n", count)
        result.push addIndent(generateComment(comment))
      else
        result.push prefix
        result.push generateComment(comment)
    else
      tailingToStatement = not endsWithLineTerminator(toSourceNodeWhenNeeded(result).toString())
      specialBase = stringRepeat(" ", calculateSpaces(toSourceNodeWhenNeeded([ base, result, indent ]).toString()))
      i = 0
      len = stmt.trailingComments.length

      while i < len
        comment = stmt.trailingComments[i]
        if tailingToStatement
          if i is 0
            result = [ result, indent ]
          else
            result = [ result, specialBase ]
          result.push generateComment(comment, specialBase)
        else
          result = [ result, addIndent(generateComment(comment)) ]
        result = [ result, "\n" ]  if i isnt len - 1 and not endsWithLineTerminator(toSourceNodeWhenNeeded(result).toString())
        ++i
  result
generateBlankLines = (start, end, result) ->
  j = undefined
  newlineCount = 0
  j = start
  while j < end
    newlineCount++  if sourceCode[j] is "\n"
    j++
  j = 1
  while j < newlineCount
    result.push newline
    j++
parenthesize = (text, current, should) ->
  return [ "(", text, ")" ]  if current < should
  text
generateVerbatimString = (string) ->
  i = undefined
  iz = undefined
  result = undefined
  result = string.split(/\r\n|\n/)
  i = 1
  iz = result.length

  while i < iz
    result[i] = newline + base + result[i]
    i++
  result
  
generateVerbatim = (expr, precedence) ->
  verbatim = undefined
  result = undefined
  prec = undefined
  verbatim = expr[extra.verbatim]
  if typeof verbatim is "string"
    result = parenthesize(generateVerbatimString(verbatim), Precedence.Sequence, precedence)
  else
    result = generateVerbatimString(verbatim.content)
    prec = (if (verbatim.precedence?) then verbatim.precedence else Precedence.Sequence)
    result = parenthesize(result, prec, precedence)
  toSourceNodeWhenNeeded result, expr
  
CodeGenerator = ->
  
generateIdentifier = (node) ->
  toSourceNodeWhenNeeded node.name, node
  
generateAsyncPrefix = (node, spaceRequired) ->
  (if node.async then "async" + (if spaceRequired then noEmptySpace() else space) else "")
generateStarSuffix = (node) ->
  isGenerator = node.generator and not extra.moz.starlessGenerator
  (if isGenerator then "*" + space else "")
generateMethodPrefix = (prop) ->
  func = prop.value
  if func.async
    generateAsyncPrefix func, not prop.computed
  else
    (if generateStarSuffix(func) then "*" else "")
    
##### TOP-LEVEL START GENERATION #####
generateInternal = (node) ->
  codegen = undefined
  codegen = new CodeGenerator()
  if isStatement(node)
    return codegen.generateStatement(node, S_TFFF)  
  if isExpression(node)
    return codegen.generateExpression(node, Precedence.Sequence, E_TTT)  
  throw new Error("Unknown node type: " + node.type)
   
##### MAIN ENTRY POINT #####
generate = (node, options) ->
  rimraf.sync 'test/srcNodes.txt'
  defaultOptions = getDefaultOptions()
  result = undefined
  pair = undefined
  if options?
    if typeof options.indent is "string"
      defaultOptions.format.indent.style = options.indent
    if typeof options.base is "number"  
      defaultOptions.format.indent.base = options.base  
    options = updateDeeply(defaultOptions, options)
    indent = options.format.indent.style
    if typeof options.base is "string"
      base = options.base
    else
      base = stringRepeat(indent, options.format.indent.base)
  else
    options = defaultOptions
    indent = options.format.indent.style
    base = stringRepeat(indent, options.format.indent.base)
  json = options.format.json
  renumber = options.format.renumber
  hexadecimal = (if json then false else options.format.hexadecimal)
  quotes = (if json then "double" else options.format.quotes)
  escapeless = options.format.escapeless
  newline = options.format.newline
  space = options.format.space
  if options.format.compact
    newline = space = indent = base = ""  
  parentheses = options.format.parentheses
  semicolons = options.format.semicolons
  safeConcatenation = options.format.safeConcatenation
  directive = options.directive
  parse = (if json then null else options.parse)
  sourceMap = options.sourceMap
  sourceCode = options.sourceCode
  preserveBlankLines = options.format.preserveBlankLines and sourceCode isnt null
  extra = options
  originalSourceCode = options.file

  if sourceMap
    if not exports.browser
      SourceNode = require("source-map").SourceNode
    else
      SourceNode = global.sourceMap.SourceNode
      
  result = generateInternal(node)
  
  if not sourceMap
    pair =
      code: result.toString()
      map: null
    return (if options.sourceMapWithCode then pair else pair.code)
  
  
  fs.writeFileSync 'test/jswIndexes.json', JSON.stringify jswIndexes
    
  pair = result.toStringWithSourceMap(
    file: options.file
    sourceRoot: options.sourceMapRoot
  )
  if options.sourceContent
    pair.map.setSourceContent options.sourceMap, options.sourceContent
  if options.sourceMapWithCode  
    return pair  
    
  pair.map.toString()

    
CodeGenerator::maybeBlock = (stmt, flags) ->
  result = undefined
  noLeadingComment = undefined
  that = this
  noLeadingComment = not extra.comment or not stmt.leadingComments
  if stmt.type is Syntax.BlockStatement and noLeadingComment
    return [ space, @generateStatement(stmt, flags) ]
  if stmt.type is Syntax.EmptyStatement and noLeadingComment  
    return ""  #  removed ;
  withIndent ->
    result = [ newline, addIndent(that.generateStatement(stmt, flags)) ]

  result

CodeGenerator::maybeBlockSuffix = (stmt, result) ->
  ends = endsWithLineTerminator(toSourceNodeWhenNeeded(result).toString())
  return [ result, space ]  if stmt.type is Syntax.BlockStatement and (not extra.comment or not stmt.leadingComments) and not ends
  return [ result, base ]  if ends
  [ result, newline, base ]

CodeGenerator::generatePattern = (node, precedence, flags) ->
  return generateIdentifier(node)  if node.type is Syntax.Identifier
  @generateExpression node, precedence, flags

CodeGenerator::generateFunctionParams = (node) ->
  i = undefined
  iz = undefined
  result = undefined
  hasDefault = undefined
  hasDefault = false
  if node.type is Syntax.ArrowFunctionExpression and not node.rest and (not node.defaults or node.defaults.length is 0) and node.params.length is 1 and node.params[0].type is Syntax.Identifier
    result = [ generateAsyncPrefix(node, true), generateIdentifier(node.params[0]) ]
  else
    result = (if node.type is Syntax.ArrowFunctionExpression then [ generateAsyncPrefix(node, false) ] else [])
    result.push "("
    hasDefault = true  if node.defaults
    i = 0
    iz = node.params.length

    while i < iz
      if hasDefault and node.defaults[i]
        result.push @generateAssignment(node.params[i], node.defaults[i], "=", Precedence.Assignment, E_TTT)
      else
        result.push @generatePattern(node.params[i], Precedence.Assignment, E_TTT)
      result.push "," + space  if i + 1 < iz
      ++i
    if node.rest
      result.push "," + space  if node.params.length
      result.push "..."
      result.push generateIdentifier(node.rest)
    result.push ")"
  result

CodeGenerator::generateFunctionBody = (node) ->
  result = undefined
  expr = undefined
  result = @generateFunctionParams(node)
  if node.type is Syntax.ArrowFunctionExpression
    result.push space
    result.push "=>"
  if node.expression
    result.push space
    expr = @generateExpression(node.body, Precedence.Assignment, E_TTT)
    expr = [ "(", expr, ")" ]  if expr.toString().charAt(0) is "{"
    result.push expr
  else
    result.push @maybeBlock(node.body, S_TTFF)
  result

CodeGenerator::generateIterationForStatement = (operator, stmt, flags) ->
  result = [ "for" + space + "(" ]
  that = this
  withIndent ->
    if stmt.left.type is Syntax.VariableDeclaration
      withIndent ->
        result.push stmt.left.kind + noEmptySpace()
        result.push that.generateStatement(stmt.left.declarations[0], S_FFFF)
    else
      result.push that.generateExpression(stmt.left, Precedence.Call, E_TTT)
    result = join(result, operator)
    result = [ join(result, that.generateExpression(stmt.right, Precedence.Sequence, E_TTT)), ")" ]

  result.push @maybeBlock(stmt.body, flags)
  result

CodeGenerator::generatePropertyKey = (expr, computed) ->
  result = []
  result.push "["  if computed
  result.push @generateExpression(expr, Precedence.Sequence, E_TTT)
  result.push "]"  if computed
  result

CodeGenerator::generateAssignment = (left, right, operator, precedence, flags) ->
  if Precedence.Assignment < precedence
    flags |= F_ALLOW_IN  
  parenthesize [ @generateExpression(left, Precedence.Call, flags), 
                 space + operator + space, 
                 @generateExpression(right, Precedence.Assignment, flags) ], 
               Precedence.Assignment, 
               precedence

CodeGenerator::semicolon = (flags) ->
  if not semicolons and flags & F_SEMICOLON_OPT
    return ""  
  ""  #  removed ;
  
  
CodeGenerator.Statement =

################ output block { } ##############
  BlockStatement: (stmt, flags) ->
    range = undefined
    content = undefined
    result = [ "", newline ] #  removed {
    that = this
    withIndent ->
      if stmt.body.length is 0 and preserveBlankLines
        range = stmt.range
        if range[1] - range[0] > 2
          content = sourceCode.substring(range[0] + 1, range[1] - 1)
          if content[0] is "\n"
            result = [ "" ]   #  removed {
          result.push content
      i = undefined
      iz = undefined
      fragment = undefined
      bodyFlags = undefined
      bodyFlags = S_TFFF
      if flags & F_FUNC_BODY
        bodyFlags |= F_DIRECTIVE_CTX  
      i = 0
      iz = stmt.body.length
 
      while i < iz
        if preserveBlankLines
          if i is 0
            if stmt.body[0].leadingComments
              range = stmt.body[0].leadingComments[0].extendedRange
              content = sourceCode.substring(range[0], range[1])
              if content[0] is "\n"
                result = [ "" ] #  removed {
            if not stmt.body[0].leadingComments
              generateBlankLines stmt.range[0], stmt.body[0].range[0], result
          if not stmt.body[i - 1].trailingComments and not stmt.body[i].leadingComments  
            if i > 0    
              generateBlankLines stmt.body[i - 1].range[1], stmt.body[i].range[0], result
        if i is iz - 1  
          bodyFlags |= F_SEMICOLON_OPT  
        if stmt.body[i].leadingComments and preserveBlankLines
          fragment = that.generateStatement(stmt.body[i], bodyFlags)
        else
          fragment = addIndent(that.generateStatement(stmt.body[i], bodyFlags))
        result.push fragment
        if not endsWithLineTerminator(toSourceNodeWhenNeeded(fragment).toString())
          if preserveBlankLines and i < iz - 1
            if not stmt.body[i + 1].leadingComments
              result.push newline 
          else
            result.push newline
        if preserveBlankLines and i is iz - 1 and not stmt.body[i].trailingComments  
          generateBlankLines stmt.body[i].range[1], stmt.range[1], result  
        ++i

    result.push addIndent("") #  removed }
    result


  BreakStatement: (stmt, flags) ->
    return "break " + stmt.label.name + @semicolon(flags)  if stmt.label
    "break" + @semicolon(flags)

  ContinueStatement: (stmt, flags) ->
    return "continue " + stmt.label.name + @semicolon(flags)  if stmt.label
    "continue" + @semicolon(flags)

  ClassBody: (stmt, flags) ->
    result = [ "{", newline ]
    that = this
    withIndent (indent) ->
      i = undefined
      iz = undefined
      i = 0
      iz = stmt.body.length

      while i < iz
        result.push indent
        result.push that.generateExpression(stmt.body[i], Precedence.Sequence, E_TTT)
        result.push newline  if i + 1 < iz
        ++i

    result.push newline  unless endsWithLineTerminator(toSourceNodeWhenNeeded(result).toString())
    result.push base
    result.push "}"
    result

  ClassDeclaration: (stmt, flags) ->
    result = undefined
    fragment = undefined
    result = [ "class " + stmt.id.name ]
    if stmt.superClass
      fragment = join("extends", @generateExpression(stmt.superClass, Precedence.Assignment, E_TTT))
      result = join(result, fragment)
    result.push space
    result.push @generateStatement(stmt.body, S_TFFT)
    result

  DirectiveStatement: (stmt, flags) ->
    return stmt.raw + @semicolon(flags)  if extra.raw and stmt.raw
    escapeDirective(stmt.directive) + @semicolon(flags)

  DoWhileStatement: (stmt, flags) ->
    result = join("do", @maybeBlock(stmt.body, S_TFFF))
    result = @maybeBlockSuffix(stmt.body, result)
    join result, [ "while" + space + "(", @generateExpression(stmt.test, Precedence.Sequence, E_TTT), ")" + @semicolon(flags) ]

  CatchClause: (stmt, flags) ->
    result = undefined
    that = this
    withIndent ->
      guard = undefined
      result = [ "catch" + space + "(", that.generateExpression(stmt.param, Precedence.Sequence, E_TTT), ")" ]
      if stmt.guard
        guard = that.generateExpression(stmt.guard, Precedence.Sequence, E_TTT)
        result.splice 2, 0, " if ", guard

    result.push @maybeBlock(stmt.body, S_TFFF)
    result

  DebuggerStatement: (stmt, flags) ->
    "debugger" + @semicolon(flags)

  EmptyStatement: (stmt, flags) ->
    "" #  removed ;

  ExportDeclaration: (stmt, flags) ->
    result = [ "export" ]
    bodyFlags = undefined
    that = this
    bodyFlags = (if (flags & F_SEMICOLON_OPT) then S_TFFT else S_TFFF)
    if stmt["default"]
      result = join(result, "default")
      if isStatement(stmt.declaration)
        result = join(result, @generateStatement(stmt.declaration, bodyFlags))
      else
        result = join(result, @generateExpression(stmt.declaration, Precedence.Assignment, E_TTT) + @semicolon(flags))
      return result
    return join(result, @generateStatement(stmt.declaration, bodyFlags))  if stmt.declaration
    if stmt.specifiers
      if stmt.specifiers.length is 0
        result = join(result, "{" + space + "}")
      else if stmt.specifiers[0].type is Syntax.ExportBatchSpecifier
        result = join(result, @generateExpression(stmt.specifiers[0], Precedence.Sequence, E_TTT))
      else
        result = join(result, "{")
        withIndent (indent) ->
          i = undefined
          iz = undefined
          result.push newline
          i = 0
          iz = stmt.specifiers.length

          while i < iz
            result.push indent
            result.push that.generateExpression(stmt.specifiers[i], Precedence.Sequence, E_TTT)
            result.push "," + newline  if i + 1 < iz
            ++i

        result.push newline  unless endsWithLineTerminator(toSourceNodeWhenNeeded(result).toString())
        result.push base + "}"
      if stmt.source
        result = join(result, [ "from" + space, @generateExpression(stmt.source, Precedence.Sequence, E_TTT), @semicolon(flags) ])
      else
        result.push @semicolon(flags)
    result

  ExportDefaultDeclaration: (stmt, flags) ->
    stmt.default = true
    @ExportDeclaration stmt, flags

  ExportNamedDeclaration: (stmt, flags) ->
    @ExportDeclaration stmt, flags

  ExpressionStatement: (stmt, flags) ->
    isClassPrefixed = (fragment) ->
      code = undefined
      return false  if fragment.slice(0, 5) isnt "class"
      code = fragment.charCodeAt(5)
      code is 0x7B or esutils.code.isWhiteSpace(code) or esutils.code.isLineTerminator(code)
    isFunctionPrefixed = (fragment) ->
      code = undefined
      return false  if fragment.slice(0, 8) isnt "function"
      code = fragment.charCodeAt(8)
      code is 0x28 or esutils.code.isWhiteSpace(code) or code is 0x2A or esutils.code.isLineTerminator(code)
    isAsyncPrefixed = (fragment) ->
      code = undefined
      i = undefined
      iz = undefined
      return false  if fragment.slice(0, 5) isnt "async"
      return false  unless esutils.code.isWhiteSpace(fragment.charCodeAt(5))
      i = 6
      iz = fragment.length
 
      while i < iz
        break  unless esutils.code.isWhiteSpace(fragment.charCodeAt(i))
        ++i
      return false  if i is iz
      return false  if fragment.slice(i, i + 8) isnt "function"
      code = fragment.charCodeAt(i + 8)
      code is 0x28 or esutils.code.isWhiteSpace(code) or code is 0x2A or esutils.code.isLineTerminator(code)
    result = undefined
    fragment = undefined
    result = [ @generateExpression(stmt.expression, Precedence.Sequence, E_TTT) ]
    fragment = toSourceNodeWhenNeeded(result).toString()
    if fragment.charCodeAt(0) is 0x7B or 
       isClassPrefixed(fragment) or 
       isFunctionPrefixed(fragment) or 
       isAsyncPrefixed(fragment) or 
       (directive and (flags & F_DIRECTIVE_CTX) and 
                      stmt.expression.type is Syntax.Literal and 
                      typeof stmt.expression.value is "string")
      result = [ "(", result, ")" + @semicolon(flags) ]
    else
      result.push @semicolon(flags)
    result

  ImportDeclaration: (stmt, flags) ->
    result = undefined
    cursor = undefined
    that = this
    return [ "import", space, @generateExpression(stmt.source, Precedence.Sequence, E_TTT), @semicolon(flags) ]  if stmt.specifiers.length is 0
    result = [ "import" ]
    cursor = 0
    if stmt.specifiers[cursor].type is Syntax.ImportDefaultSpecifier
      result = join(result, [ @generateExpression(stmt.specifiers[cursor], Precedence.Sequence, E_TTT) ])
      ++cursor
    if stmt.specifiers[cursor]
      result.push ","  if cursor isnt 0
      if stmt.specifiers[cursor].type is Syntax.ImportNamespaceSpecifier
        result = join(result, [ space, @generateExpression(stmt.specifiers[cursor], 
                      Precedence.Sequence, E_TTT) ])
      else
        result.push space + "{"
        if (stmt.specifiers.length - cursor) is 1
          result.push space
          result.push @generateExpression(stmt.specifiers[cursor], 
                                          Precedence.Sequence, E_TTT)
          result.push space + "}" + space
        else
          withIndent (indent) ->
            i = undefined
            iz = undefined
            result.push newline
            i = cursor
            iz = stmt.specifiers.length

            while i < iz
              result.push indent
              result.push that.generateExpression(stmt.specifiers[i], Precedence.Sequence, E_TTT)
              result.push "," + newline  if i + 1 < iz
              ++i

          result.push newline  unless endsWithLineTerminator(toSourceNodeWhenNeeded(result).toString())
          result.push base + "}" + space
    result = join(result, [ "from" + space, @generateExpression(stmt.source, Precedence.Sequence, E_TTT), @semicolon(flags) ])
    result
 
  VariableDeclarator: (stmt, flags) ->
    itemFlags = (if (flags & F_ALLOW_IN) then E_TTT else E_FTT)
    return [ @generateExpression(stmt.id, Precedence.Assignment, itemFlags), space, "=", space, @generateExpression(stmt.init, Precedence.Assignment, itemFlags) ]  if stmt.init
    @generatePattern stmt.id, Precedence.Assignment, itemFlags

  VariableDeclaration: (stmt, flags) ->
    block = ->
      node = stmt.declarations[0]
      if extra.comment and node.leadingComments
        result.push "\n"
        result.push addIndent(that.generateStatement(node, bodyFlags))
      else
        result.push noEmptySpace()
        result.push that.generateStatement(node, bodyFlags)
      i = 1
      iz = stmt.declarations.length

      while i < iz
        node = stmt.declarations[i]
        if extra.comment and node.leadingComments
          result.push "," + newline
          result.push addIndent(that.generateStatement(node, bodyFlags))
        else
          result.push "," + space
          result.push that.generateStatement(node, bodyFlags)
        ++i
    result = undefined
    i = undefined
    iz = undefined
    node = undefined
    bodyFlags = undefined
    that = this
    result = [ stmt.kind ]
    bodyFlags = (if (flags & F_ALLOW_IN) then S_TFFF else S_FFFF)
    if stmt.declarations.length > 1
      withIndent block
    else
      block()
    result.push @semicolon(flags)
    result

  ThrowStatement: (stmt, flags) ->
    [ join("throw", @generateExpression(stmt.argument, Precedence.Sequence, E_TTT)), @semicolon(flags) ]

  TryStatement: (stmt, flags) ->
    result = undefined
    i = undefined
    iz = undefined
    guardedHandlers = undefined
    result = [ "try", @maybeBlock(stmt.block, S_TFFF) ]
    result = @maybeBlockSuffix(stmt.block, result)
    if stmt.handlers
      i = 0
      iz = stmt.handlers.length

      while i < iz
        result = join(result, @generateStatement(stmt.handlers[i], S_TFFF))
        result = @maybeBlockSuffix(stmt.handlers[i].body, result)  if stmt.finalizer or i + 1 isnt iz
        ++i
    else
      guardedHandlers = stmt.guardedHandlers or []
      i = 0
      iz = guardedHandlers.length

      while i < iz
        result = join(result, @generateStatement(guardedHandlers[i], S_TFFF))
        result = @maybeBlockSuffix(guardedHandlers[i].body, result)  if stmt.finalizer or i + 1 isnt iz
        ++i
      if stmt.handler
        if isArray(stmt.handler)
          i = 0
          iz = stmt.handler.length

          while i < iz
            result = join(result, @generateStatement(stmt.handler[i], S_TFFF))
            result = @maybeBlockSuffix(stmt.handler[i].body, result)  if stmt.finalizer or i + 1 isnt iz
            ++i
        else
          result = join(result, @generateStatement(stmt.handler, S_TFFF))
          result = @maybeBlockSuffix(stmt.handler.body, result)  if stmt.finalizer
    result = join(result, [ "finally", @maybeBlock(stmt.finalizer, S_TFFF) ])  if stmt.finalizer
    result

  SwitchStatement: (stmt, flags) ->
    result = undefined
    fragment = undefined
    i = undefined
    iz = undefined
    bodyFlags = undefined
    that = this
    withIndent ->
      result = [ "switch" + space + "(", that.generateExpression(stmt.discriminant, Precedence.Sequence, E_TTT), ")" + space + "{" + newline ]

    if stmt.cases
      bodyFlags = S_TFFF
      i = 0
      iz = stmt.cases.length

      while i < iz
        bodyFlags |= F_SEMICOLON_OPT  if i is iz - 1
        fragment = addIndent(@generateStatement(stmt.cases[i], bodyFlags))
        result.push fragment
        result.push newline  unless endsWithLineTerminator(toSourceNodeWhenNeeded(fragment).toString())
        ++i
    result.push addIndent("}")
    result

  SwitchCase: (stmt, flags) ->
    result = undefined
    fragment = undefined
    i = undefined
    iz = undefined
    bodyFlags = undefined
    that = this
    withIndent ->
      if stmt.test
        result = [ join("case", that.generateExpression(stmt.test, Precedence.Sequence, E_TTT)), ":" ]
      else
        result = [ "default:" ]
      i = 0
      iz = stmt.consequent.length
      if iz and stmt.consequent[0].type is Syntax.BlockStatement
        fragment = that.maybeBlock(stmt.consequent[0], S_TFFF)
        result.push fragment
        i = 1
      result.push newline  if i isnt iz and not endsWithLineTerminator(toSourceNodeWhenNeeded(result).toString())
      bodyFlags = S_TFFF
      while i < iz
        bodyFlags |= F_SEMICOLON_OPT  if i is iz - 1 and flags & F_SEMICOLON_OPT
        fragment = addIndent(that.generateStatement(stmt.consequent[i], bodyFlags))
        result.push fragment
        result.push newline  if i + 1 isnt iz and not endsWithLineTerminator(toSourceNodeWhenNeeded(fragment).toString())
        ++i

    result

  IfStatement: (stmt, flags) ->
    result = undefined
    bodyFlags = undefined
    semicolonOptional = undefined
    that = this
    withIndent ->
      result = [ "if" + space + "(", that.generateExpression(stmt.test, Precedence.Sequence, E_TTT), ")" ]

    semicolonOptional = flags & F_SEMICOLON_OPT
    bodyFlags = S_TFFF
    bodyFlags |= F_SEMICOLON_OPT  if semicolonOptional
    if stmt.alternate
      result.push @maybeBlock(stmt.consequent, S_TFFF)
      result = @maybeBlockSuffix(stmt.consequent, result)
      if stmt.alternate.type is Syntax.IfStatement
        result = join(result, [ "else ", @generateStatement(stmt.alternate, bodyFlags) ])
      else
        result = join(result, join("else", @maybeBlock(stmt.alternate, bodyFlags)))
    else
      result.push @maybeBlock(stmt.consequent, bodyFlags)
    result

  ForStatement: (stmt, flags) ->
    result = undefined
    that = this
    withIndent ->
      result = [ "for" + space + "(" ]
      if stmt.init
        if stmt.init.type is Syntax.VariableDeclaration
          result.push that.generateStatement(stmt.init, S_FFFF)
        else
          result.push that.generateExpression(stmt.init, Precedence.Sequence, E_FTT)
          result.push ";"
      else
        result.push ";"
      if stmt.test
        result.push space
        result.push that.generateExpression(stmt.test, Precedence.Sequence, E_TTT)
        result.push ";"
      else
        result.push ";"
      if stmt.update
        result.push space
        result.push that.generateExpression(stmt.update, 
                                            Precedence.Sequence, E_TTT)
        result.push ")"
      else
        result.push ")"

    result.push @maybeBlock(stmt.body, 
      (if flags & F_SEMICOLON_OPT then S_TFFT else S_TFFF))
    result

  ForInStatement: (stmt, flags) ->
    @generateIterationForStatement "in", stmt, 
      (if flags & F_SEMICOLON_OPT then S_TFFT else S_TFFF)

  ForOfStatement: (stmt, flags) ->
    @generateIterationForStatement "of", stmt, 
      (if flags & F_SEMICOLON_OPT then S_TFFT else S_TFFF)

  LabeledStatement: (stmt, flags) ->
    [ stmt.label.name + ":", @maybeBlock(stmt.body, 
      (if flags & F_SEMICOLON_OPT then S_TFFT else S_TFFF)) ]

  Program: (stmt, flags) ->
    result = undefined
    fragment = undefined 
    i = undefined
    iz = undefined
    bodyFlags = undefined
    iz = stmt.body.length
    result = [ (if safeConcatenation and iz > 0 then "\n" else "") ]
    bodyFlags = S_TFTF
    i = 0
    while i < iz
      if not safeConcatenation and i is iz - 1
        bodyFlags |= F_SEMICOLON_OPT  
      if preserveBlankLines
        generateBlankLines stmt.range[0], stmt.body[i].range[0], result  unless stmt.body[0].leadingComments  if i is 0
        generateBlankLines stmt.body[i - 1].range[1], stmt.body[i].range[0], result  if not stmt.body[i - 1].trailingComments and not stmt.body[i].leadingComments  if i > 0
      fragment = addIndent(@generateStatement(stmt.body[i], bodyFlags))
      result.push fragment
      if i + 1 < iz and not endsWithLineTerminator(toSourceNodeWhenNeeded(fragment).toString())
        if preserveBlankLines
          result.push newline  unless stmt.body[i + 1].leadingComments
        else
          result.push newline
      if preserveBlankLines and i is iz - 1 and
          not stmt.body[i].trailingComments  
        generateBlankLines stmt.body[i].range[1], stmt.range[1], result  
      ++i
    result

  FunctionDeclaration: (stmt, flags) ->
    [ generateAsyncPrefix(stmt, true), "->", generateStarSuffix(stmt) or noEmptySpace(), generateIdentifier(stmt.id), @generateFunctionBody(stmt) ]

  ReturnStatement: (stmt, flags) ->
    return [ join("return", @generateExpression(stmt.argument, Precedence.Sequence, E_TTT)), @semicolon(flags) ]  if stmt.argument
    [ "return" + @semicolon(flags) ]

  WhileStatement: (stmt, flags) ->
    result = undefined
    that = this
    withIndent ->
      result = [ "while" + space + "(", that.generateExpression(stmt.test, Precedence.Sequence, E_TTT), ")" ]

    result.push @maybeBlock(stmt.body, (if flags & F_SEMICOLON_OPT then S_TFFT else S_TFFF))
    result

  WithStatement: (stmt, flags) ->
    result = undefined
    that = this
    withIndent ->
      result = [ "with" + space + "(", that.generateExpression(stmt.object, Precedence.Sequence, E_TTT), ")" ]

    result.push @maybeBlock(stmt.body, (if flags & F_SEMICOLON_OPT then S_TFFT else S_TFFF))
    result

merge CodeGenerator::, CodeGenerator.Statement

CodeGenerator.Expression =
  
  SequenceExpression: (expr, precedence, flags) ->
    result = undefined
    i = undefined
    iz = undefined
    flags |= F_ALLOW_IN  if Precedence.Sequence < precedence
    result = []
    i = 0
    iz = expr.expressions.length

    while i < iz
      result.push @generateExpression(expr.expressions[i], Precedence.Assignment, flags)
      result.push "," + space  if i + 1 < iz
      ++i
    parenthesize result, Precedence.Sequence, precedence

  AssignmentExpression: (expr, precedence, flags) ->
    @generateAssignment expr.left, expr.right, expr.operator, precedence, flags

  ArrowFunctionExpression: (expr, precedence, flags) ->
    parenthesize @generateFunctionBody(expr), Precedence.ArrowFunction, precedence

  ConditionalExpression: (expr, precedence, flags) ->
    flags |= F_ALLOW_IN  if Precedence.Conditional < precedence
    parenthesize [ @generateExpression(expr.test, Precedence.LogicalOR, flags), space + "?" + space, @generateExpression(expr.consequent, Precedence.Assignment, flags), space + ":" + space, @generateExpression(expr.alternate, Precedence.Assignment, flags) ], Precedence.Conditional, precedence

  LogicalExpression: (expr, precedence, flags) ->
    @BinaryExpression expr, precedence, flags

  BinaryExpression: (expr, precedence, flags) ->
    result = undefined
    currentPrecedence = undefined
    fragment = undefined
    leftSource = undefined
    currentPrecedence = BinaryPrecedence[expr.operator]
    flags |= F_ALLOW_IN  if currentPrecedence < precedence
    fragment = @generateExpression(expr.left, currentPrecedence, flags)
    leftSource = fragment.toString()
    if leftSource.charCodeAt(leftSource.length - 1) is 0x2F and esutils.code.isIdentifierPartES5(expr.operator.charCodeAt(0))
      result = [ fragment, noEmptySpace(), expr.operator ]
    else
      result = join(fragment, expr.operator)
    fragment = @generateExpression(expr.right, currentPrecedence + 1, flags)
    if expr.operator is "/" and fragment.toString().charAt(0) is "/" or expr.operator.slice(-1) is "<" and fragment.toString().slice(0, 3) is "!--"
      result.push noEmptySpace()
      result.push fragment
    else
      result = join(result, fragment)
    return [ "(", result, ")" ]  if expr.operator is "in" and not (flags & F_ALLOW_IN)
    parenthesize result, currentPrecedence, precedence

  CallExpression: (expr, precedence, flags) ->
    result = undefined
    i = undefined
    iz = undefined
    result = [ @generateExpression(expr.callee, Precedence.Call, E_TTF) ]
    result.push "("
    i = 0
    iz = expr["arguments"].length

    while i < iz
      result.push @generateExpression(expr["arguments"][i], Precedence.Assignment, E_TTT)
      result.push "," + space  if i + 1 < iz
      ++i
    result.push ")"
    return [ "(", result, ")" ]  unless flags & F_ALLOW_CALL
    parenthesize result, Precedence.Call, precedence

  NewExpression: (expr, precedence, flags) ->
    result = undefined
    length = undefined
    i = undefined
    iz = undefined
    itemFlags = undefined
    length = expr["arguments"].length
    itemFlags = (if (flags & F_ALLOW_UNPARATH_NEW and not parentheses and length is 0) then E_TFT else E_TFF)
    result = join("new", @generateExpression(expr.callee, Precedence.New, itemFlags))
    if not (flags & F_ALLOW_UNPARATH_NEW) or parentheses or length > 0
      result.push "("
      i = 0
      iz = length

      while i < iz
        result.push @generateExpression(expr["arguments"][i], Precedence.Assignment, E_TTT)
        result.push "," + space  if i + 1 < iz
        ++i
      result.push ")"
    parenthesize result, Precedence.New, precedence

  MemberExpression: (expr, precedence, flags) ->
    result = undefined
    fragment = undefined
    result = [ @generateExpression(expr.object, Precedence.Call, (if (flags & F_ALLOW_CALL) then E_TTF else E_TFF)) ]
    if expr.computed
      result.push "["
      result.push @generateExpression(expr.property, Precedence.Sequence, (if flags & F_ALLOW_CALL then E_TTT else E_TFT))
      result.push "]"
    else
      if expr.object.type is Syntax.Literal and typeof expr.object.value is "number"
        fragment = toSourceNodeWhenNeeded(result).toString()
        result.push "."  if fragment.indexOf(".") < 0 and not (/[eExX]/).test(fragment) and esutils.code.isDecimalDigit(fragment.charCodeAt(fragment.length - 1)) and not (fragment.length >= 2 and fragment.charCodeAt(0) is 48)
      result.push "."
      result.push generateIdentifier(expr.property)
    parenthesize result, Precedence.Member, precedence

  UnaryExpression: (expr, precedence, flags) ->
    result = undefined
    fragment = undefined
    rightCharCode = undefined
    leftSource = undefined
    leftCharCode = undefined
    fragment = @generateExpression(expr.argument, Precedence.Unary, E_TTT)
    if space is ""
      result = join(expr.operator, fragment)
    else
      result = [ expr.operator ]
      if expr.operator.length > 2
        result = join(result, fragment)
      else
        leftSource = toSourceNodeWhenNeeded(result).toString()
        leftCharCode = leftSource.charCodeAt(leftSource.length - 1)
        rightCharCode = fragment.toString().charCodeAt(0)
        if ((leftCharCode is 0x2B or leftCharCode is 0x2D) and leftCharCode is rightCharCode) or (esutils.code.isIdentifierPartES5(leftCharCode) and esutils.code.isIdentifierPartES5(rightCharCode))
          result.push noEmptySpace()
          result.push fragment
        else
          result.push fragment
    parenthesize result, Precedence.Unary, precedence

  YieldExpression: (expr, precedence, flags) ->
    result = undefined
    if expr.delegate
      result = "yield*"
    else
      result = "yield"
    result = join(result, @generateExpression(expr.argument, Precedence.Yield, E_TTT))  if expr.argument
    parenthesize result, Precedence.Yield, precedence

  AwaitExpression: (expr, precedence, flags) ->
    result = join((if expr.all then "await*" else "await"), @generateExpression(expr.argument, Precedence.Await, E_TTT))
    parenthesize result, Precedence.Await, precedence

  UpdateExpression: (expr, precedence, flags) ->
    return parenthesize([ expr.operator, @generateExpression(expr.argument, Precedence.Unary, E_TTT) ], Precedence.Unary, precedence)  if expr.prefix
    parenthesize [ @generateExpression(expr.argument, Precedence.Postfix, E_TTT), expr.operator ], Precedence.Postfix, precedence

  FunctionExpression: (expr, precedence, flags) ->
    result = [ generateAsyncPrefix(expr, true), "->" ]
    if expr.id
      result.push generateStarSuffix(expr) or noEmptySpace()
      result.push generateIdentifier(expr.id)
    else
      result.push generateStarSuffix(expr) or space
    result.push @generateFunctionBody(expr)
    result

  ExportBatchSpecifier: (expr, precedence, flags) ->
    "*"

  ArrayPattern: (expr, precedence, flags) ->
    @ArrayExpression expr, precedence, flags, true

  ArrayExpression: (expr, precedence, flags, isPattern) ->
    result = undefined
    multiline = undefined
    that = this
    return "[]"  unless expr.elements.length
    multiline = (if isPattern then false else expr.elements.length > 1)
    result = [ "[", (if multiline then newline else "") ]
    withIndent (indent) ->
      i = undefined
      iz = undefined
      i = 0
      iz = expr.elements.length

      while i < iz
        unless expr.elements[i]
          result.push indent  if multiline
          result.push ","  if i + 1 is iz
        else
          result.push (if multiline then indent else "")
          result.push that.generateExpression(expr.elements[i], Precedence.Assignment, E_TTT)
        result.push "," + (if multiline then newline else space)  if i + 1 < iz
        ++i

    result.push newline  if multiline and not endsWithLineTerminator(toSourceNodeWhenNeeded(result).toString())
    result.push (if multiline then base else "")
    result.push "]"
    result

  RestElement: (expr, precedence, flags) ->
    "..." + @generatePattern(expr.argument)

  ClassExpression: (expr, precedence, flags) ->
    result = undefined
    fragment = undefined
    result = [ "class" ]
    result = join(result, @generateExpression(expr.id, Precedence.Sequence, E_TTT))  if expr.id
    if expr.superClass
      fragment = join("extends", @generateExpression(expr.superClass, Precedence.Assignment, E_TTT))
      result = join(result, fragment)
    result.push space
    result.push @generateStatement(expr.body, S_TFFT)
    result

  MethodDefinition: (expr, precedence, flags) ->
    result = undefined
    fragment = undefined
    if expr["static"]
      result = [ "static" + space ]
    else
      result = []
    if expr.kind is "get" or expr.kind is "set"
      fragment = [ join(expr.kind, @generatePropertyKey(expr.key, expr.computed)), @generateFunctionBody(expr.value) ]
    else
      fragment = [ generateMethodPrefix(expr), @generatePropertyKey(expr.key, expr.computed), @generateFunctionBody(expr.value) ]
    join result, fragment

  Property: (expr, precedence, flags) ->
    return [ expr.kind, noEmptySpace(), @generatePropertyKey(expr.key, expr.computed), @generateFunctionBody(expr.value) ]  if expr.kind is "get" or expr.kind is "set"
    return @generatePropertyKey(expr.key, expr.computed)  if expr.shorthand
    return [ generateMethodPrefix(expr), @generatePropertyKey(expr.key, expr.computed), @generateFunctionBody(expr.value) ]  if expr.method
    [ @generatePropertyKey(expr.key, expr.computed), ":" + space, @generateExpression(expr.value, Precedence.Assignment, E_TTT) ]

  ObjectExpression: (expr, precedence, flags) ->
    multiline = undefined
    result = undefined
    fragment = undefined
    that = this
    return "{}"  unless expr.properties.length
    multiline = expr.properties.length > 1
    withIndent ->
      fragment = that.generateExpression(expr.properties[0], Precedence.Sequence, E_TTT)

    return [ "{", space, fragment, space, "}" ]  unless hasLineTerminator(toSourceNodeWhenNeeded(fragment).toString())  unless multiline
    withIndent (indent) ->
      i = undefined
      iz = undefined
      result = [ "{", newline, indent, fragment ]
      if multiline
        result.push "," + newline
        i = 1
        iz = expr.properties.length

        while i < iz
          result.push indent
          result.push that.generateExpression(expr.properties[i], Precedence.Sequence, E_TTT)
          result.push "," + newline  if i + 1 < iz
          ++i

    result.push newline  unless endsWithLineTerminator(toSourceNodeWhenNeeded(result).toString())
    result.push base
    result.push "}"
    result

  ObjectPattern: (expr, precedence, flags) ->
    result = undefined
    i = undefined
    iz = undefined
    multiline = undefined
    property = undefined
    that = this
    return "{}"  unless expr.properties.length
    multiline = false
    if expr.properties.length is 1
      property = expr.properties[0]
      multiline = true  if property.value.type isnt Syntax.Identifier
    else
      i = 0
      iz = expr.properties.length

      while i < iz
        property = expr.properties[i]
        unless property.shorthand
          multiline = true
          break
        ++i
    result = [ "{", (if multiline then newline else "") ]
    withIndent (indent) ->
      i = undefined
      iz = undefined
      i = 0
      iz = expr.properties.length

      while i < iz
        result.push (if multiline then indent else "")
        result.push that.generateExpression(expr.properties[i], Precedence.Sequence, E_TTT)
        result.push "," + (if multiline then newline else space)  if i + 1 < iz
        ++i

    result.push newline  if multiline and not endsWithLineTerminator(toSourceNodeWhenNeeded(result).toString())
    result.push (if multiline then base else "")
    result.push "}"
    result

  ThisExpression: (expr, precedence, flags) ->
    "this"

  Super: (expr, precedence, flags) ->
    "super"

  Identifier: (expr, precedence, flags) ->
    generateIdentifier expr

  ImportDefaultSpecifier: (expr, precedence, flags) ->
    generateIdentifier expr.id or expr.local

  ImportNamespaceSpecifier: (expr, precedence, flags) ->
    result = [ "*" ]
    id = expr.id or expr.local
    result.push space + "as" + noEmptySpace() + generateIdentifier(id)  if id
    result

  ImportSpecifier: (expr, precedence, flags) ->
    @ExportSpecifier expr, precedence, flags

  ExportSpecifier: (expr, precedence, flags) ->
    exported = (expr.id or expr.imported).name
    result = [ exported ]
    id = expr.name or expr.local
    result.push noEmptySpace() + "as" + noEmptySpace() + generateIdentifier(id)  if id and id.name isnt exported
    result

  Literal: (expr, precedence, flags) ->
    raw = undefined
    if expr.hasOwnProperty("raw") and parse and extra.raw
      try
        raw = parse(expr.raw).body[0].expression
        return expr.raw  if raw.value is expr.value  if raw.type is Syntax.Literal
    return "null"  if expr.value is null
    return escapeString(expr.value)  if typeof expr.value is "string"
    return generateNumber(expr.value)  if typeof expr.value is "number"
    return (if expr.value then "true" else "false")  if typeof expr.value is "boolean"
    generateRegExp expr.value

  GeneratorExpression: (expr, precedence, flags) ->
    @ComprehensionExpression expr, precedence, flags

  ComprehensionExpression: (expr, precedence, flags) ->
    result = undefined
    i = undefined
    iz = undefined
    fragment = undefined
    that = this
    result = (if (expr.type is Syntax.GeneratorExpression) then [ "(" ] else [ "[" ])
    if extra.moz.comprehensionExpressionStartsWithAssignment
      fragment = @generateExpression(expr.body, Precedence.Assignment, E_TTT)
      result.push fragment
    if expr.blocks
      withIndent ->
        i = 0
        iz = expr.blocks.length

        while i < iz
          fragment = that.generateExpression(expr.blocks[i], Precedence.Sequence, E_TTT)
          if i > 0 or extra.moz.comprehensionExpressionStartsWithAssignment
            result = join(result, fragment)
          else
            result.push fragment
          ++i
    if expr.filter
      result = join(result, "if" + space)
      fragment = @generateExpression(expr.filter, Precedence.Sequence, E_TTT)
      result = join(result, [ "(", fragment, ")" ])
    unless extra.moz.comprehensionExpressionStartsWithAssignment
      fragment = @generateExpression(expr.body, Precedence.Assignment, E_TTT)
      result = join(result, fragment)
    result.push (if (expr.type is Syntax.GeneratorExpression) then ")" else "]")
    result

  ComprehensionBlock: (expr, precedence, flags) ->
    fragment = undefined
    if expr.left.type is Syntax.VariableDeclaration
      fragment = [ expr.left.kind, noEmptySpace(), @generateStatement(expr.left.declarations[0], S_FFFF) ]
    else
      fragment = @generateExpression(expr.left, Precedence.Call, E_TTT)
    fragment = join(fragment, (if expr.of then "of" else "in"))
    fragment = join(fragment, @generateExpression(expr.right, Precedence.Sequence, E_TTT))
    [ "for" + space + "(", fragment, ")" ]

  SpreadElement: (expr, precedence, flags) ->
    [ "...", @generateExpression(expr.argument, Precedence.Assignment, E_TTT) ]

  TaggedTemplateExpression: (expr, precedence, flags) ->
    itemFlags = E_TTF
    itemFlags = E_TFF  unless flags & F_ALLOW_CALL
    result = [ @generateExpression(expr.tag, Precedence.Call, itemFlags), @generateExpression(expr.quasi, Precedence.Primary, E_FFT) ]
    parenthesize result, Precedence.TaggedTemplate, precedence

  TemplateElement: (expr, precedence, flags) ->
    expr.value.raw

  TemplateLiteral: (expr, precedence, flags) ->
    result = undefined
    i = undefined
    iz = undefined
    result = [ "`" ]
    i = 0
    iz = expr.quasis.length

    while i < iz
      result.push @generateExpression(expr.quasis[i], Precedence.Primary, E_TTT)
      if i + 1 < iz
        result.push "${" + space
        result.push @generateExpression(expr.expressions[i], Precedence.Sequence, E_TTT)
        result.push space + "}"
      ++i
    result.push "`"
    result

  ModuleSpecifier: (expr, precedence, flags) ->
    @Literal expr, precedence, flags

merge CodeGenerator::, CodeGenerator.Expression


CodeGenerator::generateExpression = (expr, precedence, flags) ->
  result = undefined
  type = undefined
  type = expr.type or Syntax.Property
  return generateVerbatim(expr, precedence)  if extra.verbatim and expr.hasOwnProperty(extra.verbatim)
  result = this[type](expr, precedence, flags)
  result = addComments(expr, result)  if extra.comment
  toSourceNodeWhenNeeded result, expr

jswIndexes = []
    
CodeGenerator::generateStatement = (stmt, flags) ->
  # jswIndex = 
  #   type:     stmt.type
  #   jsStart:  stmt.start
  #   jsEnd:    stmt.end
  #   jswStart: jswLen 
  # jswIndexes.push jswIndex
  
  result = undefined
  fragment = undefined
  result = this[stmt.type](stmt, flags)
  if extra.comment
    result = addComments(stmt, result)  
  fragment = toSourceNodeWhenNeeded(result).toString()
  
  # jswIndex.jswEnd = jswIndex.jswStart + fragment.length
  # 
  # if stmt.type is 'Program'
  #   log jswIndexes
  
  if stmt.type is Syntax.Program and not safeConcatenation and 
       newline is "" and fragment.charAt(fragment.length - 1) is "\n"
    result = (if sourceMap then toSourceNodeWhenNeeded(result).replaceRight(/\s+$/, "") \
              else fragment.replace(/\s+$/, ""))  
  toSourceNodeWhenNeeded result, stmt


FORMAT_MINIFY =
  indent:
    style: ""
    base: 0

  renumber: true
  hexadecimal: true
  quotes: "auto"
  escapeless: true
  compact: true
  parentheses: false
  semicolons: false

FORMAT_DEFAULTS = getDefaultOptions().format
exports.generate = generate
exports.attachComments = estraverse.attachComments
exports.Precedence = updateDeeply({}, Precedence)
exports.browser = false
exports.FORMAT_MINIFY = FORMAT_MINIFY
exports.FORMAT_DEFAULTS = FORMAT_DEFAULTS
