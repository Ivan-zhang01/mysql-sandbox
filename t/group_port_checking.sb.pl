#
# test for replication and group sandbox port checking
#
my $TEST_VERSION = $ENV{TEST_VERSION};
my ($bare_version, $version) = get_bare_version ($TEST_VERSION);
my $SANDBOX_HOME= $ENV{SANDBOX_HOME} || "$ENV{HOME}/sandboxes";
my $custom_port=11000;
my $custom_port1= $custom_port + 1;
my $custom_port2= $custom_port + 2;
my $custom_port5= $custom_port + 5;
my $custom_port6= $custom_port + 6;

ok_exec ({
command     => "make_multiple_sandbox --sandbox_base_port=$custom_port $TEST_VERSION",
expected    => "group directory installed",
msg         => "group 1 started",
});

ok_sql({
path        => "$SANDBOX_HOME/multi_msb_$version/node1",
query       => "show variables like 'port'",
expected    => "$custom_port1",
msg         => "right port on node1",
});

ok_sql({
path        => "$SANDBOX_HOME/multi_msb_$version/node2",
query       => "show variables like 'port'",
expected    => "$custom_port2",
msg         => "right port on node2",
});

ok_exec ({
command     => "make_multiple_sandbox --sandbox_base_port=$custom_port --group_directory=gsb --check_base_port $TEST_VERSION",
expected    => "group directory installed",
msg         => "group 2 started",
});

ok_sql({
path        => "$SANDBOX_HOME/gsb/node1",
query       => "show variables like 'port'",
expected    => "$custom_port5",
msg         => "right port on node1 (after check)",
});

ok_sql({
path        => "$SANDBOX_HOME/gsb/node2",
query       => "show variables like 'port'",
expected    => "$custom_port6",
msg         => "right port on node2 (after check)",
});

ok_exec ({
command     => "make_replication_sandbox --sandbox_base_port=6000 $TEST_VERSION",
expected    => "replication directory installed",
msg         => "replication started",
});

ok_sql({
path        => "$SANDBOX_HOME/rsandbox_$version/master",
query       => "show variables like 'port'",
expected    => "6000",
msg         => "right port on master",
});

ok_sql({
path        => "$SANDBOX_HOME/rsandbox_$version/node1",
query       => "show variables like 'port'",
expected    => "6001",
msg         => "right port on node1",
});

ok_exec ({
command     => "make_replication_sandbox --sandbox_base_port=6000 --replication_directory=rsb --check_base_port $TEST_VERSION",
expected    => "replication directory installed",
msg         => "replication started",
});

ok_sql({
path        => "$SANDBOX_HOME/rsb/master",
query       => "show variables like 'port'",
expected    => "6003",
msg         => "right port on master (after check)",
});

ok_sql({
path        => "$SANDBOX_HOME/rsb/node1",
query       => "show variables like 'port'",
expected    => "6004",
msg         => "right port on node1 (after check)",
});

ok_exec ({
command     => "sbtool -o delete -s $SANDBOX_HOME/rsandbox_$version/",
expected    => "has been removed",
msg         => "replication 1 stopped and removed",
});

ok_exec ({
command     => "sbtool -o delete -s $SANDBOX_HOME/rsb/",
expected    => "has been removed",
msg         => "replication 2 stopped and removed",
});

ok_exec ({
command     => "sbtool -o delete -s $SANDBOX_HOME/multi_msb_$version",
expected    => "has been removed",
msg         => "group 1 stopped and removed",
});

ok_exec ({
command     => "sbtool -o delete -s $SANDBOX_HOME/gsb/",
expected    => "has been removed",
msg         => "group 2 stopped and removed",
});
