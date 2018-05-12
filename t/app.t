use Test::More;
use Test::Mojo;


use Mojolicious::Lite;

  plugin 'PromiseActions';

get '/' => sub {
  my $c=shift;
  app->ua->get_p('ifconfig.me/all.json')->then(sub {
    warn "WOW MOM";
    $c->render(text=>shift->res->json('/ip_addr'));
  });
};

my $t=Test::Mojo->new;

$t->get_ok('/')->status_is('200')->content_like(qr/^(\d+\.){4}$/);
done_testing;
