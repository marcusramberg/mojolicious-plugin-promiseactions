package Mojolicious::Plugin::PromiseActions;

use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Promise;
use Scalar::Util 'blessed';

our $VERSION = '0.07';

sub register {
  my ($elf, $app, $config) = @_;
  $app->hook(
    around_action => sub {
      my ($next, $c) = @_;
      my $want = wantarray;
      my @args;
      if ($want) { @args    = $next->() }
      else       { $args[0] = $next->() }
      if (blessed($args[0]) && $args[0]->can('then')) {
        my $tx = $c->render_later->tx;
        my $p = Mojo::Promise->resolve($args[0]);
        $p->catch(sub { $c->reply->exception($_[0]) and undef $tx })->wait;
      }
      return $want ? @args : $args[0];
    }
  );
}

1;

=head1 NAME

Mojolicious::Plugin::PromiseActions - Automatic async and error handling for Promises

=head1 SYNOPSIS

  plugin 'PromiseActions';

  get '/' => sub {
    my $c=shift;
    app->ua->get_p('ifconfig.me/all.json')->then(sub {
      $c->render(text=>shift->res->json('/ip_addr'));
    });
  };

=head1  METHODS

=head2 register

Sets up a around_dispatch hook to disable automatic rendering and
add a default catch callback to render an exception page when
actions return a L<Mojo::Promise>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018, Marcus Ramberg.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=head1 SEE ALSO

L<https://github.com/kraih/mojo>, L<Mojolicious::Guides>,
L<Mojo::Promise>, L<Mojolicious::Plugin>

=cut
