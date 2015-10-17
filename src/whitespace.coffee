
exports.get = (code, tokens, comments) ->
  tokenAndCommentRanges = []
  for token in tokens
    tokenAndCommentRanges.push token.range
  for comment in comments
    tokenAndCommentRanges.push comment.range
  tokenAndCommentRanges.sort()
  whitespace = []
  pos = 0
  for range in tokenAndCommentRanges
    start = range[0]
    end   = range[1]
    if start > pos
      whitespace.push
        value: code.slice pos, start
        range: [pos, start]
    pos = end
  whitespace
  
  