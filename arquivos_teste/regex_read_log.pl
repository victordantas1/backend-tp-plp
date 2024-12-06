#!/usr/bin/perl
use strict;
use warnings;

# Nome dos arquivos
my $log_file = "system_status.log";
my $csv_file = "system_status.csv";

# Abrir o arquivo de log para leitura
open(my $fh, '<', $log_file) or die "Não foi possível abrir o arquivo '$log_file': $!";

# Abrir o arquivo CSV para escrita
open(my $csv_fh, '>', $csv_file) or die "Não foi possível criar o arquivo '$csv_file': $!";

# Escrever o cabeçalho no arquivo CSV
print $csv_fh "Data,Hora,IP,CPU (%),GPU (%),RAM (%),Disco (%),Erro\n";

print "Processando o log '$log_file' e salvando no arquivo '$csv_file':\n";

while (my $line = <$fh>) {
    chomp $line;

    # Exibir a linha lida
    print "Linha lida: $line\n";

    # Regex para capturar os dados
    if ($line =~ /\[(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2})\]\s*IP:\s*([\d\.]+)\s*\|\s*CPU:\s*([\d\.]+)%\s*\|\s*GPU:\s*([\d\.]+)%\s*\|\s*RAM:\s*([\d\.]+)%\s*\|\s*Disk:\s*([\d\.]+)%\s*(?:\|\s*ERROR:\s*(.+))?/) {
        my ($date, $time, $ip, $cpu, $gpu, $ram, $disk, $error) = ($1, $2, $3, $4, $5, $6, $7, $8 // '');

        # Tratar o erro: remover quebras de linha e espaços extras
        $error =~ s/\R/ /g;  # Substituir quebras de linha por espaços
        $error =~ s/^\s+|\s+$//g;  # Remover espaços no início/fim

        # Exibir os dados capturados
        print "Capturado -> Data: $date, Hora: $time, IP: $ip, CPU: $cpu%, GPU: $gpu%, RAM: $ram%, Disco: $disk%, Erro: $error\n";

        # Escrever os dados no CSV
        print $csv_fh "$date,$time,$ip,$cpu,$gpu,$ram,$disk,\"$error\"\n";
    } else {
        # Exibir mensagem para linhas que não correspondem ao formato esperado
        print ">> Linha não corresponde ao formato esperado e será ignorada: $line\n";
    }
}

# Fechar os arquivos
close($fh);
close($csv_fh);

print "Processamento concluído. Dados salvos em '$csv_file'.\n";
