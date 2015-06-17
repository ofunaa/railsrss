

class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy]
  require 'rss'

  def getrss
    if params[:category] != nil
      if params[:category] == "all"
        @feeds = Feed.all.order("entrydate DESC")
      else
        @feeds = Feed.where(category: params[:category]).order("entrydate DESC")
      end
    elsif
      @feeds = Feed.all.order("entrydate DESC")
    end
    render "feeds/index"
  end




  # GET /feeds
  # GET /feeds.json
  def index
    lists = [
          'http://news.livedoor.com/topics/rss/top.xml',
          'http://news.livedoor.com/topics/rss/dom.xml',
          'http://news.livedoor.com/topics/rss/int.xml',
          'http://news.livedoor.com/topics/rss/eco.xml',
          'http://news.livedoor.com/topics/rss/ent.xml',
          'http://news.livedoor.com/topics/rss/spo.xml',
          'http://news.livedoor.com/rss/summary/52.xml',
          'http://news.livedoor.com/topics/rss/gourmet.xml',
          'http://news.livedoor.com/topics/rss/love.xml',
          'http://news.livedoor.com/topics/rss/trend.xml'];
        return false unless lists

        lists.each do |rss|
            rssdata = RSS::Parser.parse(rss)
            puts "_______________________
            "
            puts rss
            puts "_______________________

            "

            rssdata.items.each do |entry|
                tmpdate = entry.respond_to?(:pubDate) ? entry.pubDate : entry.dc_date
                item = Feed.new
                icategory = rss.split(/\//)[5]
                item.category = icategory.split(/\./)[0]
                puts item.category
                item.title = entry.title
                entryDesc = []
                entry.description.scan(/<li>(.+)<\/li>|<br \/>(.+)<a href=/).each do |m|
                  entryDesc.push(m)
                end
                item.desc = entryDesc.join
                item.link = entry.link
                item.entrydate = tmpdate
                puts item.category
                if item.desc =~ /....../
                  item.save
                end
            end
        end
    @feeds = Feed.all.order("entrydate DESC")
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
    ######## スクレピング ########

    require 'nokogiri'
    require 'open-uri'
    require 'cgi'

    # スクレイピング先のURL
    url = @feed.link
    # Request the HTML before parsing
    html = open(url).read
    # Replace original DOCTYPE with a valid DOCTYPE
    html = html.sub(/^<!DOCTYPE html(.*)$/, '<!DOCTYPE html>')
    # Parse
    doc = Nokogiri::HTML(html)
    @doc = doc.css('.articleBody').text.split(" ")


    ######## 形態素解析 ########

    # 必要なライブラリを呼び出し。
    require 'natto'
    # nm(納豆めかぶ)を呼び出し。
    nm = Natto::MeCab.new

    common_words = []
    # nmにテキストをフィードしてparse(解析)してもらう
    nm.parse("#{@feed.desc}") do |n|
      s = n.surface ? n.surface : "-"
      common_words << s
    end
    #２文字以上の単語のみ取得
    common_twowords = []
    common_words.each do |common|
      if common.length > 1
        common_twowords.push("#{common}")
      end
    end

    title_words = []
    # nmにテキストをフィードしてparse(解析)してもらう
    nm.parse("#{@feed.title}") do |n|
      s = n.surface ? n.surface : "-"
      title_words << s
    end
    #２文字以上の単語のみ取得
    title_twowords = []
    title_words.each do |common_title|
      if common_title.length > 1
        puts common_title
        title_twowords.push("#{common_title}")
      end
    end

    #ディスクリプションをすべて取得
    feedall = Feed.all
    #feed.idとマッチ回数を入れる連想配列を作成
    relation_feed = {}
    #取得したフィードのディスクリプションをループ
    feedall.each do |feedone|

      
      # 同じカテゴリに優遇
      if @feed.category == feedone.category
        match_count = 5
      else
        match_count = 0
      end

      #文章の検証
      common_twowords.each do |common_twoword|
        # 文章とマッチ
        match_count = match_count + feedone.desc[0,90].scan(/#{common_twoword}/).size*2
      end

      #タイトルの検証
      title_twowords.each do |title_twoword|
        # タイトルとマッチ
        match_count = match_count + feedone.title.scan(/#{title_twoword}/).size*5
      end

      relation_feed.store("#{feedone.id}","#{match_count}")
    end
    # 並べ替え
    relation_feed_top = relation_feed.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }

    i = 0
    @relation_feeds = []
    loop{
      relation_feed = Feed.where(id: "#{relation_feed_top[i][0]}")
      @relation_feeds.push(relation_feed)
      i += 1
      if i > 2 then
        break
      end
    }


  end



  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1/edit
  def edit
  end

  # POST /feeds
  # POST /feeds.json
  def create
    @feed = Feed.new(feed_params)

    respond_to do |format|
      if @feed.save
        format.html { redirect_to @feed, notice: 'Feed was successfully created.' }
        format.json { render :show, status: :created, location: @feed }
      else
        format.html { render :new }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /feeds/1
  # PATCH/PUT /feeds/1.json
  def update
    respond_to do |format|
      if @feed.update(feed_params)
        format.html { redirect_to @feed, notice: 'Feed was successfully updated.' }
        format.json { render :show, status: :ok, location: @feed }
      else
        format.html { render :edit }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.json
  def destroy
    @feed.destroy
    respond_to do |format|
      format.html { redirect_to feeds_url, notice: 'Feed was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def feed_params
      params[:feed]
    end
end
