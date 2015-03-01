# Overview


# git / github

All quattor git repositories are part of the [quattor orgainization on GitHub][quattor_gh]

[quattor_gh]: https://github.com/quattor


## Prerequisites

1. Github account [github]
2. Join the quattor `developer` team [join_quattor]
 
[github]: https://github.com
[join_quattor]: https://help.github.com/articles/adding-or-inviting-members-to-a-team-in-an-organization/

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
9. The initial PR will trigger a [jenkins][quattor_jenkins] build of the unittests
 * The tests are run with the PR merged in current master

[quattor_jenkins]: https://jenkins1.ugent.be/view/Quattor/

# Unittests



## Adding new component in configuration-modules or AII

TODO: more info

New components should be added to the parent `pom.xml` in order to be part of the release.

Copy initial `pom.xml` from other component/hook.

# Known issues

1. Logger during unittests does not print debug messages.
