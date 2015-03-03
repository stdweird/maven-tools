# Overview


# git / github

All quattor git repositories are part of the [quattor organisation on GitHub][quattor_gh]

[quattor_gh]: https://github.com/quattor


## Prerequisites

1. An account on [GitHub][github]
2. Join the quattor organization and `developer` team 
 * TODO: this is how current admin can add/invite new people [join_quattor]
3. Join the [`quattor-devel` mailing list][quattor_devel_ml]

[github]: https://github.com
[join_quattor]: https://help.github.com/articles/adding-or-inviting-members-to-a-team-in-an-organization/
[quattor_devel_ml]: https://lists.sourceforge.net/lists/listinfo/quattor-devel

### Getting started with git

TODO: add urls to git tutorials

## Workflow

1. Fork the repository you want to work on
2. Clone the repository locally using the `ssh` URL
 * Your fork is known as `origin`
3. Add the `upstream` repository using the `https` URL
4. Start with a new branch
 * Do not work in `master` branch
5. Make modifications, add and commit them
 * Try to use meaningfull messages
  * For the the `configuration-modules-core` (and other `configuration-modules`) repository, set the
    component name in the commit message when working on more then one component in same branch.
6. Push you changes to your fork (i.e. to `origin`)
 * Do not push to `upstream`
7. Run the unittests
8. Open a pull request (PR)
 * Meaningful title; title will be part of teh relase notes
  * For `configuration-modules` repository: start the title with the component that is being modified
   * When more then one component is modified, describe the general work in the titel;
     the commit messages should have the component names.
 * Set `milestone` (i.e. the release you want this merged in)
  * Set a realistic milestone, e.g. ff the PR is not urgent or not finished
    or you have no time to follow up, you might want to pick later milestone.
 * Set `assignee` to yourself
9. The initial PR will trigger a [jenkins][quattor_jenkins] build of the unittests
 * The tests are run with the PR merged in current master
10. The PR will be reviewed, and after the reviewer is satisfied, it will be merged in.
11. Every 2 months, a release is made by the release manager that will contain your changes
 * Only for severe regressions / bugs, the release manager might consider an intermediate
   release to address the specific issue.
   To start using your new code, you best

[quattor_jenkins]: https://jenkins1.ugent.be/view/Quattor/

## Adding new component in configuration-modules or AII

TODO: more info

New components should be added to the parent `pom.xml` in order to be part of the release.

Copy initial `pom.xml` from other component/hook, change the project.


## Maven

Quattor uses `maven` for its software project management.

All source code and unittests are kept under the `src` subdir.
 * `src/main/perl` for perl modules
 * `src/main/pan` for pan templates like `schema.pan`
 * `src/test/perl` for the perl unitttests (and any other perl helper modules that might required)
 * `src/test/resources` for pan templates that are used with the unittests
 * metaconfig services are an exception

During testing, a `target` subdir is created by the maven tool

The process is steered via a `pom.xml` file, that is derived from a quattor maven atrifact.  
These pom files require few changes, but typical ones are:
 * add developer / maintainer
 * set the project name (e.g. in case of a new component)
 * add custom plugin for specific projects
 * modify the version of the `build-profile`

### maven commands 
Most common commands are

0. `mvn clean` cleans any previous maven runs (in particular the `target` directory)
1. `mvn test` runs the unittests
 * best to run `mvn clean test`
 * if you wan to run a single test, you can use `-Dunittest=name_of_test.t`
2. `mvn package` Sometimes you will want to make a rpm or tarball to start
 using your code while waiting for the PR to be reviewed and merged. This command
 will create the rpm (and tarball).
 * `package` also runs the tests, and also here it is advised to use `mvn clean package`

# Unittests

All quattor projects have unittests. These are run via the `mvn test` command, and run the perl
unittests under the `src/test/perl` subdirectory.

Maven runs the tests via `prove` (the commandline tool from `TAP::Harness`), and the required
include paths are already set, except for any dependencies.

`prove` only runs files with a `.t` suffix; any other files are ignored. This allows you to create
any helper modules for the unittests themself under the `src/test/perl` directory (`src/test/perl`
is added to the perl `@INC` via the `prove` commandline).

If you want to run a single unittest, add `-Dunittest=name_of_test.t` to the `mvn` commandline. 

## Unittest dependencies

The main issue with the unittests is the large number of dependencies that are required by all the various
repositories.

Basic non-perl:
 * `maven`
 * `panc` (`>= 10.2`)

Optional non-perl:
 * `rpm-build` (for building rpms)

Perl dependencies:
 * number of quattor tools (`LC`, `CAF`, `CCM`)
 * perl modules required for runtime
 * perl modules required for testing

The quattor test framework `Test::Quattor` is controlled through maven
(this is the `build-profile` in the `pom.xml`).

TODO: add list from `build_all_repos`

### quattor-development template

If your development environment is managed by Quattor, you can use the [quattor-development][template_qt_dev]
to add all required dependencies 


[template_qt_dev]: https://github.com/quattor/template-library-os/blob/sl6.x-x86_64/rpms/quattor-development.pan

### Bootstrap yum-based system

The [`build_all_repos`][build_all_repos] script tries to build all rpms for most quattor repositories.
Repositories that are not build include `panc` and the template repositories.

One of it's features is that it resolves (or tries to) all dependencies (currenlty) using `yum`.
(`sudo` rights are required for `yum` and `repoquery`; it is __NOT__ recommended to run this as root)
Perl dependencies that can't be installed via yum, are installed from `CPAN` (using `cpanm`).

As it runs all unittests, the result of running the script is an environment where you can start developing.

