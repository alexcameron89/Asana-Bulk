#!/usr/bin/env ruby

require "rubygems"
require "json"
require "net/https"
require "csv"
API_KEY = "2eSUdgF2.wSgSYfK9hqcVz70LFiWPgg5"
sheet_loc = ARGV.shift
task_sheet = CSV.read(sheet_loc)

def add_task
end

def add_subtask
end

def configure_https_connection
  # set up HTTPS connection
  uri = URI.parse("https://app.asana.com/api/1.0/tasks")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  
  # set up the request
  header = {
    "Content-Type" => "application/json"
  }

  return uri, http, header
end

def structure_data(column_data, row, uri)
  data = Hash.new
  row.each_with_index do |item, index |
    data[column_data[index]] = item unless item == nil
    p item
    p item.class
  end

  type = data.delete("type")

  if type == "subtask"
    parent = data.delete("parent")
    uri.path = "/api/1.0/tasks/#{parent}/subtasks"
  else
    uri.path = "/api/1.0/tasks"
  end

  return data
end

def issue_request(uri, header, http, data)
  req = Net::HTTP::Post.new(uri.path, header)
  req.basic_auth(API_KEY, '')
  req.body = {
    "data" => data
  }.to_json()

  # issue the request
  res = http.start { |http| http.request(req) }

  return res
end

def print_response(response_body)
  body = JSON.parse(response_body)
  if body['errors'] then
    puts "Server returned an error: #{body['errors'][0]['message']}"
  else
    puts "Created task with id: #{body['data']['id']}"
  end
end

#--------------------

uri, http, header = configure_https_connection
columns = task_sheet.shift

while task_sheet.length > 0
  data = structure_data(columns, task_sheet.pop, uri)

  response = issue_request(uri, header, http, data)

  print_response(response.body)

  # output
end
