package main;
#
# Copyright 2015 Comcast Cable Communications Management, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use DBI;
use strict;
use warnings;
no warnings 'once';
use warnings 'all';
use Test::TestHelper;

#no_transactions=>1 ==> keep fixtures after every execution, beware of duplicate data!
#no_transactions=>0 ==> delete fixtures after every execution

BEGIN { $ENV{MOJO_MODE} = "test" }

my $schema = Schema->connect_to_database;
my $dbh    = Schema->database_handle;
my $t      = Test::Mojo->new('TrafficOps');

Test::TestHelper->unload_core_data($schema);
Test::TestHelper->load_core_data($schema);

ok $t->post_ok( '/login', => form => { u => Test::TestHelper::ADMIN_USER, p => Test::TestHelper::ADMIN_USER_PASSWORD } )->status_is(302)
	->or( sub { diag $t->tx->res->content->asset->{content}; } );

$t->get_ok('/api/1.1/roles.json?orderby=name')->status_is(200)->or( sub { diag $t->tx->res->content->asset->{content}; } )
	->json_is( "/response/0/id", "4" )->json_is( "/response/0/description", "super-user" )->json_is( "/response/0/name", "admin" )
	->json_is( "/response/0/privLevel", "30" )->json_is( "/response/1/id", "1" )->json_is( "/response/1/description", "block all access" )
	->json_is( "/response/1/name", "disallowed" )->json_is( "/response/1/privLevel", "0" )->json_is( "/response/2/id", "7" )
	->json_is( "/response/2/description", "migrations User" )->json_is( "/response/2/name", "migrations" )->json_is( "/response/2/privLevel", "20" )
	->json_is( "/response/3/id", "3" )->json_is( "/response/3/description", "block all access" )->json_is( "/response/3/name", "operations" )
	->json_is( "/response/3/privLevel", "20" )->json_is( "/response/4/id", "6" )->json_is( "/response/4/description", "Portal User" )
	->json_is( "/response/4/name", "portal" )->json_is( "/response/4/privLevel", "2" )->json_is( "/response/5/id", "2" )
	->json_is( "/response/5/description", "block all access" )->json_is( "/response/5/name", "read-only user" )->json_is( "/response/5/privLevel", "10" );

ok $t->get_ok('/logout')->status_is(302)->or( sub { diag $t->tx->res->content->asset->{content}; } );
$dbh->disconnect();
done_testing();