By default, `build_all_repos` installs everything in a `quattordev` subdirectory, and has subdirectories
 * `repos` all the quattor git repos, with the remote `upstream` set.
  * you need to add your fork as the remote `origin`.
 * `install` contains the quattor repositories from unpacked tarballs and any dependencies installed via `CPAN`
 * `rpms` contains all build rpms
 * a number of logfiles with e.g. the installed dependencies

Running the script takes a while to complete. Best run it in a `screen` session and redirect the output to a logfile.
(Best to check the `sudo` command upfront, as it can prompt for passsword, and thus block the script).
TODO: check the sudo timeout (a.k.a when do the credentials expire).

[build_all_repos]: https://raw.githubusercontent.com/quattor/release/master/src/scripts/build_all_repos.sh

## Writing unittests

### Test::More

The basic test module
 * `ok($bool, "message");` tests if `$bool` is true
  * use `ok(! $bool, "message");` to test if `$bool` is false
 * `is($a, $value, "message")` tests if `$a` is `$value`
  * for comparing hash and array, use `is_deeply` to compare references
   * `is_deeply(\%hash, {expected => 'value'}, "message");`
   * `is_deeply(\@array, [qw(value1 value2)], "message");`
 * `isa_ok($instance, "Instance::Class::Name", "message")`  tests if `$instance` is an instance of class `Instance::Class::Name`
 * `like("text", qr{regexp}, "message");` tests if `"text"` matches the compiled regular rexpression `qr{regexp}`
  * complex texts can be tested with `Test::Quattor::RegexpTest` TODO add reference

### Test::Quattor

Methods from 

TODO: add sample component with examples
 * CAF::TextRender
 * compile profile
 * inject expected command output
  * history_ok

Quattor has it's own set of methods to help testing and mocking called [`Test::Quattor`][maven_tools_test_quattor_docs].

[maven_tools_test_quattor_docs]: http://docs-test-maven-tools.readthedocs.org/en/latest/maven-tools/Quattor/

#### Compiled profiles

To test using a profile, you create the object template under `src/test/resources` (e.g. `src/test/resources/foo.pan`).

In the test, you then prepare a compiled and ready-to-use `EDG::WP4::CCM::Configuration` instance during the load of `Test::Quattor`

```perl
use Test::Quattor qw(foo);
```

and to get the configuration instance you then do

```perl
my $cfg = get_config_for_profile('foo');
```

e.g. to be used

```perl
use Test::Quattor qw(foo);
use NCM::Component::mycomponent;
my $cmp = NCM::Component::mycomponent->new('mycomponent');
my $cfg = get_config_for_profile('foo');
$cmp->Configure($cfg);
ok(!exists($cmp->{ERROR}), "Configure succeeds with any error logged");
```

All methods of `Test::Quattor` are exported, so no need to use the load for that (in fact, you can't use load for that).

Caveat: reusing the object template for different tests can lead to race conditions (and thus failures),
try to use unique profiles to avoid this buggy behaviour.

#### CAF::Process

 * `set_command_status`, `set_desired_output`, `set_desired_err` mock the status, stdout and stderr of future `CAF::Process` call

    <!-- language: lang-perl -->
        set_desired_output("/usr/bin/command", "expected output");

* `get_command` use to test if a  `CAF::Process` with exact commandline was called (and returns the `CAF::Process` instance).

        ```perl
        ok(get_command("/usr/bin/someexecutable -l -s"), "Command was called");
        ```

   or if you need to access the instance

        ```perl
         my $procinstance = get_command("/usr/bin/someexecutable -l -s");
        ```

 * `command_history_ok`, `command_history_reset` test ordered execution of `CAF::Process` instances

        ```perl
        command_history_reset();
        ok(command_history_ok(['pattern1','pattern2']), "message");
        ``` 

#### CAF::FileWriter (Editor,Reader)

 * `get_file` returns the instance that opened/modified a file
        ```perl
        my $fh = get_file("/some/path");
        ```

 * `set_file_contents` set the content a future `CAF::File*` instance will see
        ```perl
        set_file_contents("/some/path", $text);
        ```

* `set_caf_file_close_diff` mock the `CAF::File*->close()` return behaviour to return a true value if the content changed.
   By default, this is false, and `close()` will return some garbage.
   TODO: why is this not default true?
        ```perl
        set_caf_file_close_diff(1);
        ```

### Test::MockModule

You can mock almost any module using `Test::MockModule` including the code you are working on.

E.g. by defining

```perl
my $mock = Test::MockModule->new('NCM::Component::mycomponent');
$mock->mock('do_something', sub () {return [qw(1 2 3)]} );
```

you have mocked the `do_something` method of the `mycomponent` component.

If you then initialise the component, any calls to the `do_something` method will
return the reference to the array `(1, 2, 3)`.

`Test::Quattor` provides a mocked version of a number of `CAF` modules and their methods,
so you should not mock these yourself.

Caveat: there are a few perl builtins that can't be mocked, esp. tests like `-f $filename`.
If you want to test and mock this sort of calls, it is best if you define a short private method in your code like

```perl
sub _test_file {
    my ($self, $filename) = @_;
    return -f $filename;
}
```

and use `$self->_test_file($some_file)` in the code. This can then be mocked as e.g.

```perl
my $mock = Test::MockModule->new('NCM::Component::myothercomponent');
$mock->mock('_test_file', sub () {
    my ($self,$fn) = @_;
    my $ans = 0; # does not exist
    if ($fn eq "/some/path") {
        # more logic
        $ans = 1; 
    }
    return $ans;
}
```

# Known issues

1. Logger during unittests does not print debug messages.
