use 5.16.0;
use Data::Dumper qw<Dumper>;
use XML::Simple;
use Box2D;
use SDL;
use SDL::Video;
use SDLx::App;
use SDL::Events ':all';
use SDLx::Surface;

my $screen_width = 800;
my $screen_height = 600;

my $app = SDLx::App->new(
    dt => 1.0/60.0,
    min_t => 1.0/120.0,
    width => $screen_width, height => $screen_height, flags => SDL_DOUBLEBUF | SDL_HWSURFACE, eoq => 1
);

my $pim = 64;
my $vec = Box2D::b2Vec2->new(0,-9.81);
my $world = Box2D::b2World->new($vec, 1);

$app->update;

my @objects;

my $ground = {};
$$ground{x} = 400;
$$ground{y} = 32;
$$ground{width} = 600;
$$ground{height} = 32;
$$ground{bodydef} = Box2D::b2BodyDef->new();
$$ground{bodydef}->position->Set($$ground{x} / $pim, $$ground{y} / $pim);
$$ground{shape} = Box2D::b2PolygonShape->new();
$$ground{color} = [128, 128, 128, 255];
$$ground{shape}->SetAsBox(($$ground{width}/$pim)/2, ($$ground{height}/$pim)/2);
$$ground{body} = $world->CreateBody($$ground{bodydef});
$$ground{fixture} = $$ground{body}->CreateFixture($$ground{shape}, 0.0);

my $ground2 = {};
$$ground2{x} = 400;
$$ground2{y} = 180;
$$ground2{width} = 350;
$$ground2{height} = 32;
$$ground2{bodydef} = Box2D::b2BodyDef->new();
$$ground2{bodydef}->position->Set($$ground2{x} / $pim, $$ground2{y} / $pim);
$$ground2{shape} = Box2D::b2PolygonShape->new();
$$ground2{color} = [128, 128, 0, 255];
$$ground2{shape}->SetAsBox(($$ground2{width}/$pim)/2, ($$ground2{height}/$pim)/2);
$$ground2{body} = $world->CreateBody($$ground2{bodydef});
$$ground2{fixture} = $$ground2{body}->CreateFixture($$ground2{shape}, 0.0);

my $spr;
$$spr{lolo}{stand}{right} = SDLx::Surface->load('sprites/lolo_stand_right.bmp');
$$spr{lolo}{stand}{left} = SDLx::Surface->load('sprites/lolo_stand_left.bmp');

my $player = {};
$$player{x} = 400;
$$player{y} = 512;
$$player{width} = 32;
$$player{height} = 32;
$$player{bodydef} = Box2D::b2BodyDef->new();
$$player{bodydef}->position->Set($$player{x} / $pim, $$player{y} / $pim);
$$player{bodydef}->type(Box2D::b2_dynamicBody);
$$player{shape} = Box2D::b2CircleShape->new();
$$player{color} = [255, 0, 0, 255];
$$player{shape}->m_radius(($$player{width}/$pim)/2);
$$player{body} = $world->CreateBody($$player{bodydef});
$$player{body}->SetLinearDamping(0.5);
$$player{body}->SetFixedRotation(0);
$$player{fixture} = $$player{body}->CreateFixture($$player{shape}, 0.0);
$$player{fixture}->SetFriction(0);
$$player{fixture}->SetRestitution(0);
$$player{sprite} = $$spr{lolo}{stand}{right};
$$player{direction} = 'right';
$$player{stance} = 'stand';

my $left_keydown;
my $right_keydown;
my $space_keydown;
my $space_already_down;

$app->add_event_handler(
    sub {
        my ($event, $app) = @_;
        my $type = $event->type;
        SDL::Events::pump_events();
        my $keys_ref = SDL::Events::get_key_state;
        $left_keydown  = $keys_ref->[SDLK_LEFT];
        $right_keydown = $keys_ref->[SDLK_RIGHT];
        $space_keydown = $keys_ref->[SDLK_SPACE];
    }
);

$app->add_move_handler(
    sub {
        my ($step, $app, $t) = @_;
        if ($left_keydown) {
            $$player{fixture}->SetFriction(0);
            $$player{direction} = 'left';
            $$player{body}->ApplyForce(Box2D::b2Vec2->new(-400*$step/$pim,0), $$player{body}->GetWorldCenter);
        } elsif ($right_keydown) {
            $$player{direction} = 'right';
            $$player{fixture}->SetFriction(0);
            $$player{body}->ApplyForce(Box2D::b2Vec2->new( 400*$step/$pim,0), $$player{body}->GetWorldCenter);
        } else {
            $$player{fixture}->SetFriction(1);
        }
        if ($space_keydown) {
            unless ($space_already_down) {
                $$player{body}->ApplyLinearImpulse(Box2D::b2Vec2->new(0, 800*$step/$pim), $$player{body}->GetWorldCenter);
            }
            $space_already_down = 1;
        } else {
            $space_already_down = 0;
        }
    }
);

$app->add_show_handler(
    sub {
        $world->Step(1.0/60.0, 6, 3);
        $world->ClearForces;
        $app->draw_rect([0, 0, $screen_width, $screen_height], [0, 0, 0, 255]);

        for my $object ($ground, $ground2) {
            my $pos = $$object{body}->GetPosition;
            my ($x, $y) = ($pos->x*$pim, $pos->y*$pim);
            my ($w, $h) = ($$object{width}, $$object{height});
            $app->draw_rect([$x - ($w/2), $screen_height - $y - ($h/2), $w, $h], $$object{color});
        }
        
        my $pos = $$player{body}->GetPosition;
        my ($x, $y) = ($pos->x*$pim, $pos->y*$pim);
        my ($w, $h) = ($$player{width}, $$player{height});
        $$player{sprite} = $$spr{lolo}{$$player{stance}}{$$player{direction}};
        $$player{sprite}->blit($app, undef, [$x - $w/2, $screen_height - $y - $h/2]);

        $app->update;
    }
);

$app->run;

#say Dumper XML::Simple::XMLin("maps/plage.tmx");
