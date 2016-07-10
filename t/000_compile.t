use strict;
use warnings;
use Test::More;
use lib "lib";
use lib "t/lib";

eval "use Test::Compile";
Test::More->builder->BAIL_OUT(
    "Test::Compile required for testing compilation") if $@;

all_pm_files_ok(all_pm_files('lib/KA', 'lib/Lacuna', 't/lib'));

