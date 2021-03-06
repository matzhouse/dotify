require 'dotify'
require 'thor/util'
require 'yaml'

module Dotify
  module Config

    extend self

    DEFAULTS = {
      :ignore => {
        :dotify => %w[.DS_Store .git .gitmodule .dotrc],
        :dotfiles => %w[.DS_Store .Trash .dropbox .dotify]
      }
    }.freeze

    def dir
      '.dotify'
    end

    def home(file_or_path = nil)
      file_or_path.nil? ? user_home : File.join(user_home, file_or_path)
    end

    def path(file_or_path = nil)
      joins = [self.home, self.dir]
      joins << file_or_path unless file_or_path.nil?
      File.join *joins
    end

    def installed?
      File.exists?(path) && File.directory?(path)
    end

    def editor
      get.fetch(:editor, 'vim')
    end

    def ignore(what)
      (get.fetch(:ignore, {}).fetch(what, []) + DEFAULTS[:ignore].fetch(what, [])).uniq
    end

    def get
      @hash ||= load!
    end

    def file
      File.join(path, '.dotrc')
    end

    def loader(f)
      return {} unless File.exists? f
      loaded = YAML.load_file(f)
      loaded == false ? {} : loaded
    rescue TypeError
      {}
    rescue Psych::SyntaxError
      {}
    end

    private

      def load!
        symbolize_keys! loader(self.file)
      end

      def user_home
        Thor::Util.user_home
      end

      def symbolize_keys!(opts)
        sym_opts = {}
        opts.each do |key, value|
          sym_opts[key.to_sym] = value.is_a?(Hash) ? symbolize_keys!(value) : value
        end
        sym_opts
      end

  end
end
