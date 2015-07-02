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

def set_https_connection
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

def structure_row_content(row, uri)
  data = Hash.new
  if row[0] == "subtask"
    uri.path = "/api/1.0/tasks/#{row[1]}/subtasks"
  else
    uri.path = "/api/1.0/tasks"
    data["projects"] = row[1]
    data["workspace"] = "7888734474284"
  end
  data["name"] = row[2]
  data["notes"] = row[3]

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

uri, http, header = set_https_connection
columns = task_sheet.shift

while task_sheet.length > 0
  data = structure_row_content(task_sheet.pop, uri)

  response = issue_request(uri, header, http, data)


  # output
  body = JSON.parse(response.body)
  if body['errors'] then
    puts "Server returned an error: #{body['errors'][0]['message']}"
  else
    puts "Created task with id: #{body['data']['id']}"
  end
end
