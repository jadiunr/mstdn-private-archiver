requires 'Furl';
requires 'IO::Socket::SSL';
requires 'JSON::XS';
requires 'Parallel::ForkManager';
requires 'Mouse';
requires 'HTTP::Request::Common';

on 'develop' => sub {
    requires 'Term::ReadLine::Gnu';
    requires 'Pry';
}