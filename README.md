# Catimporter
Importa una categoria (con relative sottocategorie) da una wiki all'altra.
## Prerequisiti
Avere installato Ruby e [bundler](https://bundler.io), dare `bundle install`. Tutte le dipendenze saranno così installate.
## Configurazione
Eseguite lo script chiamato `process.rb` (per esempio, col comando `$ ruby process.rb`) vi verranno richiesti alcuni parametri fondamentali che verranno salvati in un file chiamato .config e ripresi automaticamente alle successive esecuzioni.
## Daemonizzare
Per rendere lo script in continua esecuzione (facendolo diventare un daemon) e controllarlo, è possibile usare i seguenti comandi ereditati dalla gem [daemons](https://github.com/thuehlinger/daemons):
```
$ ruby bot.rb start
    (process.rb is now running in the background)
$ ruby bot.rb restart
    (...)
$ ruby bot.rb stop
```
