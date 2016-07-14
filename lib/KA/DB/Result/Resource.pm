package KA::DB::Result::Resource;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result';

__PACKAGE__->table('body_resource');
__PACKAGE__->add_columns(
    body_id             => { data_type => 'int', is_nullable => 0 },
    type                => { data_type => 'varchar', size => 63, is_nullable => 0 },
    production          => { data_type => 'int', is_nullable => 0, default => 0 },
    consumption         => { data_type => 'int', is_nullable => 0, default => 0 },
    stored              => { data_type => 'int', is_nullable => 0, default => 0 },
    capacity            => { data_type => 'int', is_nullable => 0, default => 0 },
);

# RELATIONSHIPS
#
 __PACKAGE__->belongs_to('body', 'KA::DB::Result::Map::Body', 'body_id');

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_resource_body', fields => ['body_id']);
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
