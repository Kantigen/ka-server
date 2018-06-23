use strict;
use lib ('/home/keno/ka-server/lib');
use 5.010;
use Config::JSON;
use Plack::App::URLMap;
use Log::Log4perl;
use Log::Any::Adapter;
use Plack::Builder;
use JSON qw(encode_json);

use KA;

$|=1;

my $config = Config::JSON->new("/home/keno/ka-server/etc/keno-antigen.conf");
my $db = KA->db;

use Log::Log4perl;
Log::Log4perl::init('/home/keno/ka-server/etc/log4perl.conf');
Log::Any::Adapter->set('Log::Log4perl');

my $offline = [ 500,
    [ 'Content-Type' => 'application/json-rpc' ],
    [ encode_json( {
        "jsonrpc" => "2.0",
        "error" => {
            "code" => -32000,
            "message" => "The server is offline for maintenance.",
        }
    } ) ],
];

my $gameover = [ 500,
    [ 'Content-Type' => 'application/json-rpc' ],
    [ encode_json( {
        "jsonrpc" => "2.0",
        "error" => {
            "code" => 1200,
            "message" => "Game Over",
            "data" => "http://community.lacunaexanse.com/wiki/hall-of-fame",
        }
    } ) ],
];

# Compare the current DB Version with the SQL patch files
my $db = KA->db;
my $db_version = `./dbupdate.pl database_version 2> /dev/null`;
my $schema_version = `./dbupdate.pl schema_version 2> /dev/null`;

if ($db_version =~ /^\s*$/)
{
    die "Please run the 'init-keno.pl' script to create your initial database (1)\n";
}
elsif ($db_version != $schema_version)
{
    system('./dbupdate.pl upgrade');
}

print STDERR "Latest version is [".$db_version->major_version."] [".$db_version->minor_version."]\n";

# Check the latest patch file in the update directory

