# TextRender

Generating structured text is best done with [`CAF::TextRender`][caf_textrender_docs].
This document guides through the usage and testing of `CAF::TextRender` and
also describes `ncm-metaconfig`, which is the metacomponent build around
`CAF::TextRender`.

# TODO add correct url
[caf_textrender_docs]: http://localhost

# CAF::TextRender

Basic usage has 2 main modes:
 * generate text : the `CAF::TextRender` instance has auto-stringification
        ```perl
        use CAF::TextRender;
        my $module = 'mymodule';
        my $trd = CAF::TextRender->new($module, $contents, log => $self);
        print "$trd"; # stringification
        ```
 * write text to file : get a `CAF::FileWriter` instance with text from `CAF::TextRender` instance
        ```perl
        use CAF::TextRender;
        $module = "mymodule";
        $trd = CAF::TextRender->new($module, $contents, log => $self);
        my $fh = $trd->filewriter('/some/path');
        die "Problem rendering the text" if (!defined($fh));
        $fh->close();
        ```

Besides the logger, the 2 main parameters are the `module` and the `contents`.
The contents is a hash-reference with the data that is used to generate
the text (e.g. from a `$cfg->getElement('/some/pan/path')->getTree()`).

The `module` is what defines how the text is generated.

It is either one of the following reserved values 
 * *json* (using `JSON::XS`)
 * *yaml* (using `YAML::XS`), 
 * *properties* (using `Config::Properties`), 
 * *tiny* (using `Config::Tiny`),
 * *general* (using `Config::General`)

(The builtin modules can have issues with reproducability, e.g. ordering or a default timestamp.)

Or, for any other value, `Template::Toolkit` (TT) is used,
and the `module` then indicates the relative path of the template to use.
The absolute path of the TT files is determined by 2 optional parameters:
the absolute `includepath` (defaults to `/usr/share/templates/quattor`)
shouldn't be modified, but the `relpath` (defaults to `metaconfig`) should.

A module `mytest/main` with relpath `mycode` will use a
TT file `/usr/share/templates/quattor/mycode/mytest/main.tt`.
The `relpath` is important for creating the TT files: when the
`INCLUDE` directive is used, TT searches starting from the `includepath`, so in this example the `main.tt` might look like
```
[% data.name %]
[% INCLUDE 'shared/data' %]
```

which will look for the absolute file `/usr/share/templates/quattor/shared/data.tt`.

`CAF::TextRender` does not allow you to include files from a directory lower then `relpath` (e.g. `module` `../cleverhack` will not work).

## Template::Toolkit

TODO add url with examples

# Test::Quattor::RegexpTest

Testing the generated text (and in particular the TT files used to generate it)
can be done via regular expressions and e.g. the `like` method from `Test::More`.

`Test::Quattor::RegexpTest` provides an easy way to do this.

A `RegexpTest` is a text file with 3 blocks separated by a `---` marker.

The first block is the description, the second block a list of flags (one per line)
and the third block has all the regular expressions.

An example RegexpTest looks like

    Verify mycode
    ---
    ---
    ^line 1
    ^line 3

with an empty flags block (using the defaults `ordered` and `multiline`).

If we create a file `src/test/resources/rt_mycode` with this content, we can now test
generated text against this RegexpTest using


```perl
use Test::Quattor::RegexpTest;
use CAF::TextRender;
my $module = 'mymodule';
my $trd = CAF::TextRender->new($module, $contents, log => $self);
my $rt = Test::Quattor::RegexpTest->new(
    regexp => 'src/test/resources/rt_mycode',
    text => "$trd",
    );
$rt->test();
```

With the default flags, each line is compiled as amultiline regular expression and matched gainst the text.
The matches are also checked if they are ordered. In the example above `line 3` is expected to match in the text
following `line 1`. But it does not need to be the next line (e.g. there could be a `line 2` in between).
Each match is a test and each verification of the ordering also.

TODO add links to the flags docs

# metaconfig

The `metaconfig` component together with `Test::Quattor::TextRender::Metaconfig` gives a
high-level interface to the previous classes.

Configfiles will be rendered using `CAF::TextRender` and one can validate the modules using RegexpTests.

##

