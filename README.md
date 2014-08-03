sc_erlisp
=========

All the cool kids have made a scheme; I figure I ought to too.

![Language](http://img.shields.io/badge/Language-Lisp_in_Erlang-000000.svg) &nbsp;
![Platform](http://img.shields.io/badge/Platform-OTP-000000.svg) &nbsp;
![License](http://img.shields.io/badge/License-MIT-000055.svg) &nbsp;
![Status](http://img.shields.io/travis/StoneCypher/sc_erlisp.svg) &nbsp;
![Release](http://img.shields.io/github/release/StoneCypher/sc_erlisp.svg) &nbsp;
[![Issues](http://img.shields.io/github/issues/StoneCypher/sc_erlisp.svg)](https://github.com/StoneCypher/sc_erlisp/issues)





tl;dr
-----

`rebar g-d co eu doc`





Current Library Status: *Not Usable*
--------------------------------

This library is considered to be not ready.  There's still a fair amount of stuff to be done.

Improvements will be gladly accepted.





Usage
-----

```erlang
1> sc_erlisp:run("(+ 2 3)").
5

2> sc_erlisp:run("(* (/ 6 4) (- 5 2))").
4.5

3> sc_erlisp:run("(odd? (+ 2 3))").
<<"#t">>
```





Author
------

* [John Haugeland](mailto:stonecypher@gmail.com) of [http://fullof.bs/](http://fullof.bs/).



Copyright
---------

Copyright (c) 2014 John Haugeland.  All rights reserved.



Polemic :neckbeard:
-------------------

`sc_erlisp` is MIT licensed, because viral licenses and newspeak language modification are evil.  Free is ***only*** free when it's free for everyone.
