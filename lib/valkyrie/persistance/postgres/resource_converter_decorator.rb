# OVERRIDE Valkyrie 3.0.1 to add custom ids
module Valkyrie
  module Persistence
    module Postgres
      class ResourceConverter
        # Converts the Valkyrie Resource into an ActiveRecord object
        # @return [ORM::Resource]
        def convert!
          current_id = resource.id || AMS::IdentifierService.mint
          orm_class.find_or_initialize_by(id: current_id.to_s).tap do |orm_object|
            orm_object.internal_resource = resource.internal_resource
            process_lock_token(orm_object)
            orm_object.disable_optimistic_locking! unless resource.optimistic_locking_enabled?
            orm_object.metadata = attributes
          end
        end
      end
    end
  end
end
