require 'elasticsearch/model'

Elasticsearch::Model.client = Elasticsearch::Client.new(
  log: Rails.env.development?,
  transport_options: { request: { timeout: 10 } }
)
