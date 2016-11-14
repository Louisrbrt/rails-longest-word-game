require 'open-uri'
require 'json'
KEY = "4f8ee031-87ed-4072-a885-ef7e21b6e7ab"

class LongestWordController < ApplicationController
  def game
    grid_size = params[:grid_size].to_i
    @grid = generate_grid(grid_size).join(" ")
    @start_time = Time.now
  end

  def score
    @start_time = Time.parse(params[:start_time])
    @attempt = params[:attempt]
    @end_time = Time.now
    @grid = params[:grid]
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  private

  def generate_grid(grid_size)
    (0...grid_size).map { ('A'..'Z').to_a[rand(26)] }
  end

  def run_game(attempt, grid, start_time, end_time)
    # check if word matches the grid
    attempt.upcase.split("").each_with_index do |letter, i|
      if grid.include?(letter)
        grid.slice!(grid.index(letter))
      else
        p "this word doesn't match the grid"
        return false
      end
    end
    # make API call to get the translation
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{KEY}&input=#{attempt}"
    word_serialized = open(url).read
    french_word = JSON.parse(word_serialized)["outputs"][0]["output"]
    # check if word exists in English dictionary
    result = Hash.new
    if french_word == attempt
      result = { score: 0, time: nil, translation: nil, message: "This is an invalid word !" }
    else
      result = {
        score: attempt.length - ((end_time - start_time).to_i / 10),
        time: (end_time - start_time).to_i, translation: french_word, message: "Well done !"}
    end
  end

end
