BEGIN { $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll' }
use Test::More;
use Test::Mojo;

use Mojolicious::Lite;
use Mojo::Promise;

plugin 'PromiseActions';

my $r = app->routes;

my $ok;
$r->under('/normal' => sub {
  my $c = shift;
  return 1 if $ok;
  $c->render(text => 'nok');
  return 0;
})->get('/' => { text => 'ok' });

my $t = Test::Mojo->new;

# tests to be sure that regular unders work as expected

$ok = 1;
$t->get_ok('/normal')
  ->status_is(200)
  ->content_is('ok');

$ok = 0;
$t->get_ok('/normal')
  ->status_is(200)
  ->content_is('nok');

#TODO add tests for returning promises

done_testing;

