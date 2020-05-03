package Slack::WebAPI;

use strict;
use warnings;
use utf8;
use Encode 'encode_utf8';
use feature 'say';
use File::Temp 'tempfile';
use HTTP::Request::Common;
use Furl;
use Parallel::ForkManager;
use Mouse;

has token => (is => 'ro', isa => 'Str');
has channel_id => (is => 'ro', isa => 'Str');

my $pm = new Parallel::ForkManager(16);
my $http = new Furl;

sub notify {
  my ($self, $status) = @_;

  $pm->start and return;

  my $reply_status = $status->{in_reply_to_id};
  my $reply_url = $reply_status
                  ? "\n\nIn reply to\nhttps://$ENV{MPA_MSTDN_DOMAIN_NAME}/web/status/$reply_status"
                  : '';

  say encode_utf8 $status->{account}{display_name}.' ('.$status->{account}{acct}.')';
  say encode_utf8 $status->{content};
  say encode_utf8 $status->{created_at};

  eval {
    $http->post(
      'https://slack.com/api/chat.postMessage',
      [],
      [
        token => $ENV{MPA_SLACK_TOKEN},
        channel => $ENV{MPA_SLACK_CHANNEL_ID},
        icon_url => $status->{account}{avatar},
        username => encode_utf8 $status->{account}{display_name}.' ('.$status->{account}{acct}.')',
        text => encode_utf8("Status ID: ".$status->{id}."\n\n".$status->{content}.$reply_url."\n\n".$status->{created_at})
      ]
    );
  };
  warn "WARNING: $@" if $@;

  $pm->finish;
}

sub upload {
  my ($self, $media_attachments) = @_;

  for (@$media_attachments) {
    $pm->start and next;

    say $_->{url};

    my $binary = $http->get($_->{url});
    die 'Cannot fetch image: '.$_->{url}
      if grep {$_ eq $binary->code} (404, 500);
    my ($tmpfh, $tmpfile) = tempfile(UNLINK => 1);
    say $tmpfh $binary->content;
    close $tmpfh;
    eval {
      $http->request(POST (
        'https://slack.com/api/files.upload',
        'Content-Type' => 'form-data',
        'Content' => [
          token => $ENV{MPA_SLACK_TOKEN},
          channels => $ENV{MPA_SLACK_CHANNEL_ID},
          file => [$tmpfile]
        ]
      ));
    };
    warn "WARNING: $@" if $@;
    unlink $tmpfile;

    $pm->finish;
  }

}