package KA::DB;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces();

sub sqlt_deploy_hook {
    my ($self, $sqlt_schema) = @_;
#    $sqlt_schema->drop_table('noexist_basetable');
}

no Moose;
__PACKAGE__->meta->make_immutable;

