package KA::DB::Result::AIScratchPad;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result';
use KA::Util qw(format_date);
use DateTime;

__PACKAGE__->table('ai_scratch_pad');
__PACKAGE__->add_columns(
    id              => { data_type => 'int', size => 11, is_nullable => 0 },
    ai_empire_id    => { data_type => 'int', size => 11, is_nullable => 0 },
    body_id         => { data_type => 'int', size => 11, is_nullable => 1 },
    pad             => { data_type => 'mediumblob', is_nullable => 1, 'serializer_class' => 'JSON' },
); 

__PACKAGE__->belongs_to('body', 'KA::DB::Result::Map::Body', 'body_id');
__PACKAGE__->belongs_to('empire', 'KA::DB::Result::Empire', 'ai_empire_id');

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
