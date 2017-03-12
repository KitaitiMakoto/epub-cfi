EPUB CFI
========

* [Homepage](https://gitlab.com/KitaitiMakoto/epub-cfi)
* [Documentation](http://rubydoc.info/gems/epub-cfi/frames)
* [Email](mailto:KitaitiMakoto at gmail.com)

Description
-----------

Parser and builder implementation for EPUB CFI defined at http://www.idpf.org/epub/linking/cfi/

Extracted from [EPUB Parser][].

[EPUB Parser]: http://www.rubydoc.info/gems/epub-parser/file/docs/Home.markdown

Features
--------

* Parses EPUB CFI string.
* Builds EPUB CFI(implemented but currently useless).
* Converts EPUB CFI object to a string.

Examples
--------

    require 'epub/cfi'
    
    location = EPUB::CFI.parse("epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]])")
    # Or location = EPUB::CFI("epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]])")
    # => #<EPUB::CFI::Location:/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]]>
    location.to_s # => "epubcfi(/6/14[chap05ref]!/4[body01]/10/2/1:3[2^[1^]])"
    
    location1 = EPUB::CFI("/6/4[chap01ref]!/4[body01]/10[para05]/1:3[xx,y]")
    location2 = EPUB::CFI("/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy]")
    location1 < location2 # => true
    location1 <=> location2 # => -1
    # location2 appears earlier than location1
    
    range = EPUB::CFI("/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4")
    # => #<EPUB::CFI::Location:/6/4[chap01ref]!/4[body01]/10[para05]/2/1:1>..#<EPUB::CFI::Location:/6/4[chap01ref]!/4[body01]/10[para05]/3:4>
    range.kind_of? ::Range # => true
    range.begin
    # => #<EPUB::CFI::Location:/6/4[chap01ref]!/4[body01]/10[para05]/2/1:1>
    range.end
    # => #<EPUB::CFI::Location:/6/4[chap01ref]!/4[body01]/10[para05]/3:4>
    range.start_subpath
    # => "/2/1:1"
    range.end_subpath
    # => "/3:4"
    range.parent_path
    # => #<EPUB::CFI::Location:/6/4[chap01ref]!/4[body01]/10[para05]>
    range.to_s # => "epubcfi(/6/4[chap01ref]!/4[body01]/10[para05],/2/1:1,/3:4)"
    
    builtin_range = location2..location1
    # => #<EPUB::CFI::Location:/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy]>..#<EPUB::CFI::Location:/6/4[chap01ref]!/4[body01]/10[para05]/1:3[xx,y]>
    builtin_range.to_s
    # => "epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy])..epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/1:3[xx,y])"
    builtin_range.kind_of? ::Range # => true
    builtin_range.kind_of? EPUB::CFI::Range # => false
    cfi_range = EPUB::CFI::Range.new(location2, location1)
    # => #<EPUB::CFI::Location:/6/4[chap01ref]!/4[body01]/10[para05]/2/1:3[yyy]>..#<EPUB::CFI::Location:/6/4[chap01ref]!/4[body01]/10[para05]/1:3[xx,y]>
    cfi_range.kind_of? ::Range # => true
    cfi_range.kind_of? EPUB::CFI::Range # => true

Install
-------

    $ gem install epub-cfi

See also
--------

* [EPUB Canonical Fragment Identifiers 1.1][spec]
* [EPUB Parser][]

[spec]: http://www.idpf.org/epub/linking/cfi/
[EPUB Parser]: http://www.rubydoc.info/gems/epub-parser/file/docs/Home.markdown

Copyright
---------

Copyright (c) 2017 KITAITI Makoto

See {file:COPYING.txt} for details.
