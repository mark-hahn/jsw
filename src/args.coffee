
getArgs = ->

  parser = new (require('argparse').ArgumentParser)
    version: "0.0.1"
    addHelp: true
    description: 
      "A translator for an alternate Javascript syntax that uses significant whitespace"

  parser.addArgument ['-t', '--tojsw' ], 
    nargs: 0
    action: 'storeTrue'
    help: 'Translate .js files to .jsw (default is .jsw to .js).'

  parser.addArgument ['-s', '--safe'  ], 
    nargs: 0
    action: 'storeTrue'
    help: "Don't overwrite existing files."

  parser.addArgument ['-d', '--delete'], 
    nargs: 0
    action: 'storeTrue'
    help: 'Delete .jws file if newer .js file exists.'

  parser.addArgument ['files'], 
    nargs: '+'
    help: 'Files to translate.'

  parser.parseArgs()

module.exports = getArgs()
