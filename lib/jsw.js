// Generated by CoffeeScript 1.9.3

/*
  jsw.coffee
  A translator for an alternate Javascript syntax that uses significant whitespace
 */

(function() {
  var args, log, parser;

  log = require('debug')('jsw');

  log('process7', process.argv);

  parser = new (require('argparse').ArgumentParser)({
    version: "0.0.1",
    addHelp: true,
    description: "A translator for an alternate Javascript syntax that uses significant whitespace"
  });

  parser.addArgument(["-o", "--output"], {
    help: "Output all translated files to this directory."
  });

  parser.addArgument(["-f", "--force"], {
    help: "Allow overwriting existing files."
  });

  parser.addArgument(["-d", "--delete"], {
    help: "Delete .jws file if matching .js file exists."
  });

  args = parser.parseArgs();

  log('args', args);

}).call(this);