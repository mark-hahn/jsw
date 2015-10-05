# jsw

An alternate version of Javascript syntax that uses significant whitespace

JSW (Javascript with Significant Whitespace) is a syntax for Javascript, and especially ES6, that allows editing real JS with Coffeescript-like syntax. 

The utility in this repository is a bi-directional translator between JS and JSW.

Unlike Coffeescript, JSW does not provide a new language with differing semantics.  It is a thin skin over Javascript that only changes the syntax. This JSW utility is a syntax translator, not a compiler or transpiler. 

JSW is a great way for coffeescript users to migrate to real Javacscript with ES6.

### Sample JSW with translated Javascript

```
-> func1 arg1, arg2                 function func1 (arg1, arg2) {
  var hash1 = key1: val1              var hash1 = {
              key2: val2                key1: val1,
              key3:                     key2: val2,
  block                                 key3: key3
    let x = y                         }
    func2 x                           {
    if q and z                          let x = y;
      func1 "This is text spread        func2(x);
             over two lines."           if (q && z) {
                                          func1("This is text spread " +
                                                "over two lines.");
                                        }
                                      }
                                    }
```

### JSW Overall Features

- JSW syntax is much less noisy than the JS syntax, just like Coffeescript.  No more unnecessary parens and braces.  No typing of `function`.

- Some syntax features, like simple line continuations and blocks, are an improvement over Coffeescript.

- The translation of JSW to/from JS is one-to-one and reversible.  Changing JS to JSW and back preserves the original text.  This means that JS commits to GIT will have minimal lines changed, only where JSW changed.

- The JSW utility in this repository includes translation to/from JS and JSW.  Both directions are equally supported.

- The JS produced by translating JSW is easily predictable.  It consists of simple short mappings like `function` to `->`.  Writing JSW and debugging with the translated JS takes no mental effort.

- JSW takes advantage of new ES6 features.  The syntax `->` is a replacement for `function` while ES6 provides `=>` with no change in JSW.  The combination of the two matches coffescript.

- An Atom editor extension, coffee-js-translator, is planned that allows opening normal JS, editing in JSW, and saving in the original JS.  This allows working with others who don't even know about JSW.  One does not even need to have JSW files.

### Coffeescript features not in JSW

  - Some ES6 replacements not as complete (e.g. Classes)
  - All statements are expressions
  - Ranges
  - `this` reference in params and object declrations
  - Matching ES6 features often have different syntax (e.g. interpolation)
  - Combined comparison (0 < x < 1)
  
### JSW features not in Coffeescript

  - Much of ES6
  - Simple continuations that can break anywhere, including strings
  - Blocks
  - No hashes require braces
  
### Status

You are looking at it.  No coding has started.  Even this readme is a work-in-progress.

### License

Copyright by Mark Hahn using the MIT license.

