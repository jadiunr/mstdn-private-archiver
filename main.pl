use strict;
use warnings;
use utf8;
use Time::Piece;
use Encode;
use Furl;
use JSON::XS;

use lib 'lib';
use Slack::WebAPI;

$|=1;

my $domain = $ENV{MPA_DOMAIN_NAME};
my $access_token = $ENV{MPA_ACCESS_TOKEN};
my $account_id = $ENV{MPA_ACCOUNT_ID};

my $furl = Furl->new(headers => ['Authorization' => "Bearer $access_token"]);
my $slack = Slack::WebAPI->new(
    token => $ENV{MPA_SLACK_TOKEN},
    channel_id => $ENV{MPA_SLACK_CHANNEL_ID}
);

while(1) {
    my $max_id = '9223372036854775807'; #7FFFFFFFFFFFFFFF
    my $all_statuses = [];
    my $current_time = localtime;

    for (1..12) {
        my $statuses = decode_json($furl->get("https://${domain}/api/v1/accounts/${account_id}/statuses?limit=40&exclude_replies=false&max_id=${max_id}")->content);
        push(@$all_statuses, @$statuses);
        $max_id = $statuses->[-1]{id};
    }

    for my $status (reverse @$all_statuses) {
        if($status->{visibility} eq 'private') {
            my $created_at = Time::Piece->strptime(substr($status->{created_at}, 0, -5), "%FT%T");
            my $time_diff = $current_time - $created_at;
            if($time_diff->hours > 12) {
                $slack->notify($status);
                my $media_attachments = $status->{media_attachments};
                $slack->upload($media_attachments) if $media_attachments;

                $furl->delete("https://${domain}/api/v1/statuses/$status->{id}");
                print "Deleted toot ID: $status->{id}\n";

                sleep 120;
            }
        }
    }
    sleep 300;
}
