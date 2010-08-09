# Building

1. First make sure all the submodules are checked out.
   Run `git submodule init && git submodule update` in this directory
   and also in build-couchdb
1. cd couchdb/src/couchdb
1. erlc *.erl
1. cd ../../..
1. mv couchdb/src/couchdb/*.beam ./ebin

At this point you should be able to make a portable distribution like this:

    tar cvf fsck_couchdb.tar fsck_couchdb.escript ebin/

# Running

Untar to your database server.

    find . -type f -name '*.couch' -exec ./fsck_couchdb.escript {} \;
