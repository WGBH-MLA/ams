module Hyrax
  module Actors
    class AssetFromPBCoreActor < Hyrax::Actors::BaseActor

      attr_reader :pbcore

      def create(env)
        set_env_from_pbcore!(env)
        # NOTE: Hyrax::Actors::BaseActor#create calls next_actor, so we don't
        # need to do that here.
        super
      end

      private

        def set_env_from_pbcore!(env)
          # TODO: Raise error if missing :pbcore_description_document
          @pbcore = env.attributes.delete(:pbcore_description_document)
          set_titles(env)
          set_descriptions(env)
          env
        end

        def set_titles(env)
          titles_by_type.each { |type, vals| env.attributes[type] = vals }
        end

        def set_descriptions(env)
          descriptions_by_type.each { |type, vals| env.attributes[type] = vals }
        end

        def group_by_attr_value(element_accessor, attr_name)
          {}.tap do |hash|
            Array(pbcore.send(element_accessor)).each do |element|
              attr_val = element.send(attr_name)
              key = yield(attr_val) if block_given?
              hash[key] ||= []
              hash[key] << element.value
            end
          end
        end

        def titles_by_type
          @titles_by_type = group_by_attr_value(:titles, :type) do |type|
            # Convert the type to lowercase, underscored, stip out the word
            # "title" which may or may not be there, and convert to symbol.
            type = type.downcase.gsub(/ +/, '_').gsub(/(_title)+/, '') if type
            title_types.include?(type) ? "#{type}_title" : 'title'
          end
        end

        def descriptions_by_type
          @descriptions_by_type ||= group_by_attr_value(:descriptions, :type) do |type|
            # Convert the type to lowercase, underscored, stip out the word
            # "title" which may or may not be there, and convert to symbol.
            type = type.downcase.gsub(/ +/, '_').gsub(/(_description)+/, '') if type
            description_types.include?(type) ? "#{type}_description" : 'description'
          end
        end

        def title_types
          ['program', 'episode', 'segment', 'clip', 'raw_footage']
        end

        def description_types
          title_types # same as title types
        end
    end
  end
end
