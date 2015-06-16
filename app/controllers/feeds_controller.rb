

class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy]
  require 'rss'

  def getrss
    @feeds = Feed.all
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
                # # dateの記述が間違っているRSSがたまにあるので念のため
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
    @feeds = Feed.all
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show

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
