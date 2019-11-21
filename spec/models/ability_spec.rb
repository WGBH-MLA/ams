require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  # User is defined
  let(:subject) { Ability.new user }

  context 'for any user (no group)' do
    let(:user) { create(:user) }

    it { is_expected.to be_able_to(:show, Asset) }
    [:create, :update, :destroy].each do |action|
      it { is_expected.not_to be_able_to(action, Asset) }
    end

    it { is_expected.to be_able_to(:show, DigitalInstantiation) }
    [:create, :update, :destroy].each do |action|
      it { is_expected.not_to be_able_to(action, DigitalInstantiation) }
    end

    it { is_expected.to be_able_to(:show, PhysicalInstantiation) }
    [:create, :update, :destroy].each do |action|
      it { is_expected.not_to be_able_to(action, PhysicalInstantiation) }
    end

    it { is_expected.to be_able_to(:show, EssenceTrack) }
    [:create, :update, :destroy].each do |action|
      it { is_expected.not_to be_able_to(action, EssenceTrack) }
    end

    it { is_expected.to be_able_to(:show, Contribution) }
    [:create, :update, :destroy].each do |action|
      it { is_expected.not_to be_able_to(action, Contribution) }
    end

    it { is_expected.to be_able_to(:show, Collection) }
    [:create, :update, :destroy].each do |action|
      it { is_expected.not_to be_able_to(action, Collection) }
    end

    it { is_expected.to be_able_to(:show, AdminData) }
    [ :create,
      :update,
      :destroy,
      :update_level_of_user_access,
      :update_minimally_cataloged,
      :update_outside_url,
      :update_sonyci_id,
      :update_licensing_info,
      :update_playlist_group,
      :update_playlist_order,
      :update_hyrax_batch_ingest_batch_id,
      :update_last_pushed,
      :update_last_updated,
      :update_needs_update ].each do |action|
      it { is_expected.not_to be_able_to(action, AdminData) }
    end
  end

  context ', given a user who is part of the "ingester" group, ' do
    let(:user) { create(:user, role_names: [:ingester]) }

    # An 'ingester' user may create and update the following object types.
    [:create, :update].each do |action|
      it { is_expected.to be_able_to(action, Asset) }
      it { is_expected.to be_able_to(action, DigitalInstantiation) }
      it { is_expected.to be_able_to(action, PhysicalInstantiation) }
      it { is_expected.to be_able_to(action, Collection) }
      it { is_expected.to be_able_to(action, EssenceTrack) }
      it { is_expected.to be_able_to(action, Contribution) }
    end

    # An 'ingester' user may create AdminData, but not update all fields.
    it { is_expected.to be_able_to(:create, AdminData) }

    # An 'ingestser' user may update specific fields on AdminData objects.
    it { is_expected.to be_able_to(:update_level_of_user_access, AdminData) }
    it { is_expected.to be_able_to(:update_minimally_cataloged, AdminData) }
    it { is_expected.to be_able_to(:update_outside_url, AdminData) }
    it { is_expected.to be_able_to(:update_sonyci_id, AdminData) }
    it { is_expected.to be_able_to(:update_licensing_info, AdminData) }
    it { is_expected.to be_able_to(:update_playlist_group, AdminData) }
    it { is_expected.to be_able_to(:update_playlist_order, AdminData) }
    it { is_expected.to be_able_to(:update_hyrax_batch_ingest_batch_id, AdminData) }
    it { is_expected.to be_able_to(:update_last_pushed, AdminData) }
    it { is_expected.to be_able_to(:update_last_updated, AdminData) }
    it { is_expected.to be_able_to(:update_needs_update, AdminData) }
  end

  context ', given a user who is part of the "admin" group, ' do
    let(:user) { create(:admin_user) }

    it { is_expected.to be_able_to(:manage, :all) }

    # it { is_expected.to be_able_to([:create, :update, :destroy], Asset) }
    # it { is_expected.to be_able_to([:create, :update, :destroy], DigitalInstantiation) }
    # it { is_expected.to be_able_to([:create, :update, :destroy], PhysicalInstantiation) }
    # it { is_expected.to be_able_to([:create, :update, :destroy], Collection) }
    # it { is_expected.to be_able_to([:create, :update, :destroy], EssenceTrack) }
    # it { is_expected.to be_able_to([:create, :update, :destroy], Contribution) }
    #
    #
    # it 'an create, update, and destroy a Role' do
    #   [:create, :update, :destroy].each do |action|
    #
    #   end
    #   expect(subject.can?(action, Role)).to eq true
    # end
    #
    # it 'an create, update, and destroy a Contribution' do
    #   expect(subject.can?([:create, :update, :destroy], Contribution)).to eq true
    # end
    #
    # it 'an create, update, and destroy a AdminData' do
    #   expect(subject.can?([:create, :update, :destroy], AdminData)).to eq true
    # end
    #
    # it { is_expected.to be_able_to([:create, :update, :destroy], Role) }
    # it { is_expected.to be_able_to(:create, Role) }
    # it { is_expected.to be_able_to(:update, Role) }
    # it { is_expected.to be_able_to(:destroy, Role) }
    # it { is_expected.to be_able_to([:create, :update, :destroy], User) }
    # it { is_expected.to be_able_to([:create, :update, :destroy], Push) }
  end
end
