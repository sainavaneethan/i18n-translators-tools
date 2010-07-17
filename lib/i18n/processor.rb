# -*- coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2
# 
# @author: Petr Kovar <pejuko@gmail.com>

module I18n::Translate

  module Processor
    @processors = []

    class << self
      attr_reader :processors
    end

    def self.<<(processor)
      @processors << processor
    end

    def self.read(fname, tr)
      processor = find_processor(fname)
      raise "Unknown file format" unless processor
      worker = processor.new(fname, tr)
      worker.read
    end

    def self.write(fname, data, tr)
      processor = find_processor(fname)
      raise "Unknown file format `#{fname}'" unless processor
      worker = processor.new(fname, tr)
      worker.write(data)
    end

    def self.find_processor(fname)
      @processors.each do |processor|
        return processor if processor.can_handle?(fname)
      end
      nil
    end


    class Template
      FORMAT = []

      def self.inherited(processor)
        Processor << processor
      end

      attr_reader :filename, :translate

      def initialize(fname, tr)
        @filename = fname
        @translate = tr
      end

      def read
        data = File.open(@filename, mode("r")) do |f|
          f.flock File::LOCK_SH
          f.read
        end
        import(data)
      end

      def write(data)
        File.open(@filename, mode("w")) do |f|
          f.flock File::LOCK_EX
          f << export(data)
        end
      end

      def self.can_handle?(fname)
        fname =~ %r{\.([^\.]+)$}
        self::FORMAT.include?($1)
      end

    protected

      def import(data)
        data
      end

      def export(data)
        data
      end

      def mode(m)
        mode = m.dup
        mode << ":" << @translate.options[:encoding] if defined?(Encoding)
        mode
      end
    end
  end

end


require 'i18n/processor/yaml'
require 'i18n/processor/ruby'
require 'i18n/processor/gettext'
