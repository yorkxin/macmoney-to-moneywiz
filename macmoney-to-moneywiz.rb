#!/bin/env ruby

require 'cfpropertylist'
require 'csv'

if ARGV.length != 2
  $stderr.puts "usage: #{$0} your_database.plist export.csv"
  exit(1)
end

puts "Reading #{ARGV[0]}, be pacient..."

data = CFPropertyList.native_types(CFPropertyList::List.new(:file => ARGV[0]).value)

puts "Writing #{data["MainData"].size} transactions..."

fout = CSV(File.open(ARGV[1], "w"))

data["MainData"].each do |row|
  account1 = row["Account1"]
  account2 = row["Account2"]
  amount = row["Amount"]
  color = row["Color"]
  date = row["Date"]
  is_done = row["Done"]
  note_1 = row["Note1"]
  note_2 = row["Note2"]

  transfer = ""

  if account1.start_with? "A-"
    # transfer
    transfer = account1
    amount = amount * -1
  elsif account1.start_with? "E-"
    # expense
    category = account1
    amount = amount * -1
  elsif account1.start_with? "I-"
    # income
    category = account1
  else
    raise "Unknown account1: #{account1}"
  end

  fout << [
    date.strftime("%F"),
    account2,
    transfer,
    category,
    amount,
    note_1
  ]
end

fout.close()

puts "Please create the following accounts:"
puts ""

data["Accounts"].each do |account|
  next unless account["Type"] == "A-"

  hidden = account["Hide"] ? "Hidden" : nil
  notes = [hidden].compact.join(', ')

  puts "- #{account["Name"]}"
  puts "  * Open Balance: #{account["Amount"]}"
  puts "  * #{notes}"
end

