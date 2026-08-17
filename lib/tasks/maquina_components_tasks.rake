# frozen_string_literal: true

namespace :maquina do
  desc "Scan this app's CSS/views/JS for patterns a maquina-components release changes (advisory, always exits 0)"
  task :doctor, [:path] do |_task, args|
    require_relative "../maquina_components/doctor"

    # Scans Rails.root by default; a path argument or MAQUINA_DOCTOR_PATH lets
    # you point it somewhere else: rake "maquina:doctor[../other_app]"
    root = args[:path].to_s
    root = ENV["MAQUINA_DOCTOR_PATH"].to_s if root.empty?
    root = ((defined?(Rails) && Rails.respond_to?(:root) && Rails.root) || Dir.pwd).to_s if root.empty?

    puts MaquinaComponents::Doctor.new(root).run.report
  end
end
