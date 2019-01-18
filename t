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
my $isTaskdirExplicit = 0;
my $showColors;
my $showHelp;
#my $VERSION = "0.8.0";

sub findTasksDir {
	my $dir = shift;

	until (-e "$dir/$list") {
		$dir = "$dir/../";
	}

	return $dir;
}

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
	open(my $in, "<", "$taskdir/$list") or return 0;
	my @stack = (); #stack of (indentation, text) tuples
	push(@stack, [-1,""]);
	my $line = 1;

	while (<$in>) {
		if (/^(\s*)\[(.)\] (.*)/) {
			#$1: indentation, $2: mode, $3: text
			my $len = length $1;
			#pop all the previously items pushed to stack
			# that were children of my previously encountered siblings
			while ($len < $stack[-1][0]) {
				pop(@stack);
			}
			#if I am the same level as the last item in stack (it is my sibling)
			#	then overwrite it in the stack
			#otherwise I must be its child
			if ($len == $stack[-1][0]) {
				@stack[-1] = [$len, $3];
			} else {
				push(@stack, [$len, $3]);
			}

			print("$line. $1$3\n") if ($2 eq " ");
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
	"t|task-dir=s" => sub{
		$taskdir = $_[1];
		$isTaskdirExplicit = 1;
	},
	"h|help" => \$showHelp
) or pod2usage(2);

pod2usage(1) if $showHelp;

if (!$isTaskdirExplicit) {
	$taskdir = findTasksDir($taskdir);
}

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

=head VERSION

version 0.8.0

=head SYNOPSIS

t [OPTIONS] [NEW TASK]

=head1 OPTIONS

=over 4

=item (-f | --finish) TASK_ID

Finishes task with id.

=item (-l | --list) name

Uses given filename instead of "TODO.txt".

=item (-t | --task-dir) name

Uses task file in given directory.
If not given, the file will be searched in current director or in the parent directories.

=item (-h | --help)

Show help

=back
