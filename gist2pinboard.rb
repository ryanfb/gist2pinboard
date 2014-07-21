#!/usr/bin/env ruby

require 'yaml'
require 'rest_client'
require 'json'

def fetch_gist_page(gist_page, github_token)
  $stderr.puts "Fetching page #{gist_page}"
  response = RestClient.get("https://api.github.com/gists", :params => { :access_token => github_token, :page => gist_page }, :accept => :json)
  return gists = JSON.parse(response)
end

def fetch_all_gists(github_token)
  all_gists = []
  response = RestClient.get("https://api.github.com/gists", :params => { :access_token => github_token }, :accept => :json)
  gists = JSON.parse(response)
  pages = response.headers[:link].scan(/(\d+)>; rel="last"$/).first.first.to_i
  puts "Pages: #{pages}"
  all_gists += gists
  (2..pages).each do |page|
    all_gists += fetch_gist_page(page, github_token)
  end
  return all_gists
end

def get_title(gist)
  if gist['description'].nil? || gist['description'].empty?
    return "gist:#{gist['id']}"
  else
    return gist['description']
  end
end

config = YAML.load_file('.secrets.yml')

gists = fetch_all_gists(config['github_token'])
gists.each do |gist|
  $stderr.puts "Adding: " + gist['html_url']
  RestClient.get("https://api.pinboard.in/v1/posts/add", :params => { :auth_token => config['pinboard_token'], :url => gist['html_url'], :description => get_title(gist), :shared => 'no', :tags => 'gist2pinboard' }, :accept => :json)
end
