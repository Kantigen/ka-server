package KA::DB::Result::Probe;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result';
use KA::Util qw(format_date);
use DateTime;

__PACKAGE__->table('probe');
__PACKAGE__->add_columns(
    empire_id               => { data_type => 'int', is_nullable => 0 },
    star_id                 => { data_type => 'int', is_nullable => 0 },
    body_id                 => { data_type => 'int', is_nullable => 0 },
    alliance_id             => { data_type => 'int', is_nullable => 1 },
    virtual                 => { data_type => 'int', is_nullable => 1, default_value => 0 },
);

__PACKAGE__->belongs_to('empire', 'KA::DB::Result::Empire', 'empire_id');
__PACKAGE__->belongs_to('star', 'KA::DB::Result::Map::Star', 'star_id');
__PACKAGE__->belongs_to('body', 'KA::DB::Result::Map::Body', 'body_id');
__PACKAGE__->belongs_to('alliance', 'KA::DB::Result::Alliance', 'alliance_id');


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
