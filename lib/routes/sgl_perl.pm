package sgl_perl;
use Dancer2;
use Text::CSV;
use JSON;

hook after => sub {
    my $response = shift;

    $response->header('Access-Control-Allow-Origin'  => '*'); # Ou substitua * pela origem permitida
    $response->header('Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS');
    $response->header('Access-Control-Allow-Headers' => 'Content-Type, Authorization');
};

sub process_line {
    my ($line) = @_;

    # Valores padrão
    my ($date, $time, $ip, $gpu, $cpu, $ram, $disk) = ('N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A');

    # Regex flexível para capturar quaisquer campos disponíveis
    if ($line =~ /(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2})/) {
        $date = $1;
        $time = $2;
    }
    if ($line =~ /Endere.*IP:\s([\d\.]+)/) {
        $ip = $1;
    }
    if ($line =~ /GPU:\s([\d\.]+)%/) {
        $gpu = $1;
    }
    if ($line =~ /Media de CPU:\s([\d\.]+)%/) {
        $cpu = $1;
    }
    if ($line =~ /RAM:\s([\d\.]+)%/) {
        $ram = $1;
    }
    if ($line =~ /Disco:\s([\d\.]+)%/) {
        $disk = $1;
    }

    # Retornar os valores extraídos
    return ($date, $time, $ip, $gpu, $cpu, $ram, $disk);
}

post '/upload' => sub {
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
        my @date;
        my @time;
        my @ip;
        my @gpu;
        my @cpu;
        my @ram;
        my @disk;

        my ($date, $time, $ip, $gpu, $cpu, $ram, $disk) = ('N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A');
        foreach my $line (@lines) {
            while ($line =~ /(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)/g) {
                push @ips, $1;
            }
            ($date, $time, $ip, $gpu, $cpu, $ram, $disk) = process_line($line);
            push @ip, $ip;
            push @gpu, $gpu;
            push @cpu, $cpu;
            push @ram, $ram;
            push @disk, $disk;
        }

        # Salvar IPs e o nome do arquivo no CSV
        foreach my $ip (@ips) {
            $csv->print($fh, [$filename, $ip]);
        }

        # Armazenar resultados para o JSON final
        push @results, { filename => $filename, 
            ip => \@ips,
            ram => \@ram,
            gpu => \@gpu,
            cpu => \@cpu,
            disk => \@disk
        };
        close $fh;
    }

    # Retorna os resultados para o cliente
    return to_json({ files => \@results });
};

# Inicia o servidor
true;
