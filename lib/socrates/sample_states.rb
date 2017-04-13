require 'date'

require 'socrates/core/state'

module Socrates
  module SampleStates
    class StateFactory
      def default_state
        :get_started
      end

      def build(state_data:, chatbot_client:, context: nil)
        classname = StringHelpers.underscore_to_classname(state_data.state_id)

        Object::const_get("Socrates::SampleStates::#{classname}")
          .new(data: state_data, chatbot_client: chatbot_client, context: context)
      end
    end

    class GetStarted
      include Socrates::Core::State

      def listen(message)
        case message.strip
          when 'help'
            transition_to :help
          when 'age'
            transition_to :ask_for_name
          when 'error'
            transition_to :raise_error
          else
            transition_to :no_comprende
        end
      end
    end

    class Help
      include Socrates::Core::State

      def say
        respond message: <<~MSG
          Thanks for asking! I can do these things for you...

            • `age` - Calculate your age from your birth date.
            • `error` - Start a short error path that raises an error.
            • `help` - Tell you what I can do for you.

          So, what shall it be?
        MSG

        transition_to :get_started, action: :listen
      end
    end

    class NoComprende
      include Socrates::Core::State

      def say
        respond message: "Whoops, I don't know what you mean by that. Try `help` to see my commands."

        transition_to :get_started
      end
    end

    class AskForName
      include Socrates::Core::State

      def say
        respond message: "First things first, what's your name?"
      end

      def listen(message)
        transition_to :ask_for_birth_date, data: { name: message }
      end
    end

    class AskForBirthDate
      include Socrates::Core::State

      def say
        respond message: "Hi #{first_name}! What's your birth date (e.g. MM/DD/YYYY)?"
      end

      def listen(message)
        begin
          birth_date = Date.strptime(message, '%m/%d/%Y')

        rescue ArgumentError
          respond message: "Whoops, I didn't get that. Can you try again? What's your birth date (e.g. MM/DD/YYYY)?"
          repeat_action
          return
        end

        transition_to :calculate_age, data: { birth_date: birth_date.strftime('%y/%m/%d') }
      end

      def first_name
        @data.get(:name).split.first
      end
    end

    class CalculateAge
      include Socrates::Core::State

      def say
        birth_date = Date.parse(@data.get(:birth_date))
        age        = calculated_age(birth_date)

        respond message: "Got it #{first_name}! So that makes you #{age} years old."

        # Example of a :say => :say transition.
        transition_to :end_conversation_1
      end

      def first_name
        @data.get(:name).split.first
      end

      def calculated_age(birth_date)
        ((Date.today.to_time - birth_date.to_time) / 31_536_000).floor
      end
    end

    class EndConversation1
      include Socrates::Core::State

      def say
        respond message: "That's all for now..."

        # Example of another :say => :say transition.
        transition_to :end_conversation_2
      end
    end

    class EndConversation2
      include Socrates::Core::State

      def say
        respond message: "Type `help` to see what else I can do."

        end_conversation
      end
    end

    class RaiseError
      include Socrates::Core::State

      def say
        respond message: "I will raise an error regardless of what you enter next..."
      end

      def listen(_message)
        raise ArgumentError.new
      end
    end
  end
end
