#!/bin/env ruby

require "optparse"
require "json"
require "yaml"

OPTIONS = {
  :debug => false,
  :node_pattern => "%%.yaml",
  :data_dir => "/etc/puppetlabs/code/environments/*/hieradata",
  :default_environment => "production",
  :certname => nil
}

def debug(msg)
  return unless OPTIONS[:debug]

  File.open(OPTIONS[:debug], "a") do |f|
    f.puts("%s: %s" % [Time.now, msg])
  end
end

def data_dirs
  OPTIONS[:data_dir].split(File::PATH_SEPARATOR).map do |glob|
    Dir.glob(glob).map do |dir|
      File.expand_path(dir)
    end
  end.flatten
end

def node_patterns
  Array(OPTIONS[:node_pattern])
end

def validate_options!
  data_dirs.each do |dir|
    abort("Data directory %s does not exist" % OPTIONS[:data_dir]) unless File.directory?(dir)
  end

  abort("A certname is required") unless OPTIONS[:certname]
end

def node_data_paths
  data_dirs.map do |dir|
    node_patterns.map do |pattern|
      File.expand_path(File.join(dir, pattern.gsub("%%", OPTIONS[:certname])))
    end
  end.flatten
end

def parse(file)
  if file.match(/yaml$/)
    debug("Attempting to YAML parse %s" % file)
    YAML.load_file(file)

  elsif file.match(/json$/)
    debug("Attempting to JSON parse %s" % file)
    JSON.parse(File.read(file))

  else
    debug("Cannot figure out how to parse %s, returning {}" % file)
    {}
  end
end

def lookup_env
  environment = OPTIONS[:default_environment]
  found_path = "default"

  node_data_paths.each do |path|
    unless File.readable?(path)
      debug("Skipping %s as it's not readable" % path)
      next
    end

    data = parse(path)

    if data.include?("classifier::environment")
      environment = data["classifier::environment"]
      found_path = path
      break
    end
  end

  debug("Setting environment for %s to %s from %s" % [OPTIONS[:certname], environment, found_path])

  [environment, found_path]
end

def classify!
  environment, source = lookup_env

  classification = {
    "classes" => {
      "classifier" => {
        "enc_used" => true,
        "enc_source" => source,
        "enc_environment" => environment
      }
    },
    "environment" => environment
  }

  classification = YAML.dump(classification)
  debug("Classified %s with: \n%s" % [OPTIONS[:certname], classification])

  puts classification
rescue
  debug("Failed to classify node %s: %s: %s" % [OPTIONS[:certname], $!.class, $!.to_s])
  raise
end

def parse_options!
  opt = OptionParser.new

  opt.banner = "Usage: %s [options] <certname>" % $0

  opt.on("--debug [FILE]", "Enable debug logs to a file") do |v|
    OPTIONS[:debug] = v
  end

  opt.on("--node-pattern [PATTERN]", "-p", "Pattern to match nodes against (%s)" % OPTIONS[:node_pattern]) do |v|
    OPTIONS[:node_pattern] = v
  end

  opt.on("--data-dir [DIR]", "-d", "'%s' Separated directories to look for node files in (%s)" % [File::PATH_SEPARATOR, OPTIONS[:data_dir]]) do |v|
    OPTIONS[:data_dir] = v
  end

  opt.on("--default [ENVIRONMENT]", "Default environment when nothing is found (%s)" % OPTIONS[:default_environment]) do |v|
    OPTIONS[:default_environment] = v
  end

  opt.parse!

  OPTIONS[:certname] = ARGV.shift

  validate_options!
end

parse_options!
classify!
