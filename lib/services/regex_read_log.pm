#!/usr/bin/perl
use strict;
use warnings;
use Text::CSV;

# Nome do arquivo de log
my $log_file = 'detailed_computer_info.log';

# Nome do arquivo CSV de saída
my $csv_file = 'system_status.csv';

# Função para processar uma linha e retornar os valores extraídos
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
    if ($line =~ /GPU.*?([\d\.]+)%/) {
        $gpu = $1;
    }
    if ($line =~ /(?:Media de\s)?CPU:\s([\d\.]+)%/) {
        $cpu = $1;
    }
    if ($line =~ /RAM.*?([\d\.]+)%/) {
        $ram = $1;
    }
    if ($line =~ /(?:Disco|Disk):\s([\d\.]+)%/) {
        $disk = $1;
    }

    # Retornar os valores extraídos
    return ($date, $time, $ip, $gpu, $cpu, $ram, $disk);
}

# Abrir o arquivo de log para leitura
open my $fh, '<', $log_file or die "Não foi possível abrir o arquivo: $!";

# Criar e configurar um objeto Text::CSV para gerar o CSV
my $csv = Text::CSV->new({ binary => 1, eol => "\n" });
open my $csv_fh, '>', $csv_file or die "Não foi possível criar o arquivo CSV: $!";

# Escrever cabeçalhos no CSV
$csv->print($csv_fh, ["Data", "Hora", "IP", "GPU (%)", "CPU Média (%)", "RAM (%)", "Disco (%)"]);

# Processar o arquivo linha por linha e escrever os dados no CSV
while (my $line = <$fh>) {
    chomp $line;
    my @values = process_line($line);
    $csv->print($csv_fh, \@values);
}

# Fechar os arquivos
close $fh;
close $csv_fh;

print "Arquivo CSV '$csv_file' gerado com sucesso!\n";