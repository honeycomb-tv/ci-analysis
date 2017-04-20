#!/usr/bin/env ruby

require "nokogiri"
require "json"
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
    data = JSON.parse(json)

    data.each do |test|
      failed = test['elements'].any? do |element|
        element['steps'].any? do |step|
          step['result']['status'] != 'passed'
        end
      end

      next unless failed
      record_failure(file: test.fetch('uri'),
                     name: test.fetch('name'),
                     type: :cucumber)
    end
  end

  private

  def record_failure(file:, name:, type:)
    failures.push(file: file, name: name, type: type)
  end
end

report = Report.new
report.analyse_rspec_output("./data/platform/2017-02-17T12:38:56Z-rspec.xml")
report.analyse_cucumber_output('data/platform/2017-04-20T14:17:43Z-cucumber/tests.cucumber')

pp report.failures
