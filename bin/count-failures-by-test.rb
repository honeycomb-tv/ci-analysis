#!/usr/bin/env ruby

require "fileutils"
require "nokogiri"
require "json"
require "csv"
require "pp"

class Report
  attr_reader :failures

  def initialize
    @failures = []
  end

  def analyse_rspec_output(path)
    xml = File.read(path)
    doc = Nokogiri::XML(xml)
    doc.css("testcase failure").each do |failure|
      test = failure.parent
      record_failure(file: test.attributes["file"].value,
                     name: test.attributes["name"].value,
                     type: :rspec)
    end
  end

  def analyse_cucumber_output(path)
    json = File.read(path)
    return if json == ""
    data = JSON.parse(json)

    data.each do |test|
      test["elements"].each do |element|
        next if element.fetch('keyword') == 'Background'

        failed = element["steps"].any? do |step|
          step["result"]["status"] != "passed"
        end

        next unless failed
        name = element.fetch('name', 'nil')
        record_failure(file: test.fetch("uri"), name: name, type: :cucumber)
      end
    end
  end

  def grouped_failures
    failures.each.with_object({}) do |failure, acc|
      name = failure.fetch(:name)
      record = acc.fetch(name, failure.merge(count: 0))
      record[:count] = record.fetch(:count) + 1
      acc[name] = record
    end
  end

  private

  def record_failure(file:, name:, type:)
    failures.push(file: file, name: name, type: type)
  end
end

start_time = Time.now
report = Report.new
cucumber_files = Dir.glob("./data/platform/*cucumber/*")
rspec_files = Dir.glob("./data/platform/*-rspec.xml")
total = rspec_files.size + cucumber_files.size

puts "#{total} files to process"

cucumber_files.each.with_index do |path, index|
  puts "#{index + 1}/#{total}: #{path}"
  report.analyse_cucumber_output(path)
end

rspec_files.each.with_index do |path, index|
  puts "#{cucumber_files.size + index + 1}/#{total}: #{path}"
  report.analyse_rspec_output(path)
end

puts "Processed #{total} files in #{Time.now - start_time} seconds"
puts "Writing to ./output/"

FileUtils.mkdir_p("./output")
File.write("./output/failures.json", report.failures.to_json)
grouped_failures = report.grouped_failures
File.write("./output/grouped-failures.json", grouped_failures.to_json)

CSV.open("./output/failure-report.csv", "wb") do |csv|
  csv << ["name", "file", "type", "number of failures"]
  grouped_failures.values
                  .sort_by { |failure| failure.fetch(:count) }
                  .reverse
                  .each do |failure|
    csv << [failure.fetch(:name),
            failure.fetch(:file),
            failure.fetch(:type),
            failure.fetch(:count)]
  end
end
