package OOCEapps::PkgUpd::PyMod;
use Mojo::Base 'OOCEapps::PkgUpd::base';

# public methods
sub canParse {
    my $self = shift;
    my $name = shift;
    my $url  = shift;

    return $name =~ /^library\/python-2/;
}

sub getVersions {
    my $self = shift;
    my $name = shift;
    my $res  = shift;

    # remove -27 suffix
    $name =~ s/-27$//;

    $name = $self->extractName($name);
    # enum is a backport from python3
    $name .= '34' if $name eq 'enum';
    return [
        map { /(?:$name[-\/]((?:\d+[-.]){1,3}\d+)\.(?:tar\.(?:gz|xz|bz2)|xml)|lxml\s+((?:\d+\.){1,2}\d+))/i ? $1 // $2 : () }
            $res->dom->find('a')->each
    ];
}

1;

__END__

=head1 COPYRIGHT

Copyright 2017 OmniOS Community Edition (OmniOSce) Association.

=head1 LICENSE

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.
This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.
You should have received a copy of the GNU General Public License along with
this program. If not, see L<http://www.gnu.org/licenses/>.

=head1 AUTHOR

S<Dominik Hassler E<lt>hadfl@omniosce.orgE<gt>>

=head1 HISTORY

2017-09-06 had Initial Version

=cut

