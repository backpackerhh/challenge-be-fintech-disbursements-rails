# frozen_string_literal: true

require "rake"

RSpec.shared_context "rake" do
  subject(:task) { rake[task_name] }

  let(:rake) { Rake::Application.new }
  let(:task_name) { self.class.top_level_description }
  let(:namespaces_count) { task_name.scan(/(?=:)/).count }
  let(:task_namespace) { task_name.split(":").take(namespaces_count).join("/") }
  let(:task_path) { "lib/tasks/#{task_namespace}" }
  let(:task_alternative_path) { "lib/tasks/#{task_namespace}/#{task_name.split(':').drop(namespaces_count).join('_')}" }

  def rake_require_file(file_path, loaded_files)
    Rake.application.rake_require(file_path, [Rails.root.to_s], loaded_files)
  end

  before do
    Rake.application = rake
    Rake::Task.define_task(:environment)

    loaded_files = $LOADED_FEATURES.reject do |file_path|
      [Rails.root.join("#{task_path}.rake").to_s,
       Rails.root.join("#{task_alternative_path}.rake").to_s].include?(file_path)
    end

    begin
      rake_require_file(task_path, loaded_files)
    rescue LoadError
      rake_require_file(task_alternative_path, loaded_files)
    end
  end
end
