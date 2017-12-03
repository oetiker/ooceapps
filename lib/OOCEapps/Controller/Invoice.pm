package OOCEapps::Controller::Invoice;
use Mojo::Base 'OOCEapps::Controller::base';
use File::Temp;
use Mojo::File;

has log  => sub { shift->app->log };

has model => sub {
    shift->app->model->{Invoice};
};

has luaLaTeX => sub {'lualatex'};

sub createInvoice {
    my $c = shift;
    $c->stash(
        AssetPath => Mojo::Home->new->rel_file("share/invoice")->to_string,
        Address => $c->param('address') // 'Tobi Oetiker
Aarweg 15
4600 Olten',
        Product => $c->param('product') // 'A cool description of the stuff you are getting',
        Price => $c->param('price') // '10',
        Currency => $c->param('currency') // 'CHF',
        InvoiceId => 42,
    );
    my $tex = $c->render_to_string(template=>'invoice/invoice',format=>'tex');
    my $subprocess = Mojo::IOLoop::Subprocess->new;
    $subprocess->run(
        sub {
            my $subprocess = shift;
            my $tmpDir = File::Temp->newdir();
            chdir $tmpDir;
            my $texFile = Mojo::File->new('invoice.tex');
            $texFile->spurt($tex);
            open my $latex, '-|', $c->luaLaTeX,'invoice';
            my $latexOut = join '', <$latex>;
            close $latex;
            my $output = 'invoice.pdf';
            if (not -e $output or -z $output){
                die $latexOut;
            }
            my $pdf = Mojo::File->new($output)->slurp;
            chdir '/';
            return $pdf;
        },
        sub {
            my ($subprocess, $err, $pdf) = @_;
            if (not $pdf){
                $c->log->error("Subprocess error: $err");
                return $c->render(staus=>500,text=>"<pre>ERROR: $err</pre>");
            }
            $c->res->headers->content_disposition("inline; filename=invoice-42.pdf;");
            return $c->render(data=>$pdf,format=>'pdf');
        }
    );
    $c->inactivity_timeout(60);
    $c->render_later;
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

S<Tobias Oetiker E<lt>tobi@oetiker.chE<gt>>

=head1 HISTORY

2017-12-03 to Initial Version

=cut
