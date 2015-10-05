# jsw
An alternate version of Javascript syntax that uses significant whitespace

JSW (Javascript with Significant Whitespace) is a syntax for Javascript, and especially ES6, that allows editing real JS with Coffeescript-like syntax. 

The utility in this repository is a bi-directional translator between JS and JSW.

Unlike Coffeescript, JSW does not provide a new langauge with differing semantics.  It is a thin skin over Javascript that only changes the syntax. This JSW utility is a translator, not a compiler. 

### Sample JSW with translated Javascript

```
-> func1 arg1, arg2
  var hash1 = key1:
```

### Features

- JSW syntax is much less noisy than the JS syntax, just like Coffeescript.  No more unnecessary parens and braces.  No typing of `function`.

- Some syntax features, like simple line continuations, are an improvement over Coffeescript.

- The translation of JSW to/from JS is one-to-one and reversible.  Changing JS to JSW and back preserves the original text.  This means that commits to GIT will have minimal lines changed, only where JSW changed.

- The JSW utility in this repository includes translation to/from JS and JSW.  Both directions are of equal importance.

- The JS produced by translating JSW is easily predictable.  It consists of simple short mappings like `function` to `->`.  Writing JSW and debugging with the translated JS takes no mental effort.

- JSW takes advantage of new ES6 features.  The syntax `->` is a replacement for `function` while ES6 provides `=>` with no change in JSW.  The combination of the two matches coffescript.

- An Atom editor extension, coffee-js-translator, is available that allows opening normal JS, editing in JSW, and saving in the original JS.  This allows working with others who don't even know about JSW.  One does not even need to have JSW files.

