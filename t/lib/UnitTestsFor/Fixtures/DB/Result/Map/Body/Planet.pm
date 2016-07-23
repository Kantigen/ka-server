package UnitTestsFor::Fixtures::DB::Result::Map::Body::Planet;

use Moose;
extends 'DBIx::Class::EasyFixture';
use namespace::autoclean;

my %definitions = (
    my_empire => {
        new => 'Empire',
        using => {
            id                 => 1,
            name               => 'me',
            date_created       => '2016-07-20 06:33:16',
            self_destruct_date => '2016-07-20 06:33:16',
            status_message     => '',
            password           => 'secret',
            sitter_password    => 'secret',
            last_login         => '2016-07-20 06:33:16',
            storage_boost      => '2016-07-20 06:33:16',
            food_boost         => '2016-07-20 06:33:16',
            water_boost        => '2016-07-20 06:33:16',
            energy_boost       => '2016-07-20 06:33:16',
            happiness_boost    => '2016-07-20 06:33:16',
            building_boost     => '2016-07-20 06:33:16',
            spy_training_boost => '2016-07-20 06:33:16',
        },
    },

    my_star => {
        new => 'Map::Star',
        using => {
            id             => 1,
            name           => "Dillon",
            x              => 98,
            y              => 98,
            zone           => "0|0",
            color          => "yellow",
        }
    },

    my_planet => {
        new => 'Map::Body::Planet',
        using => {
            id                  => 1,
            name                => 'my_empire',
            x                   => 100,
            y                   => 100,
            zone                => "0|0",
            star_id             => 1,
            orbit               => 3,
            class               => "KA::DB::Result::Map::Body::Planet::P14",
            size                => 72,
            usable_as_starter   => 1,
            usable_as_starter_enabled => 0,
            empire_id           => 1,
            last_tick           => "2016-07-20 06:33:16",
            boost_enabled       => 0,
            needs_recalc        => 0,
            needs_surface_refresh => 0,
            restrict_coverage   => 0,
            plots_available     => 10,
            surface_version     => 1,
            max_berth           => 5,
            unhappy_date        => "2016-07-20 06:44:40",
            unhappy             => 0,
            propaganda_boost    => 0,
            neutral_entry       => 0,
            notes               => "hello world",
        },
        requires => {
            my_empire => {
                our   => 'empire_id',
                their => 'id',
            },
            my_star => {
                our   => 'star_id',
                their => 'id',
            },
        },
    }
);

sub get_definition {
    my ($self, $name) = @_;

    return $definitions{$name};
}

sub all_fixture_names { return keys %definitions };

__PACKAGE__->meta->make_immutable;
1;

