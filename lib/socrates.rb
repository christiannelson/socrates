# Socrates
require "socrates/version"
require "socrates/configuration"
require "socrates/logger"
require "socrates/string_helpers"
require "socrates/adapters/console"
require "socrates/adapters/memory"
require "socrates/adapters/slack"
require "socrates/adapters/stubs"
require "socrates/storage/memory"
require "socrates/storage/redis"
require "socrates/core/state_data"
require "socrates/core/state"
require "socrates/core/dispatcher"
require "socrates/bots/cli"
require "socrates/bots/slack"
require "socrates/bots/slack/ping"

module Socrates
end
