###
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
###

log = require('debug') 'jsw'

log 'process.argv', process.argv

parser = new (require('argparse').ArgumentParser)
  version: "0.0.1"
  addHelp: true
  description: "A translator for an alternate Javascript syntax that uses significant whitespace"

parser.addArgument ['-t', '--tojsw' ], help: 'Translate .js files to .jsw (default is to .js).'
parser.addArgument ['-s', '--safe'  ], help: "Don't overwrite existing files."
parser.addArgument ['-d', '--delete'], help: 'Delete .jws file if newer .js file exists.'

args = parser.parseArgs()
log 'args', args
