require 'httparty'
require 'addressable'
require 'mediawiki_api'
# Legge le credenziali e la wiki di destinazione
if !File.exist? "#{__dir__}/.config"
    puts 'Inserisci username:'
    print '> '
    username = gets.chomp
    puts 'Inserisci password:'
    print '> '
    password = gets.chomp
    puts 'Inserisci indirizzo API della wiki di provenienza (nella forma https://it.wikipedia.org/w/api.php)'
    print '> '
    fromwiki = gets.chomp
    puts 'Inserisci indirizzo API della wiki di destinazione (nella forma https://it.wikipedia.org/w/api.php)'
    print '> '
    importwiki = gets.chomp
    puts "Inserisci il prefisso interwiki della wiki di provenienza sulla wiki di destinazione, avendo cura di verificare che l'importazione sia abilitata per quel prefisso"
    print '> '
    interwikiprefix = gets.chomp
    puts "Inserisci la categoria che contiene le pagine da importare (l'importazione è ricorsiva)"
    print '> '
    importcat = gets.chomp
    File.open("#{__dir__}/.config", "w") do |file| 
      file.puts username
      file.puts password
      file.puts fromwiki
      file.puts importwiki
      file.puts interwikiprefix
      file.puts importcat
    end
end
userdata = File.open("#{__dir__}/.config", "r").to_a
userdata.map! {|d| d.gsub!("\n", "")}
fromwiki = userdata[2]
importwiki = userdata[3]
importcat = userdata[5]

# Funzione per ottenere i membri della categoria
def getcatmembers(cat, fromwiki)
    pagelist = HTTParty.get("#{fromwiki}?action=query&list=categorymembers&cmtitle=#{CGI.escape(cat)}&format=json&cmlimit=max", uri_adapter: Addressable::URI).to_a
    unless pagelist.empty?
        if pagelist[2].nil?
            pagelist = pagelist[1][1]['categorymembers']
        else
            cmcontinue = pagelist[1][1]['cmcontinue']
            continue = pagelist[1][1]['continue']
            pagelist = pagelist[2][1]['categorymembers']
        end

            unless pagelist.nil?
            while continue == '-||'
                puts 'Ottengo la continuazione della categoria...'
                new_pagelist = HTTParty.get(fromwiki, query: {action: :query, list: :categorymembers, cmtitle: CGI.escape(cat), cmlimit: 500, cmdir: :newer, cmcontinue: cmcontinue, format: :json }, uri_adapter: Addressable::URI).to_a
                unless new_pagelist.nil?
                if new_pagelist[2].nil?
                    new_pagelist = new_pagelist[1][1]['categorymembers']
                    continue = false
                    @noph = true
                else
                    cmcontinue = new_pagelist[1][1]['cmcontinue']
                    continue = new_pagelist[1][1]['continue']
                    new_pagelist = new_pagelist[2][1]['categorymembers']
                end      
                unless new_pagelist.nil?
                    puts 'Sommo le liste di foto...'
                    pagelist = pagelist += new_pagelist
                end
                end
            end
        end
        return pagelist
    end
end
# recupera la lista delle categorie con pagine da cancellare
catlist = HTTParty.get("#{fromwiki}?action=query&list=categorymembers&cmtitle=#{CGI.escape(importcat)}&format=json&cmlimit=max", uri_adapter: Addressable::URI).to_a[2][1]['categorymembers']
catlist.reject! { |cat| cat["ns"] != 14 }
totalcontain = []
catlist.each do |cat|
    getcatmembers(cat["title"], fromwiki).each do |page|
        totalcontain.push(page)
    end
end

# Verifica e rientra nelle sottocategorie e nelle eventuali categorie più sommerse
count = 0
totalcontain.each { |tc| count += 1 if tc["ns"] == 14}
while(count > 0)
    totalcontain.each do |tc|
        if tc["ns"] == 14
            getcatmembers(tc["title"], fromwiki).each do |page|
                totalcontain.push(page)
            end
            totalcontain.delete(tc)
        end
    end
    count = 0
    totalcontain.each { |tc| count += 1 if tc["ns"] == 14}
end

# Rimuove le voci già sul wiki dall'array
totalcontain.reject! { |page| HTTParty.get(importwiki + '?action=query&list=search&srsearch="' + CGI.escape(page["title"]) + '"&format=json&srlimit=max&srwhat=title', uri_adapter: Addressable::URI).to_a[2][1]["searchinfo"]["totalhits"] > 0}
# Importa la voce nel wiki, funziona solo se c'è un interwiki a Wikipedia in Italiano con w, modificabile secondo necessità
client = MediawikiApi::Client.new importwiki
client.log_in "#{userdata[0]}", "#{userdata[1]}"
totalcontain.each do |page|
    puts "Importo pagina #{page["title"]}"
    begin
        client.action(:import, summary: "Importazione della pagina #{page["title"]} #CatImporterBot", interwikiprefix: userdata[4], interwikisource: userdata[4], interwikipage: page["title"], fullhistory: true, templates: true)
    rescue
        puts "Pagina #{page["title"]} ha riscontrato un errore"
    end
end