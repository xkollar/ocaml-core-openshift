OCaml-Core-OpenShift
====================

OpenShift cartridge for OCaml with integrated building and running server.

This is simple cartridge for creating applications based on OCaml <del>with Core</del>
(well, unless you have larger gear at your disposal).
There already exists other [OCaml cartridge](https://bitbucket.org/jpathy/ocaml-openshift),
you may want to check it out too. Originally I thought my cartridge would be different,
however during the development I gradually found out that those people did quite good
job and converged to very similar design myself. At least I have learned something.

I added building and installation of packages using `OASIS` and `OPAM`. This was loosely
inspired by [Haskell-Cloud](https://github.com/accursoft/Haskell-Cloud).

Original idea was to create environment where it would be simple/possible
to build servers based on Core+Async. However, it turned out to be quite
hard to build Core in limited conditions that OpenShift provides.

To start with OCaml and Core read [Real Wold OCaml](https://realworldocaml.org/).

HowTo
-----

### Example installation

~~~~ .bash
repodir=~/ocamltest
rhc app create ocamltest --repo "${repodir}" "https://raw.githubusercontent.com/xkollar/ocaml-core-openshift/master/metadata/manifest.yml"
cd "${repodir}"
~~~~

At this point, only environment configuration is done. If you ssh to
your gear, you will not find any OCaml stuff there.

~~~~ .bash
# do your changes and commit them into git
git push
~~~~

When you push for the first time, OPAM will be downloaded and
installed and then OCaml compiler and couple of auxiliary
packages will be downloaded and/or built (it was timing out if
this was done during initial gear setup).

Next step is installation of your application (it should be OASIS and
OPAM enabled) followed by execution of binary `server`. That can be
vaguely described as follows:

~~~~ .bash
# in application repo dir
oasis setup
opam pind add "${pkgname}" . -y
server -port "${OPENSHIFT_OCAML_CORE_PORT}" -address "${PENSHIFT_OCAML_CORE_ADDRESS}"
~~~~

### What needs to be done for your application

Your application must have at least executable called `server` that
takes uses values of environment variables `OPENSHIFT_OCAML_CORE_PORT`
and `OPENSHIFT_OCAML_CORE_ADDRESS` as parameters for binding.
