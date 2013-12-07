require 'slop'
require 'simple_http_monitor'

defaults = {
  tries:      '2,10,50,100,500',
  timeout:    5,
  work_dir:   '/tmp/simple_http_monitor'
}

cli = Slop.parse(strict: true, help: true, optional_arguments: true) do
  on :url       , "URL to monitor."
  on :tries     , "Set of fails before sending notification. Default: #{defaults[:tries]}."
  on :timeout   , "HTTP connection timeout in seconds."
  on :work_dir  , "Directory to persist results of work to."
  on :ops_email , "Email to send notifications to."
  on :from_email, "Email to send notifictions from."
  on :smtp_host , "Hostname of SMTP server."
  on :smtp_user , "Username on SMTP server."
  on :smtp_paswd, "Password for SMTP server."
  on :config    , "Path to config file. CLI argumants overwrite the velues from this file."
end

config_path    = cli[:config].to_s
if config_path.size > 0
  config_contents = File.read(config_path)
  config_options  = YAML.load(config_contents).inject({}) do |memo, (k,v)|
    memo[k.to_sym] = v
    memo
  end
end
cli_options = cli.to_hash.reject {|k,v| v.nil? }

options = defaults.
           merge(config_options).
           merge(cli_options)
options.delete(:config) # it was needed to load config file
options[:tries] = options[:tries].split(',').map(&:to_i)

SimpleHttpMonitor::Monitor.new(options).check
