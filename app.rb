# Copyright 2015 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START app]
require "sinatra"
require "dotenv/load"
require "HTTParty"
require "trello"
require "pry"

Trello.configure do |config|
  config.developer_public_key = ENV["TRELLO_KEY"]
  config.member_token = ENV["TRELLO_TOKEN"]
end

get "/" do
  body = {
    "token" => ENV["TODOIST_TOKEN"],
    "resource_types" => '["items"]'
  }

  response = HTTParty.post(
    "https://todoist.com/api/v7/sync",
    body: body
  )
  body = JSON.parse(response.body)
  items = body["items"]
  kevin = Trello::Member.find("kevinmcalear")
  "basic setup works #{kevin.full_name}'s first task: #{items[0]['content']}!"
end

get "/trello" do
  kevin = Trello::Member.find("kevinmcalear")
  board = Trello::Board.find('DBCb2STn')
  lists = board.lists
  lists_html = ""
  lists.each do |list|
    lists_html += "<h3>#{list.name}</h3><ul>"
    list.cards.each do |card|
      lists_html += "<li>#{card.name}</li>"
    end
    lists_html += "</ul>"
  end
  "<h1>#{kevin.full_name}'s Tasks:</h1>#{lists_html}"
end

get "/todoist" do
  todoist_request_body = {
    "token" => ENV["TODOIST_TOKEN"],
    "resource_types" => '["items", "collaborators", "projects"]'
  }

  response = HTTParty.post(
    "https://todoist.com/api/v7/sync",
    body: todoist_request_body
  )
  body = JSON.parse(response.body)
  items = body["items"]
  labels = body["labels"]
  projects = body["projects"]
  items_html = ""
  projects_html = ""
  items.each do |item|
    items_html += "<li>#{item['content']}</li>"
  end
  projects.each do |project|
    projects_html += "<li>#{project['name']}</li>"
  end
  "<h1>todoist tasks:</h1> <ul>#{items_html}</ul><h1>projects:</h1><ul>#{projects_html}</ul>"
end
# [END app]
