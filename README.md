# Catimporter
Importa una categoria (con relative sottocategorie) da una wiki all'altra.
## Prerequisiti

Avere installato Ruby e [bundler](https://bundler.io); quindi dare 

```console
bundle install 				(systemwide)
bundle install --path vendor/bundle 	(utente)
```

Tutte le dipendenze saranno così installate.

## Configurazione
Eseguite lo script chiamato `process.rb` (per esempio, col comando `$ ruby process.rb`) vi verranno richiesti alcuni parametri fondamentali che verranno salvati in un file chiamato .config e ripresi automaticamente alle successive esecuzioni.

## Eseguire ciclicamente
Potete aggiungere lo script alla crontab, chiedendo `which ruby` ed inserendo in crontab una cosa del genere (sostituendo user col nome del vostro utente, /usr/bin/ruby col risultato di which ruby e directory col path allo script):
```
0 1 * * * user /usr/bin/ruby /directory/process.rb
```
