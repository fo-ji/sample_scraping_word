class SearchesController < ApplicationController
  require 'nokogiri'
  require 'open-uri'
  require 'natto'

  def search
    nm = Natto::MeCab.new
    wordHash = {}
  
    doc = Nokogiri::HTML(open('https://sample.com/')) do |config|
      config.noblanks
    end
  
    doc.search("script").each do |script|
      script.content = "" ##scriptタグの中身を空にする
    end
  
    doc.css('body').each do |elm|
      text = elm.content.gsub(/(\t|\s|\n|\r|\f|\v)/,"")
      nm.parse(text) do |n|
        # 条件はHTMLにより変更
        if n.feature.split(',')[0].in?(["名詞"]) && n.surface.size >= 2 && !n.surface.in?(['null','co', '://', 'https', 'http', '>,','こと', 'もの', 'プラン', '更新', 'ログイン', '.', ',', '-', 'アカウント', 'フォロー', 'こちら', '登録', '特集', '公式', '新規', '編集', '記事'])
          wordHash[n.surface] ? wordHash[n.surface] += 1 : wordHash[n.surface] = 1 if n.feature.match("名詞")
        end
      end
    end

    @popular_words = []
    # 上位5ワードを取得
    @popular_words << wordHash.sort_by{ | k, v | v }.reverse.first(10)
  end
end
