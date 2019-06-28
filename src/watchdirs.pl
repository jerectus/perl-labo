#!/usr/bin/perl
use strict;
use warnings;

require "syscall.ph";

sub _inotify_init {
    syscall(&SYS_inotify_init);
}

sub _close {
    my ($fd) = @_;
    syscall(&SYS_close, $fd);
}

sub _inotify_add_watch {
    my ($fd, $dir, $mode) = @_;
    syscall(&SYS_inotify_add_watch, $fd, $dir, $mode);
}

sub _inotify_rm_watch {
    my ($fd, $wd) = @_;
    syscall(&SYS_inotify_rm_watch, $fd, $wd);
}

sub _read {
    my ($fd, $buf_size) = @_;
    my $buf = ' ' x $buf_size;
    my $n = syscall(&SYS_read, $fd, $buf, $buf_size);
    return $n < 0 ? undef : substr($buf, 0, $n);
}

sub main {
    my $fd = _inotify_init();
    print "fd=$fd\n";

    my $wd = _inotify_add_watch($fd, ".", 8);
    print "wd=$wd\n";

    my $buf = _read($fd, 512);
    print "len=", length($buf), ", buf=", unpack("H*", $buf), "\n";

    _inotify_rm_watch($fd, $wd);
    _close($fd);
}

main();
