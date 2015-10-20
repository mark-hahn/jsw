
getArgs = ->

  parser = new (require('argparse').ArgumentParser)
    version: JSON.parse(require('fs').readFileSync 'package.json', 'utf8').version
    addHelp: true
    description: 
      "A translator for an alternate Javascript syntax that uses significant whitespace. 
       A .js file is a javascript file up to es6. A .jsw file is the alternate syntax version.
      The two files operated on have file names that only differ in the suffix.
      This utility translates to/from these two types. "

  parser.addArgument ['-w', '--tojsw' ], 
    nargs: 0
    action: 'storeTrue'
    help: 'Translate js file to a jsw file.'
 
  parser.addArgument ['-t', '--tojs' ], 
    nargs: 0
    action: 'storeTrue'
    help: 'Translate jsw file to a js file.'
 
  parser.addArgument ['-m', '--map' ], 
    nargs: 0
    action: 'storeTrue'
    help: 'Create map file.'
 
  parser.addArgument ['-a', '--auto' ], 
    nargs: 0
    action: 'storeTrue'
    help: 'Translate older js or jsw file to the other type.'
 
  parser.addArgument ['files'], 
    nargs: '*'
    help: 'Files to translate.'

  parser.parseArgs()

module.exports = getArgs()
