require 'open-uri'

class Kart
  def initialize(url)
    @data = open(url).read
  end

  def converter(segs)
    duracao=[1, 1000, 60000, 3600000]*2
    segs=segs.split(/[:\.]/).map{|tempo| tempo.to_i*duracao.pop}.sum
  end

  def classificar
    linhas = @data.split("\n")
    linhas.shift

    @analisar = linhas.map do |linha|
      registrar = linha.gsub(/\s+/m, ' ').strip.split(" ")
        {
          hora: registrar[0],
          cod_piloto: registrar[1],
          piloto: registrar[3],
          volta: registrar[4].to_i,
          tempo_volta: converter(registrar[5].to_s.rjust(12, "00:0")),
          velocidade_media: registrar[6].to_s.gsub(",",".").to_f
        }
    end

    @final = @analisar
              .group_by{|data| [data[:cod_piloto], data[:piloto]]}
              .to_a.map{|e| [e.first, e.last.length,Time.at(e.last
              .sum{|e| e[:tempo_volta]/1000.0}).utc.strftime("%H:%M:%S.%L")]}
              .map(&:flatten)

    @final.each_with_index do |rank, index|
      puts "#{index + 1} | #{rank[0]} | #{rank[1]}\t\t| #{rank[2]} | #{rank[3]}"
    end
  end
end

kart = Kart.new("https://gist.githubusercontent.com/erickvictor/622e7d623e9baf9c26e9211f9afb277d/raw/b77987c1ce92b49b5f6f24de355c9cc6743c311e/lista.txt")
kart.classificar