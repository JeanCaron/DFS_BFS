#!/usr/bin/perl

use strict;

my $start = "hit";
my $end   = "cog";
my $dict  = [qw / hot dot dog lot log lit lut cig dpt cuc cug hrt hat bat mat mag mog mwg lwt mwt pop puc lug mug /];

sub _shortest_paths {
    my ($start, $end, $dict, $algo) = @_;

    my $results = [];
    my %graph   = ();

    # create the graph of neighbours
    foreach my $word ($start, $end, @$dict) {

        foreach my $neighbour (@$dict, $end) {

            if ($word ne $neighbour) {

                my $same_char = 0;
                my @word_chars = split(//, $word);
                my @neighbour_chars = split(//, $neighbour);

                for (my $i = 0; $i < scalar @word_chars; $i++) {

                    if ($word_chars[$i] eq $neighbour_chars[$i]) {
                        $same_char++;
                    }
                }

                if ($same_char eq (length $word) - 1) {

                    if (not defined $graph{$word}) {

                        $graph{$word} = [];
                    }
                    push @{$graph{$word}}, $neighbour;
                }
            }
        }
    }

    my $hop    = undef;
    my $minHop = \$hop;

    if ($algo eq 'depth') {

	_find_shortest_paths_depth([ $start ], $end, \%graph, $results, $minHop);

    } elsif ($algo eq 'breadth') {

	_find_shortest_paths_breadth($start, $end, \%graph, $results);

    } else {

        die 'The search algorithm "' . $algo . '" is not known';
    }

    return $results;
}


sub _find_shortest_paths_breadth {
    my ($start, $end, $graph, $results) = @_;
    
    my @paths = ();

    my $minHop = undef;

    push @paths, [ $start ];

    while (my $path = shift @paths) {

	my $lastHop = $path->[-1];
	my $nbHop   = (scalar @$path) + 1;

	if ((not defined $minHop) or $minHop >= $nbHop) {

	    foreach my $neighbour (@{$graph->{$lastHop}}) {

		if ($neighbour eq $end) {

		    if ($nbHop < $minHop or not defined $minHop) {
			$minHop = $nbHop;
		    }

		    push @$path, $neighbour;
		    push @$results, $path;
                    last;

                  # loop avoidance
		} elsif (not grep { $neighbour eq $_ } @$path) {
                    
    		    push @paths, [(@$path, $neighbour)];
		}
	    }
	}
    }
}

sub _find_shortest_paths_depth {
    my ($path, $end, $graph, $results, $minHop) = @_;

    my $hop = scalar @$path;

    if ($$minHop and $hop > $$minHop) {
	return;
    }

    my $lastHop = $path->[-1];

    if ($lastHop eq $end) {

	if ((not defined $$minHop) or $$minHop > $hop) {

            # we found a shorter path, no need to keep the previous ones
            @$results = ();
            $$minHop = $hop;
	}

	push @$results, $path;
	return;
    }

    foreach my $neighbour (@{$graph->{$lastHop}}) {

        # loop avoidance
	if (not grep { $neighbour eq $_ } @$path) {

	    _find_shortest_paths_depth([(@$path, $neighbour)], $end, $graph, $results, $minHop);
	}
    }
}

my $results = _shortest_paths($start, $end, $dict, 'depth');

print "### depth first search :\n";
foreach my $result (@$results) {

    print join(',', @$result) . "\n";
}

print "\n";

$results = _shortest_paths($start, $end, $dict, 'breadth');

print "### breadth first search :\n";
foreach my $result (@$results) {

    print join(',', @$result) . "\n";
}
