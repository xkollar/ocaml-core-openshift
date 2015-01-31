OCaml-<del>Core-</del>OpenShift
====================

OpenShift cartridge for OCaml with integrated building and running server.

This is a simple cartridge for creating applications based on OCaml <del>with Core</del>
(well, unless you have larger gear at your disposal).

There is also another [OCaml cartridge](https://bitbucket.org/jpathy/ocaml-openshift),
you may want to check it out too. Originally I thought my cartridge would be different.
However, during the development I gradually found out that they had done quite good
job and I have converged to very similar design myself. (At least I have learned something.)

Comparing to the other one my cartridge implements also
building, installation, and startup of packages (using `OASIS` and `OPAM`).
This was loosely inspired by [Haskell-Cloud](https://github.com/accursoft/Haskell-Cloud).

Original idea was to create environment where it would be simple/possible
to build applications based on `Core`+`Async`. However, it turned out to be quite
hard to build `Core` under restrictions imposed by small gears of OpenShift.

To start with OCaml and Core read [Real Wold OCaml](https://realworldocaml.org/).

HowTo
-----

### Example installation

~~~~ .bash
repodir=~/ocamltest
rhc app create ocamltest --repo "${repodir}" "https://raw.githubusercontent.com/xkollar/ocaml-core-openshift/master/metadata/manifest.yml"
cd "${repodir}"
~~~~

At this point only environment configuration is done. If you ssh to
your gear you will not find any OCaml stuff there.

~~~~ .bash
# do your changes and commit them into git
git push
~~~~

When you push for the first time, OPAM will be downloaded and
installed and then OCaml compiler and couple of auxiliary
packages will be downloaded and/or built. (One might think
that this should have been done during the application creation.
However, compiler installation is rather lengthy process and it would
have led to time-out thus causing inconsistent state.)

Next step is installation of your application (it should be OASIS and
OPAM enabled) followed by execution of binary `server`. That can be
vaguely described as follows:

~~~~ .bash
# in application repo dir
oasis setup
opam pin add "${pkgname}" . -y
server -port "${OPENSHIFT_OCAML_CORE_PORT}" -address "${PENSHIFT_OCAML_CORE_ADDRESS}"
~~~~

### What needs to be done for your application

Your application must provide binary called `server` that
uses values of environment variables `OPENSHIFT_OCAML_CORE_PORT`
and `OPENSHIFT_OCAML_CORE_ADDRESS` as parameters for binding.
