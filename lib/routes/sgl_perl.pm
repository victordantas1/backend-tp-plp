package sgl_perl;
use Dancer2;
use Text::CSV;
use JSON;

post '/upload' => sub {
    # Recebe o arquivo da requisição
    my $upload = upload('file');
    unless ($upload) {
        return status 400, to_json({ error => "Nenhum arquivo foi enviado." });
    }

    # Lê o conteúdo do arquivo
    my $content = $upload->content;
    my @lines = split /\n/, $content;

    # Regex para capturar IPs
    my @ips;
    foreach my $line (@lines) {
        while ($line =~ /(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)/g) {
            push @ips, $1;
        }
    }

    # Salvar IPs no arquivo CSV
    my $csv_file = 'ips_extracted.csv';
    my $csv = Text::CSV->new({ binary => 1, eol => $/ });
    open my $fh, '>', $csv_file or die "Não foi possível abrir $csv_file: $!";
    $csv->print($fh, ['IP']);
    $csv->print($fh, [$_]) for @ips;
    close $fh;

    # Retorna os IPs extraídos em formato JSON
    return to_json({ ips_extracted => \@ips });
};

# Inicia o servidor
true;
