# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  module Actors
    class AssetActor < Hyrax::Actors::BaseActor
      def create(env)
        contributions = extract_contributions(env)
        add_title_types(env)
        add_description_types(env)
        add_date_types(env)
        save_aapb_admin_data(env)
        super && create_or_update_contributions(env, contributions)
      end

      def update(env)
        contributions = extract_contributions(env)
        add_title_types(env)
        add_description_types(env)
        add_date_types(env)
        save_aapb_admin_data(env)
        super && create_or_update_contributions(env, contributions)
      end

      def destory(env)
        super && destory_admin_data(env)
      end

      private
        def save_aapb_admin_data(env)
          env.curation_concern.admin_data = find_or_create_admin_data(env)
          set_admin_data_attributes(env.curation_concern.admin_data,env)
          remove_admin_data_from_env_attributes(env)
        end

        def set_admin_data_attributes(admin_data,env)
          admin_data_attributes.each do |k|
            if [:special_collection,:sonyci_id].include?(k)
              admin_data.send("#{k.to_s}=",Array(env.attributes[k]))
            else
             admin_data.send("#{k.to_s}=",env.attributes[k].to_s)
            end
          end
        end

        def remove_admin_data_from_env_attributes(env)
          admin_data_attributes.each { |k| env.attributes.delete(k) }

        end

        def admin_data_attributes
          #removing id, created_at & updated_at from attributes
          AdminData.attribute_names.dup.tap {|admin| admin.shift() && admin.pop() && admin.pop() }.map &:to_sym
        end

        def find_or_create_admin_data(env)
          if env.curation_concern.admin_data_gid.blank?
            admin_data = AdminData.create
          else
            admin_data = AdminData.find_by_gid!(env.curation_concern.admin_data_gid)
          end
          admin_data
        end

        def destroy_admin_data(env)
          if env.curation_concern.admin_data_gid
            env.curation_concern.admin_data.destroy
          end
        end

        def extract_contributions(env)
            contributors = env.attributes[:contributors]
            env.attributes.delete(:contributors)
            # removing element where contributor is blank, as its req field
            contributors.select{|contributor| contributor unless contributor[:contributor].first.blank? }
        end

        def create_or_update_contributions(env, contributions)
            if(contributions.any? && !contributions.first["contributor"].blank?)
              contributions.each do |param_contributor|
                actor ||= Hyrax::CurationConcern.actor
                #Moving contributor into Array before saving object
                param_contributor[:contributor] = Array(param_contributor[:contributor])
                param_contributor[:admin_set_id] = env.curation_concern.admin_set_id
                param_contributor[:title] = env.attributes["title"]

                if param_contributor[:id].blank?
                  param_contributor.delete(:id)
                  contributor = ::Contribution.new
                  if actor.create(Actors::Environment.new(contributor, env.current_ability, param_contributor))
                    env.curation_concern.ordered_members << contributor
                    env.curation_concern.save
                  end
                elsif (contributor = Contribution.find(param_contributor[:id]))
                    param_contributor.delete(:id)
                    actor.update(Actors::Environment.new(contributor, env.current_ability, param_contributor))
                end
              end
            end
            #This method must return true
            true
        end

        def add_title_types(env)
          env.attributes[:title] = get_titles_by_type('main', env.attributes)
          env.attributes[:program_title] = get_titles_by_type('program', env.attributes)
          env.attributes[:episode_title] = get_titles_by_type('episode', env.attributes)
          env.attributes[:segment_title] = get_titles_by_type('segment', env.attributes)
          env.attributes[:raw_footage_title] = get_titles_by_type('raw_footage', env.attributes)
          env.attributes[:promo_title] = get_titles_by_type('promo', env.attributes)
          env.attributes[:clip_title] = get_titles_by_type('clip', env.attributes)

          # Now that we're done with these attributes, remove them from the
          # environment to avoid errors later in the save process.
          env.attributes.delete(:title_type)
          env.attributes.delete(:title_value)
        end

        def add_description_types(env)
          env.attributes[:description] = get_descriptions_by_type('main', env.attributes)
          env.attributes[:program_description] = get_descriptions_by_type('program', env.attributes)
          env.attributes[:episode_description] = get_descriptions_by_type('episode', env.attributes)
          env.attributes[:segment_description] = get_descriptions_by_type('segment', env.attributes)
          env.attributes[:raw_footage_description] = get_descriptions_by_type('raw_footage', env.attributes)
          env.attributes[:promo_description] = get_descriptions_by_type('promo', env.attributes)
          env.attributes[:clip_description] = get_descriptions_by_type('clip', env.attributes)

          # Now that we're done with these attributes, remove them from the
          # environment to avoid errors later in the save process.
          env.attributes.delete(:description_type)
          env.attributes.delete(:description_value)
        end

        def add_date_types(env)
          env.attributes[:broadcast_date] = get_dates_by_type('broadcast', env.attributes)
          env.attributes[:created_date] = get_dates_by_type('created', env.attributes)
          env.attributes[:copyright_date] = get_dates_by_type('copyright', env.attributes)

          # Now that we're done with these attributes, remove them from the
          # environment to avoid errors later in the save process.
          env.attributes.delete(:date_type)
          env.attributes.delete(:date_value)
        end

        def get_titles_by_type(title_type, attributes)
          attributes[:title_value].select.with_index do |title_value, index|
            attributes[:title_type][index] == title_type
          end
        end

        def get_descriptions_by_type(description_type, attributes)
          attributes[:description_value].select.with_index do |description_value, index|
            attributes[:description_type][index] == description_type
          end
        end

        def get_dates_by_type(date_type, attributes)
          attributes[:date_value].select.with_index do |date_value, index|
            attributes[:date_type][index] == date_type
          end
        end
    end
  end
end
