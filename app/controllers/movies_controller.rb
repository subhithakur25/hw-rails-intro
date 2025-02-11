class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      @all_ratings = Movie.all_ratings 
      
      @is_ratings_to_show_filled = true
      if params.has_key?(:ratings) && params[:ratings] != {} 
        @ratings_to_show = params[:ratings]
        session[:ratings] = @ratings_to_show
        @is_ratings_to_show_filled = false
      elsif session.has_key?(:ratings)
        @ratings_to_show = session[:ratings]
      else 
        @ratings_to_show = Hash[@all_ratings.map {|x| [x, 1]}]
      end
      
      ratings_list = @ratings_to_show
      
      @movies = Movie.with_ratings(ratings_list.keys)
      
      @is_clicked_header_filled = true
      if params.has_key?(:clicked_header) 
        @clicked_header = params[:clicked_header]
        session[:clicked_header] = @clicked_header
        @is_clicked_header_filled = false
      elsif session.has_key?(:clicked_header)
        @clicked_header = session[:clicked_header]  
      else 
        @clicked_header = {}
        # to avoid redirecting again and again since clicked_header will be an empty param
        @is_clicked_header_filled = false
      end
      
      if @is_ratings_to_show_filled == true || @is_clicked_header_filled == true
        redirect_to :clicked_header => @clicked_header, :ratings => @ratings_to_show and return
      end
      
      if @clicked_header == "title_header"
        @movies = @movies.order(:title)
      end
      if @clicked_header == "release_date_header"
        @movies = @movies.order(:release_date)
      end      
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end