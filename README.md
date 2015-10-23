# JSW

An alternate version of Javascript syntax that uses significant whitespace

JSW (Javascript with Significant Whitespace) is a syntax for Javascript, and especially ES6, that allows editing real JS with Coffeescript-like syntax. 

The utility in this repository is a bi-directional translator between JS and JSW.

Unlike Coffeescript, JSW does not provide a new language with differing semantics.  It is a thin skin over Javascript that only changes the syntax. This JSW utility is a syntax translator, not a compiler or transpiler. 

JSW is a great way for Coffeescript users to migrate to real Javascript with ES6.

### Sample JSW with translated Javascript

```coffee
# JSW
-> func1 arg1, arg2                 
  var hash1 = key1: val1            
              key2: val2            
              key3:                 
  block                             
    let x = y                       
    func2 x                         
    if q and z                      
      func1 "This is text spread    
             over two lines."       
```
```javascript                                    
// Javascript                                    
function func1 (arg1, arg2) {
  var hash1 = {
    key1: val1,
    key2: val2,
    key3: key3
  }
  {
    let x = y;
    func2(x);
    if (q && z) {
      func1("This is text spread " +
            "over two lines.");
    }
  }
}
```

### Installation

This is not published in npm yet but installation is easy. Just clone this repo and run `npm install` in the repo folder.

### Usage

From the repo folder, run `scripts/run -tm test.js` to translate `test.js` *to* `test.jsw` with a map. Run `scripts/run -fm test.js` to translate *from* the new test.jsw to test.js. Run `scripts/run -h` to see all run options.

### JSW Overall Features

- JSW syntax is much less noisy than the JS syntax, just like Coffeescript.  No more unnecessary parens and braces.  No typing of `function`.

- Some syntax features, like simple line continuations and blocks, are an improvement over Coffeescript.

- The translation of JSW to/from JS is one-to-one and reversible.  Changing JS to JSW and back preserves the original text.  This means that JS commits to GIT will have minimal lines changed, only where JSW changed.

- The JSW utility in this repository includes translation to/from JS and JSW.  Both directions are equally supported.

- The JS produced by translating JSW is easily predictable.  It consists of simple short mappings like `function` to `->`.  Writing JSW and debugging with the translated JS takes no mental effort.

- JSW takes advantage of new ES6 features.  The syntax `->` is a replacement for `function` while ES6 provides `=>` with no change in JSW.  The combination of the two matches coffescript.

- You can easily convert from Coffeescript to JSW by first converting to JS and then to JSW.

- Coffeescript highlighting works pretty well with JSW (see sample above)

- An Atom editor extension, coffee-js-translator, is planned that allows opening normal JS, editing in JSW, and saving in the original JS.  This allows working with others who don't even know about JSW.  One does not even need to have JSW files.

### JSW features not in Coffeescript

  - Most of ES6
  - Simple continuations that can break anywhere, including strings
  - Blocks
  - No hashes require braces
  
### Coffeescript features not in JSW

  - Some ES6 replacements not as complete (e.g. Classes)
  - All statements are expressions
  - Ranges
  - `this` reference in params and object declrations
  - Matching ES6 features often have different syntax (e.g. string interpolation)
  - Combined comparison (0 < x < 1)
  
### JSW to JS Text Mapping

When JS is converted to JSW, a compact set of metadata is added to the bottom of JSW as a comment.  This is very similar to how Coffeescript provides a source map.  If support for exact JS text matching is not required this can be disabled.  In general it can be ignored and the Atom package JSW will hide that metadata when editing.

### Status is Pre-Alpha

Not useful yet. The project is stable enough to run the round-trip translation. But the only language translation is `->` to/from `function`.  It also doesn't preserve the JS formatting when translating back to js, but the map is properly created in the .jsw file, ready to be used.

The next step is adding the code to use the map and complete the round-trip formatting.  Then the only thing left to is hack the parser/generator to finish the new syntax.  I use the term "only" liberally (grin).

### Helping Development

Clone this repo and run `npm install` in the repo folder.  Edit the code in the `src` or `uglify` folder.  When you run `scripts/run` using the Usage instructions above it will automatically compile the coffeescript to javascript before running.  This is obviously temporary until the pre-publish build process is added.

Use `scripts/runw` (run and watch) instead of `scripts/run` and the test will be run again whenever and source file changes.

### Worried about developing in Coffeescript?  

Don't be!  The whole point of this project is to allow you to work in either coffeescript-like syntax or in real Javascript.  As soon as this utility is mature, it will be used to change this project to pure Javascript.  Everyone will then be able to work on it the way they want.

### License

Copyright by Mark Hahn using the MIT license.

