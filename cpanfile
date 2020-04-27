requires 'Furl';
requires 'IO::Socket::SSL';
requires 'JSON::XS';
requires 'Term::ReadLine::Perl';

on 'develop' => sub {
    requires 'Pry';
}