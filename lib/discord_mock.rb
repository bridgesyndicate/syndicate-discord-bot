class DiscordMock
  class Interaction
    attr_accessor :response

    def edit_response(args={})
      @response = args
    end
  end

  class Event
    attr_accessor :channel, :interaction

    def initialize
      @channel = Channel.new
      @interaction = Interaction.new
    end

    def respond(args={})
    end

  end

  class Embed
    attr_accessor :description, :colour, :timestamp, :title, :fields
    def initialize
      @fields = []
    end

    def add_field(args={})
      @fields << args
    end
  end

  class Button
    attr_accessor :attributes
    def initialize(attributes)
      @attributes = attributes
    end
  end

  class Row
    attr_accessor :buttons

    def initialize
      @buttons = []
    end

    def button(attributes = {}, &block)
      @buttons << Button.new(attributes)
    end
  end

  class View
    attr_accessor :rows

    def initialize
      @rows = []
    end

    def row(attributes={}, &block)
      new_row = Row.new
      @rows << new_row
      yield new_row
    end
  end

  class Message
    attr_accessor :embed, :view

    def initialize(embed, view)
      @embed = embed
      @view = view
    end
  end

  class Channel
    attr_accessor :messages

    def initialize
      @messages = []
    end

    def send_embed(message = '', embed = nil, attachments = nil, tts = false, allowed_mentions = nil, message_reference = nil, components = nil, &block)
      embed = Embed.new
      view = View.new
      if block_given?
        yield(embed, view)
        messages << Message.new(embed, view)
      end
    end
  end
end
