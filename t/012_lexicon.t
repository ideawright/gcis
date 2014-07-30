#!perl

use FindBin;
use lib $FindBin::Bin;
use tinit;
use Test::More;
use Test::MBD qw/-autostart/;
use Test::Mojo;

use_ok "Tuba";

my $t = Test::Mojo->new("Tuba");

$t->post_ok("/login" => form => { user => "unit_test", password => "anything" })->status_is(302);

my $gcid = "/organization/european-space-agency";

#  Send lexicon, term and context to map to a GCID.
$t->post_ok("/lexicon/ceos" => {Accept => "application/json"} => json =>
    {term => 'ESA', context => "Agency", gcid => $gcid})
  ->status_is(200)
  ->json_is({status => 'ok'});

$t->get_ok("/lexicon/ceos/Agency/ESA")
  ->status_is(303)                  # 303 == "See Other"
  ->header_is(Location => $gcid)
  ->content_like(qr/\Q$gcid\E/);    # The content SHOULD have a link, says RFC 2616

$t->delete_ok("/lexicon/ceos/Agency/ESA")
  ->status_is(200);

$t->get_ok("/lexicon/ceos/Agency/ESA")
  ->status_is(404);

done_testing();

1;

