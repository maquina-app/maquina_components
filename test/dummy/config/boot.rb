# Set up gems listed in the Gemfile.
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../../Gemfile", __dir__)
# Absolute, so a relative override survives Rails changing the working directory.
ENV["BUNDLE_GEMFILE"] = File.expand_path(ENV["BUNDLE_GEMFILE"])

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])
require "bootsnap/setup" # Speed up boot time by caching expensive operations

# Under Gemfile.branch the engine is resolved from GitHub, and the source tree
# must not shadow it — otherwise the check proves nothing.
unless File.basename(ENV["BUNDLE_GEMFILE"].to_s) == "Gemfile.branch"
  $LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
end
