require "thor"

class BaseCLI < Thor
  def self.exit_on_failure?
    true
  end

  # Automatically give every command a `-h/--help`
  def self.extended(base)
    base.class_option :help, type: :boolean, aliases: "-h", desc: "Show help for this command"
  end

  no_commands do
    def check_help_for(command_name)
      if options[:help]
        invoke :help, [command_name]
        exit(0)
      end

      if ARGV.include?('-h') || ARGV.include?('--help')
        invoke :help, [command_name]
        exit(0)
      end
    end
  end
end
