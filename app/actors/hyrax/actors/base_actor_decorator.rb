# frozen_string_literal: true
#
# OVERRIDE HYRAX-BaseActor to remove ActiveFedora specific save code
module Hyrax
  module Actors
    module BaseActorDecorator

      def valkyrie_save(resource:, is_valid:)
        permissions = resource.permission_manager.acl.permissions
        # removed Active Fedora reference that can cause some issues in postgres only persistance
        resource    = Hyrax.persister.save(resource: resource)

        resource.permission_manager.acl.permissions = permissions
        resource.permission_manager.acl.save
        resource
      end
    end
  end
end
Hyrax::Actors::BaseActor.prepend(Hyrax::Actors::BaseActorDecorator)