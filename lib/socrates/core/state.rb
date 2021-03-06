require "hashie"
require "erb"

require "socrates/configuration"
require "socrates/logger"
require "socrates/string_helpers"
require "socrates/core/state_data"

module Socrates
  module Core
    module State
      attr_reader :data, :adapter, :session, :user

      def initialize(adapter:, session:, data: StateData.new)
        @data              = data
        @adapter           = adapter
        @session           = session
        @user              = session.user
        @next_state_id     = nil
        @next_state_action = nil
        @logger            = Socrates.config.logger || Socrates::Logger.default
      end

      def next_state_id
        if @next_state_id.nil?
          state_id_from_classname
        else
          @next_state_id
        end
      end

      def next_state_action
        if @next_state_action.nil?
          next_action(@data.state_action)
        else
          @next_state_action
        end
      end

      def respond(message: nil, template: nil, send_now: false)
        if template
          # TODO: Partials?
          filename = File.join(Socrates.config.view_path, template)
          source   = File.read(filename)
          message  = ERB.new(source, 0, "<>").result(binding)
        end

        return if message.empty?

        @logger.info %Q(#{@session.channel} send: "#{format_for_logging(message)}")
        @adapter.queue_message(@session, message, send_now: send_now)
      end

      def send_message(to:, message:)
        displayable_to = to.respond_to?(:id) ? to.id : to

        @logger.info %Q(#{@session.channel} send direct to #{displayable_to}: "#{format_for_logging(message)}")
        @adapter.queue_direct_message(@session, message, to)
      end

      def transition_to(state_id, action: nil, data: {})
        if action.nil?
          action =
            if state_id.nil?
              nil
            elsif state_id == state_id_from_classname
              next_action(@data.state_action)
            else
              :ask
            end
        end

        @next_state_id     = state_id
        @next_state_action = action

        @data.merge(data)
      end

      def repeat_action
        @next_state_id     = @data.state_id
        @next_state_action = @data.state_action
      end

      def end_conversation
        @data.clear

        transition_to StateData::END_OF_CONVERSATION, action: StateData::END_OF_CONVERSATION
      end

      def ask
        # stub implementation, to be overwritten.
      end

      def listen(_message)
        # stub implementation, to be overwritten.
      end

      private

      def next_action(current_action)
        (%i[ask listen] - [current_action]).first
      end

      def format_for_logging(message)
        message.gsub("\n", "\\n")
      end

      def state_id_from_classname
        StringHelpers.classname_to_underscore(self.class.to_s.split("::").last).to_sym
      end
    end
  end
end
