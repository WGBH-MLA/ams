class Ability
  include Hydra::Ability
  include Hyrax::Ability
  include Hyrax::BatchIngest::Ability

  # IMPORTANT! This is a list of methods that modify the Ability's permissions
  # and the order matters! Subsequent definitions overwrite previous ones,
  # including those that are set in the included modules above.
  # Best practice:
  #   * Use methods for defining permissions that are logically related
  #     (e.g. permission for a given user group).
  #   * Start with blanket restrictions, and then seletively enable permissions
  #     in subsequent methods.
  #   * It's OK to have redundant permission declarations if it means abilities
  #     are easier to read and modify without unexpected side effects.
  self.ability_logic += [
    :ams_base_permissions,
    :ams_admin_permissions,
    :ams_ingester_permissions,
    :ams_aapb_admin_permissions
  ]

  # Sets permissions for all users.
  def ams_base_permissions
    # Minimal permissions for everybody
    can [:show], [ AdminData,
                   InstantiationAdminData,
                   Asset,
                   EssenceTrack,
                   PhysicalInstantiation,
                   DigitalInstantiation,
                   Collection,
                   Contribution,
                   Annotation ]

    # Explicitly forbid these actions.
    cannot [:destroy, :update], [ AdminData,
                                  InstantiationAdminData,
                                  Asset,
                                  EssenceTrack,
                                  PhysicalInstantiation,
                                  DigitalInstantiation,
                                  Collection,
                                  Contribution,
                                  Annotation ]
  end

  # Sets permisisons for 'admin' users.
  def ams_admin_permissions
    return unless current_user.admin?
    can :manage, :all
  end

  # Sets permission for 'ingester' users
  def ams_ingester_permissions
    return unless user_groups.include? 'ingester'
    can [:create, :update], [ Asset,
                              EssenceTrack,
                              PhysicalInstantiation,
                              DigitalInstantiation,
                              Collection,
                              Contribution,
                              AdminData,
                              InstantiationAdminData,
                              Annotation ]

    # Field-level permissions for Admin Data
    can [ :update_sonyci_id, :update_hyrax_batch_ingest_batch_id, :update_last_pushed,
         :update_last_updated, :update_needs_update ], AdminData
  end

  # Sets permissions for 'aapb-admin' users.
  def ams_aapb_admin_permissions
    return unless user_groups.include?('aapb-admin')
    can [:create, :update, :destroy], [ AdminData,
                                        InstantiationAdminData,
                                        Asset,
                                        EssenceTrack,
                                        PhysicalInstantiation,
                                        DigitalInstantiation,
                                        Collection,
                                        Contribution,
                                        Annotation ]
  end
end
