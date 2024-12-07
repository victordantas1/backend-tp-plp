package sgl_perl;
use Dancer2;
use Text::CSV;
use JSON;

post '/upload' => sub {
    # Recebe os arquivos enviados no campo 'files'
    my @uploads = upload('files');
    
    unless (@uploads) {
        return status 400, to_json({ error => "Nenhum arquivo foi enviado." });
    }

    my @results; # Armazena os resultados de cada arquivo

    # Iterar sobre os uploads
    foreach my $upload (@uploads) {
        my $filename = $upload->filename; # Nome do arquivo original
        
        my $csv_file = 'csv/ips_extracted_' . $filename . '.csv';
        my $csv = Text::CSV->new({ binary => 1, eol => $/});

        # Abrir arquivo CSV para salvar os IPs
        open my $fh, '>', $csv_file or die "Não foi possível abrir $csv_file: $!";
        $csv->print($fh, ['Filename', 'IP']); # Cabeçalho do CSV

        my $content = $upload->content;
        my @lines = split /\n/, $content;

        my @ips;
        foreach my $line (@lines) {
            while ($line =~ /(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)/g) {
                push @ips, $1;
            }
        }

        # Salvar IPs e o nome do arquivo no CSV
        foreach my $ip (@ips) {
            $csv->print($fh, [$filename, $ip]);
        }

        # Armazenar resultados para o JSON final
        push @results, { filename => $filename, ips => \@ips };
        close $fh;
    }

    # Retorna os resultados para o cliente
    return to_json({ files => \@results });
};

# Inicia o servidor
true;
