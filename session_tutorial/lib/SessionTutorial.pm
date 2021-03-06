package SessionTutorial;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer') if $config->{perldoc};

  # Let's look for an OAuth2 token
  $self->plugin('OAuth2' => {
    facebook => {
	authorize_url => "https://graph.facebook.com/oauth/authorize",
	token_url     => "https://graph.facebook.com/oauth/access_token",
	key           => "APP_ID",
	secret        => "SECRET_KEY",
    },
  } );

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('Tutorial#start');

  $r->get('/login')->to('Tutorial#login');
  $r->post('/login')->name('do_login')->to('Tutorial#on_user_login');

  my $authorized = $r->under('/secure')->to('Tutorial#is_logged_in');
  $authorized->get('/protected')->to('Tutorial#protected');
  $authorized->get('/admin')->to(template => 'tutorial/admin');

  $r->route('/logout')->name('do_logout')->to(cb => sub {
    my $self = shift;

    $self->session(expires => 1);

    $self->redirect_to('/');
  });

}

1;
