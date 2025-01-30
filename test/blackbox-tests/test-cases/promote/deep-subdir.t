Tests for promoting directory targets
-------------------------------------

  $ cat > dune-project << EOF
  > (lang dune 3.0)
  > (using directory-targets 0.1)
  > EOF

  $ cat > dune << EOF
  > (rule
  >  (deps
  >   (source_tree deep))
  >  (targets
  >   (dir deep_copied))
  >  (mode promote)
  >  (action
  >   (run cp -r deep deep_copied)))
  > EOF

Let's create the directory structure we are going to promote (as a copy on
another dir):

  $ mkdir -p deep/a/
  $ touch deep/a/deep_file
  $ touch deep/base_file

Let's try this:

  $ dune build deep_copied

This one works. Now, let's add a layer between base_file and deep_file:

  $ rm -rf deep
  $ mkdir -p deep/a/b/
  $ touch deep/a/b/deep_file
  $ touch deep/base_file

  $ dune build deep_copied
  File "dune", lines 1-8, characters 0-123:
  1 | (rule
  2 |  (deps
  3 |   (source_tree deep))
  4 |  (targets
  5 |   (dir deep_copied))
  6 |  (mode promote)
  7 |  (action
  8 |   (run cp -r deep deep_copied)))
  Error: Cannot promote files to "deep_copied/a/b".
  Reason: opendir(deep_copied/a/b): No such file or directory
  -> required by _build/default/deep_copied
  [1]

It does not work! Note that the `base_file` is required. For instance, move it
to `a/`, or remove it, and it works:

  $ mv deep/base_file deep/a/
  $ dune build deep_copied

  $ rm deep/a/base_file
  $ dune build deep_copied
