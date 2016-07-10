use lib '../lib';
use Test::More tests => 10;
use Test::Deep;
use Data::Dumper;
use 5.010;

use TestHelper;
TestHelper->clear_all_test_empires;

my $tester = TestHelper->new->generate_test_empire->build_infrastructure;
my $db = KA->db;
my $session_id = $tester->session->id;
my $empire_id = $tester->empire->id;
my $result;

my $university = KA->db->resultset('KA::DB::Result::Building')->new({
	x               => -5,
	y               => -5,
	class           => 'KA::DB::Result::Building::University',
	level           => 5,
});
$tester->empire->home_planet->build_building($university);
$university->finish_upgrade;
$tester->empire->university_level(6);
$tester->empire->update;

my $uid = $university->id;

$result = $tester->post('university', 'view', [$session_id, $uid]);
is($result->{result}{building}{level}, 6, "made it to level 6");
my $empire = $db->resultset('KA::DB::Result::Empire')->find($empire_id);
is($empire->university_level, 6, 'empire university level was upgraded');

for my $level (7..10) {
    $result = $tester->post('university', 'upgrade', [$session_id, $uid]);    
    $db->resultset('KA::DB::Result::Building')->find($uid)->finish_upgrade;
    KA->cache->delete('upgrade_contention_lock', $uid);
    
    $result = $tester->post('university', 'view', [$session_id, $uid]);
    is($result->{result}{building}{level}, $level, "made it to level ".$level);
    $empire = $db->resultset('KA::DB::Result::Empire')->find($empire_id);
    is($empire->university_level, $level, 'empire university level was upgraded');    
}

END {
    TestHelper->clear_all_test_empires;
}
