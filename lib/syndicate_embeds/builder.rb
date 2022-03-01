require 'string'

class SyndicateEmbeds

  class Builder
    def initialize()
      @@embed_db ||= JSON.parse(EmbedsHash.to_json, object_class:OpenStruct)
    end

    def embed_db
      @@embed_db
    end

    def convert_error(error)
      return :no_error if error.nil?
      return error
               .class.to_s
               .split(/::/)
               .last
               .to_underscore
               .to_sym unless error.class == Symbol
      error
    end

    def send(type,
             event: nil,
             channel: event.channel,
             error: nil,
             discord_id_list: nil,
             custom_id: nil
            )

      error = convert_error(error)
      entry = embed_db.send(type).send(error)
      discord_id_list = format_mentions(discord_id_list) if error == :no_error
      add_content(event, entry) if has_content?(entry)

      channel.send_embed do |embed, view|
        add_title(embed, entry) if has_title?(entry)
        add_description(embed, entry, discord_id_list) if has_description?(entry)
        add_fields(embed, entry, discord_id_list) if has_fields?(entry)
        add_button(entry, view, custom_id) if has_button?(entry)
        embed.colour = entry.color
        embed.timestamp = Time.now
      end
    end

    def update(type,
               event: nil,
               error: nil,
               discord_id_list: nil
              )

      error = convert_error(error)
      entry = embed_db.send(type).send(error)
      discord_id_list = format_mentions(discord_id_list) unless discord_id_list.nil?
      event.interaction.edit_response(content: '`[accept]:`')

      event.channel.send_embed do |embed, view|
        add_title(embed, entry) if has_title?(entry)
        add_description(embed, entry, discord_id_list) if has_description?(entry)
        add_fields(embed, entry, discord_id_list) if has_fields?(entry)
        embed.colour = entry.color
        embed.timestamp = Time.now
      end
    end

    def format_mentions(discord_id_list)
      if discord_id_list.class == Array
        format_discord_id_mention_list(discord_id_list)
      elsif discord_id_list.class == String
        format_discord_id_mention(discord_id_list)
      else
        discord_id_list
      end
    end

    def has_content?(entry)
      !entry.content.nil?
    end

    def add_content(event, entry)
      event.respond(content: entry.content)
    end

    def has_title?(entry)
      !entry.title.nil?
    end

    def add_title(embed, entry)
      embed.title = entry.title
    end

    def has_description?(entry)
      !entry.description.nil?
    end

    def add_description(embed, entry, discord_id_list)
      description = entry.description
      embed.description =
        [description, discord_id_list]
          .join('')
    end

    def has_fields?(entry)
      !entry.fields.nil?
    end

    def add_fields(embed, entry, discord_id_list)
      embed.add_field(name: entry.fields.red,
                      value: format_discord_id_mention_list(discord_id_list[:red]),
                      inline: false)
      embed.add_field(name: entry.fields.blue,
                      value: format_discord_id_mention_list(discord_id_list[:blue]),
                      inline: false)
    end

    def has_button?(entry)
      !entry.button_text.nil?
    end

    def add_button(entry, view, custom_id)
      view.row do |r|
        r.button(
          label: entry.button_text,
          style: :primary,
          custom_id: custom_id
        )
      end
    end

  end
end
