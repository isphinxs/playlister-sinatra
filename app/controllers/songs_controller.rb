require "rack-flash"

class SongsController < ApplicationController

    get "/songs" do
        @songs = Song.all
        erb :"/songs/index"
    end

    get "/songs/new" do
        @artists = Artist.all
        @genres = Genre.all
        erb :"/songs/new"
    end

    post "/songs" do
        @song = Song.create(params[:song])

        params["genres"].each do |genre|
            @song.genres << Genre.find_by(id: genre.to_i)
        end
        
        if @song.artist.nil? && !params["artist"]["name"].empty?
            artist = Artist.find_by(name: params["artist"]["name"])
            if artist
                @song.artist = artist
            else
                @song.create_artist(name: params["artist"]["name"])
            end
        end
        @song.save
        # flash[:message] = "Successfully created song."
        session[:message] = "Successfully created song."
        redirect "/songs/#{@song.slug}"
    end
    
    get "/songs/:slug" do
        @song = Song.find_by_slug(params[:slug])
        erb :"/songs/show"
    end
    
    get "/songs/:slug/edit" do
        @song = Song.find_by_slug(params[:slug])
        @artists = Artist.all
        @genres = Genre.all
        erb :"/songs/edit"
    end
    
    patch "/songs/:slug" do
        # binding.pry
        if !params[:song].keys.include?("artist_id")
            params[:song]["artist_id"] = []
        end
        
        @song = Song.find_by_slug(params[:slug])
        @song.update(params[:song])
        
        @song.genres.clear
        params["genres"].each do |genre|
            @song.genres << Genre.find_by(id: genre.to_i)
        end
        
        if !params["artist"]["name"].empty?
            artist = Artist.find_by(name: params["artist"]["name"])
            if artist
                @song.artist = artist
            else
                @song.create_artist(name: params["artist"]["name"])
            end
        end
        
        @song.save

        session[:message] = "Successfully updated song."
        redirect "/songs/#{@song.slug}"
    end
end