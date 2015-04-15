Gem::Specification.new do |s|
  s.name        = 'ruqlcqb'
  s.version     = '0.0.0'
  s.date        = '2015-04-14'
  s.summary     = "Ruby question language"
  s.description = "Ruby-embedded DSL for creating short-answer quiz questions"
  s.authors     = ["Armando Fox", "Aaron Zhang"]
  s.email       = 'aaron.zhang@berkeley.edu'
  s.files = []
  s.files       << 'lib/ruql.rb'
  s.files +=  %w(quiz answer question renderer
                     select_multiple fill_in multiple_choice true_false
                     tex_output).
    map { |s| "lib/ruql/#{s}.rb" }
  s.files += %w(auto_qcm_renderer edxml_renderer html5_renderer html_form_renderer
                     json_renderer qualtrics_renderer xml_renderer).
    map { |s| "lib/ruql/renderers/#{s}.rb" }
  # add the templates
  s.files += Dir["templates/*.erb"]
  s.executables << 'ruqlcqb'
  # dependencies
  s.add_runtime_dependency 'builder'
  s.add_runtime_dependency 'getopt'
  s.homepage    = 'http://github.com/saasbook/ruql'
  s.license       = 'CC By-SA'
end