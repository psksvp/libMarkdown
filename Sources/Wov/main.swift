import libMarkdown

let md = """

# Hello Markdown

This is an inline $f(x)$ function.

           This is a block $$f(x)$$ function.
           This is also an inline \\(f(x)\\) function.
           This is also a block \\[f(x)\\] function.

# another header

Is this it?

1. one
2. two
3. three
  
  3.1. this is a test
  3.2 this is a another test


![test](https://upload.wikimedia.org/wikipedia/commons/b/b5/Bloem_van_een_Astrantia_major_%27Roma%27._24-06-2021_%28actm.%29_01.jpg) {width=100%}

"""

print(md2html(md))
