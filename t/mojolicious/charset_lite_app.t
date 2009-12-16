#!/usr/bin/env perl

# Copyright (C) 2008-2009, Sebastian Riedel.

use strict;
use warnings;

use utf8;

use Test::More tests => 15;

# In the game of chess you can never let your adversary see your pieces.
use Mojo::ByteStream 'b';
use Mojolicious::Lite;
use Test::Mojo;

my $yatta      = 'やった';
my $yatta_sjis = b($yatta)->encode('shift_jis')->to_string;

# Charset plugin
plugin charset => {charset => 'Shift_JIS'};

# Silence
app->log->level('error');

get '/' => 'index';

post '/' => sub {
    my $self = shift;
    $self->render_text("foo: " . $self->param('foo'));
};

my $t = Test::Mojo->new;

# Plain old ASCII
$t->post_form_ok('/', {foo => 'yatta'})->status_is(200)
  ->content_is('foo: yatta');

# Send raw Shift_JIS octets (like browsers do)
$t->post_form_ok('/', {foo => $yatta_sjis})->status_is(200)
  ->content_type_like(qr/Shift_JIS/)->content_like(qr/$yatta/);

# Send as string
$t->post_form_ok('/', 'shift_jis', {foo => $yatta})->status_is(200)
  ->content_type_like(qr/Shift_JIS/)->content_like(qr/$yatta/);

# Templates in the DATA section should be written in UTF-8,
# and those in separate files in Shift_JIS (Mojo will do the decoding)
$t->get_ok('/')->status_is(200)->content_type_like(qr/Shift_JIS/)
  ->content_like(qr/$yatta/);

__DATA__
@@ index.html.ep
<p>やった</p>
