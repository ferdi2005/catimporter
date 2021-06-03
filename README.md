# Catimporter
Importa una categoria (con relative sottocategorie) da una wiki all'altra.
## Prerequisiti

Lo script richiede Ruby.

In particolare sono richieste le gem
- `httparty`
- `addressable`
- `mediawiki_api`

È possibile installare e gestire le dipendenze usando [bundler](https://bundler.io): 

```console
bundle install 				(systemwide)
bundle install --path vendor/bundle 	(utente)
```

## Avvio e configurazione
Eseguite lo script chiamato `process.rb` (per esempio, col comando `$ ruby process.rb`);
vi verranno richiesti alcuni parametri fondamentali che verranno salvati 
in un file chiamato .config e ripresi automaticamente alle successive esecuzioni.

Se state eseguendo il programma avendo installato le dipendenze come utente,
e' probabile dobbiate settare anche la variabile `$GEM_HOME` in modo che punti alla cartella
di bundler.

Sembrerebbe **NON** essere possibile utilizzare un'utenza bot per l'importazione delle voci.

## Eseguire ciclicamente
Potete aggiungere lo script alla crontab, chiedendo `which ruby` ed inserendo in crontab una cosa del genere (sostituendo user col nome del vostro utente, /usr/bin/ruby col risultato di which ruby e directory col path allo script):
```
0 1 * * * user /usr/bin/ruby /directory/process.rb
```
