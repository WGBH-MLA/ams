class Ability
  include Hydra::Ability

  include Hyrax::Ability
  include Hyrax::BatchIngest::Ability

  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    # Probbly too permissive in the long run. Replace and augment with
    # hydra-role-management gem in long run.
    can [:create], Asset
    can [:create], EssenceTrack
    can [:create], PhysicalInstantiation
    can [:create], DigitalInstantiation
    can [:create], Collection
    can [:create], Contribution

    cannot [:destroy], Asset
    cannot [:destroy], EssenceTrack
    cannot [:destroy], PhysicalInstantiation
    cannot [:destroy], DigitalInstantiation
    cannot [:destroy], Collection
    cannot [:destroy], Contribution

    # Limits deleting objects to a the admin user
    #
    # if user_groups.include? 'aapb-admin'
    #   can [:destroy], ActiveFedora::Base
    # end
    # cannot [:destroy], ActiveFedora::Base
    
    # this will not block direct delete requests to the destroy action ^^^ you have to explicitly check in controller

    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
      can [:create, :savenew, :new, :index, :edit, :update, :destroy], User

      # push ids to AAPB
      can [:index,:show,:new,:create,:validate_ids,:transfer_query,:needs_updating], Push
      can :push_to_aapb
    end
    if user_groups.include? 'aapb-admin'
      can [:create], AdminData
      can [:create], InstantiationAdminData


      # This only allows us to check can? :destroy in the view. does not permit deleting!!!!!
      can [:destroy], Asset
      can [:destroy], EssenceTrack
      can [:destroy], PhysicalInstantiation
      can [:destroy], DigitalInstantiation
      can [:destroy], Collection
      can [:destroy], Contribution
    end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
  end
end
