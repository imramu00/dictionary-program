#!/usr/bin/env ruby
require 'net/http'
require 'json'

# Class dictionary holds methods to find meaning for a word and suggestion of words
class Dictionary
  attr_accessor :word

  # initializer of the class taking a string as argument
  def initialize(word)
    @word=word
  end

  # response method
  ## this method takes a word as it's argument and gets the meaning of the given word by REST API
  ## The response will be in JSON format
  ## The JSON file can be parsed using JSON gem
  ## The parsed JSON will give a Hash
  def response(word)
    url = 'https://api.dictionaryapi.dev/api/v2/entries/en_US/'+word
    uri = URI(url)
    response = Net::HTTP.get(uri)
    json_data =  JSON.parse(response)
  end

  # word_checker
  ## this method takes an array of strings as the argument and returns the first valid english string in the array.
  def word_checker(word_possibility)
    valid_words=[]
    word_possibility.each{ |word|
      if (system("look #{word} > new.txt"))
        if response(word)[0] !=nil
          valid_words << word
          break
        end
      end
    }
    valid_words
  end

  # word_predictor
  ## this method takes an array of strings as argument and returns an array with all the possible english words starting with each string of the input array.
  def word_predictor(word_array)
    similar_words=[]
      word_array.each { |word|
      system("look #{word} > new.txt")
      f = File.open("new.txt")
      f.each_line {|line| similar_words << line.chomp }
    }
    self.word_checker(similar_words)
  end
end

begin
	system 'clear'
end

arr= nil
valid_words = nil
word_possibility = nil
puts "Enter a word to get the meaning: "
word=gets.chomp
json = Dictionary.new(word)
json_data = json.response(word)

if (json_data[0] != nil)
  p json_data[0]["meanings"][0]["definitions"][0]["definition"]
else
  word_possibility = word.chars.to_a.permutation.map(&:join)
  valid_words = json.word_checker(word_possibility)

  if valid_words.length > 0
    puts "Did you mean "+valid_words[0]
  else

    for i in 2..(word.length-1)
      arr << word.slice(1..i)
    end

    valid_words = json.word_predictor(arr)

    if valid_words.length > 0
      puts "Did you mean "+valid_words[0]
    else
      puts "Check the entered word"
    end

  end
end
