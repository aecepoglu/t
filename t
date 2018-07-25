#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Term::ANSIColor;

my $editMode;
my $finishId = -1;
my $list = "TODO.txt";
my $taskdir = "./";
my $verbose;
my $showColors;
my $showHelp;

sub editTasks {
	if (exists $ENV{"EDITOR"}) {
		system($ENV{"EDITOR"}, "$taskdir/$list");
	} else {
		die "EDITOR not set";
	}
}

sub finishTask {
	print "TODO: finish task with id: $finishId\n";
}

sub listTasks {
	print "listing tasks\n";
	open(my $in, "<", "$taskdir/$list") or die "can't open file";
	my @stack = (); #stack of (indentation, text) tuples
	push(@stack, [-1,""]);
	my $line = 0;

	while (<$in>) {
		if (/^(\s*)\[(.)\] (.*)/) {
			#$1: indentation, $2: mode, $3: text
			my $len = length $1;
			while ($len < $stack[-1][0]) {
				pop(@stack);
			}
			if ($len == $stack[-1][0]) {
				@stack[-1] = [$len, $3];
			} else {
				push(@stack, [$len, $3]);
			}

			print("$line) $1$3\n") if ($2 eq " ");
		}

		$line = $line + 1;
	}

	close $in;
}

sub createTask {
	my $text = shift;
	open(my $out, ">>", "$taskdir/$list") or die "can't open file";
	print $out "[ ] $text\n";
	close $out;
}

Getopt::Long::Configure("bundling");
GetOptions(
	"e|edit" => \$editMode,
	"f|finish=i" => \$finishId,
	"l|list=s" => \$list,
	"t|task-dir=s" => \$taskdir,
	"v|verbose" => \$verbose,
	"h|help" => \$showHelp
) or pod2usage(2);
pod2usage(1) if $showHelp;

if ($editMode) {
	editTasks();
} elsif ($finishId > 0) {
	finishTask();
} elsif ($#ARGV > 0) {
	createTask(join(" ", @ARGV));
} else {
	listTasks();
}



__END__

=head NAME

t - a stupid simple task manager

=head SYNOPSIS

t [OPTIONS] [NEW TASK]

=head1 OPTIONS

=over 4

=item (-f | --finish) TASK_ID

finishes task with id

=item (-l | --list) name

uses given filename instead of "TODO.txt"

=item (-t | --task-dir) name

uses task file in given path rather than "./"

=item (-v | --verbose)

verbose mode on

=item (-h | --help)

show help

=back