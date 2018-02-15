# Adding new columns to the db

Whether adding, removing, or modifying, the steps required prior to git commit are:

1. Make the changes as normal.
2. Increment `$VERSION` in `KA::DB`.
3. In the docker image, run `dbupdate.pl write_ddl`.
4. Test the update: `dbupdate.pl upgrade`.  Assuming it all works...
5. Add all new files and directories in `var/upgrades`.
6. Commit and push.

If it does not all work after the upgrade, you may have to manually roll it
back, and try again. You can `write_ddl` with the `-f` flag to rewrite those
changes.

## WHY?

This replaces the old method of ... really, I don't know what. Manually 
updating the upgrades sql files? This new method is a wrapper around
[App::DH](https://metacpan.org/pod/App::DH), which is a wrapper around
[DBIx::Class::DeploymentHandler](https://metacpan.org/pod/DBIx::Class::DeploymentHandler).

The old method mostly worked. I caught a couple of errors in the
sql alter table statements, sometimes too late. I caught many errors
in my own alter table statements as I tried to develop them. The goal
here is to let DBIx::Class handle it so we don't have to. While DB
stuff is fun to learn about, it's not the goal of this project. I
just want to simplify this so that we can focus on producing the game
instead.
