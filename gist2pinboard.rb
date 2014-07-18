#!/usr/bin/env ruby

require 'yaml'
require 'ghee'
require 'pinboard'

config = YAML.load_file('.secrets.yml')

gh = Ghee.access_token(config['github_token'])

$stderr.puts gh.gists.inspect