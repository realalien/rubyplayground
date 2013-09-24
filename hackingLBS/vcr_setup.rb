#encoding: UTF-8

require 'vcr'

VCR::YAML = ::YAML

VCR.configure do |c|
  c.cassette_library_dir = './vcr_cassettes'
  c.hook_into :fakeweb#:webmock
  c.ignore_localhost = true
  c.default_cassette_options = { record: :new_episodes, :serialize_with => :json, :preserve_exact_body_bytes => true }
end