my $app = builder {
    if ($^O ne 'darwin' && not defined $ENV{'KA_NO_MIDDLEWARE'} ) {
        ##Wrapper to fully enable size limiting.  The psgix.harakiri has to be set for it to work.
        enable sub {
            my $app = shift;
            return sub {
                my ($env) = @_;
                $env->{'psgix.harakiri'} = 1;
                return $app->($env);
            }
        };
        enable "Plack::Middleware::SizeLimit" => (
            max_unshared_size_in_kb => '51200', # 50MB
            max_process_size_in_kb => '125000', # 125MB
            check_every_n_requests => 3,
        );
        enable "Plack::Middleware::LightProfile";
    }  
    enable 'CrossOrigin',
        origins => '*', methods => ['GET', 'POST'], max_age => 60*60*24*30, headers => '*';

    enable sub {
        my $app = shift;
        return sub {
            my ($env) = @_;
            my $status = KA->cache->get('server','status');
            if ($status eq 'Offline') {
                return $offline;
            }
            elsif ($status eq 'Game Over') {
                return $gameover;
            }
            $app->($env);
        }
    };

    mount '/starman_ping' => sub { [200, [ 'Content-Type' => 'text/plain'], [ 'pong' ]] };

    mount "/map"            => KA::RPC::Map->new->to_app;
    mount "/body"           => KA::RPC::Body->new->to_app;
    mount "/empire"         => KA::RPC::Empire->new->to_app;
    mount "/alliance"       => KA::RPC::Alliance->new->to_app;
    mount "/inbox"          => KA::RPC::Inbox->new->to_app;
    mount "/stats"          => KA::RPC::Stats->new->to_app;
    mount "/pay"            => KA::Web::Pay->new->to_app;
    mount "/chat"           => KA::Web::Chat->new->to_app;
    mount "/chat/rpc"       => KA::RPC::Chat->new->to_app;
    mount "/entertainment/vote" => KA::Web::EntertainmentVote->new->to_app;
    mount "/announcement"   => KA::Web::Announcement->new->to_app;
    mount "/facebook"       => KA::Web::Facebook->new->to_app;
    mount "/apikey"         => KA::Web::ApiKey->new->to_app;
    mount "/essentia-code"  => KA::RPC::EssentiaCode->new->to_app;
    mount "/captcha"        => KA::RPC::Captcha->new->to_app;

    for my $building (qw(
        KA::RPC::Building::Shipyard
        KA::RPC::Building::SpacePort
        KA::RPC::Building::Intelligence
        KA::RPC::Building::IntelTraining
        KA::RPC::Building::MayhemTraining
        KA::RPC::Building::PoliticsTraining
        KA::RPC::Building::TheftTraining
        KA::RPC::Building::Security
        KA::RPC::Building::Trade
        KA::RPC::Building::Transporter
        KA::RPC::Building::Archaeology
        KA::RPC::Building::DistributionCenter
        KA::RPC::Building::SAW
        KA::RPC::Building::AtmosphericEvaporator
        KA::RPC::Building::GreatBallOfJunk
        KA::RPC::Building::JunkHengeSculpture
        KA::RPC::Building::MetalJunkArches
        KA::RPC::Building::PyramidJunkSculpture
        KA::RPC::Building::SpaceJunkPark
        KA::RPC::Building::ThemePark
        KA::RPC::Building::BlackHoleGenerator
        KA::RPC::Building::TheDillonForge
        KA::RPC::Building::HallsOfVrbansk
        KA::RPC::Building::GratchsGauntlet
        KA::RPC::Building::KasternsKeep
        KA::RPC::Building::SubspaceSupplyDepot
        KA::RPC::Building::SupplyPod
        KA::RPC::Building::PantheonOfHagness
        KA::RPC::Building::Capitol
        KA::RPC::Building::Stockpile
        KA::RPC::Building::Algae
        KA::RPC::Building::Apple
        KA::RPC::Building::Bean
        KA::RPC::Building::Beeldeban
        KA::RPC::Building::Bread
        KA::RPC::Building::Burger
        KA::RPC::Building::Cheese
        KA::RPC::Building::Chip
        KA::RPC::Building::Cider
        KA::RPC::Building::Corn
        KA::RPC::Building::CornMeal
        KA::RPC::Building::EssentiaVein
        KA::RPC::Building::Volcano
        KA::RPC::Building::MassadsHenge
        KA::RPC::Building::LibraryOfJith
        KA::RPC::Building::NaturalSpring
        KA::RPC::Building::OracleOfAnid
        KA::RPC::Building::TempleOfTheDrajilites
        KA::RPC::Building::GeoThermalVent
        KA::RPC::Building::InterDimensionalRift
        KA::RPC::Building::CitadelOfKnope
        KA::RPC::Building::CrashedShipSite
        KA::RPC::Building::KalavianRuins
        KA::RPC::Building::Grove
        KA::RPC::Building::Sand
        KA::RPC::Building::Lagoon
        KA::RPC::Building::Crater
        KA::RPC::Building::Dairy
        KA::RPC::Building::Denton
        KA::RPC::Building::Development
        KA::RPC::Building::Embassy
        KA::RPC::Building::EnergyReserve
        KA::RPC::Building::Entertainment
        KA::RPC::Building::Espionage
        KA::RPC::Building::Fission
        KA::RPC::Building::FoodReserve
        KA::RPC::Building::Fusion
        KA::RPC::Building::DeployedBleeder
        KA::RPC::Building::GasGiantLab
        KA::RPC::Building::GasGiantPlatform
        KA::RPC::Building::Geo
        KA::RPC::Building::Hydrocarbon
        KA::RPC::Building::Lapis
        KA::RPC::Building::Malcud
        KA::RPC::Building::Mine
        KA::RPC::Building::MiningMinistry
        KA::RPC::Building::Network19
        KA::RPC::Building::Observatory
        KA::RPC::Building::OreRefinery
        KA::RPC::Building::OreStorage
        KA::RPC::Building::Pancake
        KA::RPC::Building::Park
        KA::RPC::Building::Pie
        KA::RPC::Building::PlanetaryCommand
        KA::RPC::Building::Potato
        KA::RPC::Building::Propulsion
        KA::RPC::Building::Oversight
        KA::RPC::Building::RockyOutcrop
        KA::RPC::Building::Lake
        KA::RPC::Building::Shake
        KA::RPC::Building::Singularity
        KA::RPC::Building::Soup
        KA::RPC::Building::Syrup
        KA::RPC::Building::TerraformingLab
        KA::RPC::Building::GeneticsLab
        KA::RPC::Building::TerraformingPlatform
        KA::RPC::Building::University
        KA::RPC::Building::WasteEnergy
        KA::RPC::Building::WasteExchanger
        KA::RPC::Building::WasteRecycling
        KA::RPC::Building::WasteSequestration
        KA::RPC::Building::WasteDigester
        KA::RPC::Building::WasteTreatment
        KA::RPC::Building::WaterProduction
        KA::RPC::Building::WaterPurification
        KA::RPC::Building::WaterReclamation
        KA::RPC::Building::WaterStorage
        KA::RPC::Building::Wheat
        KA::RPC::Building::Beach1
        KA::RPC::Building::Beach2
        KA::RPC::Building::Beach3
        KA::RPC::Building::Beach4
        KA::RPC::Building::Beach5
        KA::RPC::Building::Beach6
        KA::RPC::Building::Beach7
        KA::RPC::Building::Beach8
        KA::RPC::Building::Beach9
        KA::RPC::Building::Beach10
        KA::RPC::Building::Beach11
        KA::RPC::Building::Beach12
        KA::RPC::Building::Beach13
        KA::RPC::Building::PilotTraining
        KA::RPC::Building::MissionCommand
        KA::RPC::Building::CloakingLab
        KA::RPC::Building::MunitionsLab
        KA::RPC::Building::LuxuryHousing
        KA::RPC::Building::Fissure
        KA::RPC::Building::Ravine
        KA::RPC::Building::AlgaePond
        KA::RPC::Building::LapisForest
        KA::RPC::Building::BeeldebanNest
        KA::RPC::Building::MalcudField
        KA::RPC::Building::SSLa
        KA::RPC::Building::SSLb
        KA::RPC::Building::SSLc
        KA::RPC::Building::SSLd
        KA::RPC::Building::AmalgusMeadow
        KA::RPC::Building::DentonBrambles
        KA::RPC::Building::MercenariesGuild
        KA::RPC::Building::StationCommand
        KA::RPC::Building::OperaHouse
        KA::RPC::Building::ArtMuseum
        KA::RPC::Building::CulinaryInstitute
        KA::RPC::Building::IBS
        KA::RPC::Building::Warehouse
        KA::RPC::Building::Parliament
        KA::RPC::Building::PoliceStation
        KA::RPC::Building::LCOTa
        KA::RPC::Building::LCOTb
        KA::RPC::Building::LCOTc
        KA::RPC::Building::LCOTd
        KA::RPC::Building::LCOTe
        KA::RPC::Building::LCOTf
        KA::RPC::Building::LCOTg
        KA::RPC::Building::LCOTh
        KA::RPC::Building::LCOTi
    )) {
        mount $building->new->to_app_with_url;
    }

    mount '/admin' => builder {
        enable "Auth::Basic", authenticator => sub {
            my ($username, $password) = @_;
            return 0 unless $username;
            my $empire = KA->db->resultset('Empire')->search({name => $username, is_admin => 1})->first;
            return 0 unless defined $empire;
            return $empire->is_password_valid($password);
        };
        KA::Web::Admin->new->to_app;
    };

    mount "/missioncurator" => builder {
        enable "Auth::Basic", authenticator => sub {
            my ($username, $password) = @_;
            return 0 unless $username;
            my $empire = KA->db->resultset('Empire')->search({name => $username, is_mission_curator => 1})->first;
            return 0 unless defined $empire;
            return $empire->is_password_valid($password);
        };
        KA::Web::MissionCurator->new->to_app;
    };

};

say "Server Started";

$app;

