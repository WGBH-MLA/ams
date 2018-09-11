require 'rails_helper'
require_relative '../../../app/search_builders/ams/search_builder'

RSpec.describe AMS::SearchBuilder do
  let(:me) { create(:user) }

  let(:config) { CatalogController.blacklight_config }

  let(:scope) do
    double('The scope',
           blacklight_config: config,
           current_ability: Ability.new(me),
           current_user: me)
  end

  let(:builder) { described_class.new(scope).with(params_object) }
  let(:builder_params) { builder[:fq].map { |fq_param_val| "fq=#{fq_param_val}"  }.join('&') }
  let(:after_date) { "2010-10-10" }
  let(:before_date) { "2011-11-11" }
  let(:params_object) { ActionController::Parameters.new(
      'controller' => 'catalog',
      'action' => 'index') }


  describe '#apply_date_filter' do
    context 'when no dates are supplied' do
      it 'does not include any filters for date fields' do
        expect(builder_params).to_not include("date_drsim")
        expect(builder_params).to_not include("broadcast_date_drsim")
        expect(builder_params).to_not include("created_date_drsim")
        expect(builder_params).to_not include("copyright_date_drsim")
      end
    end

    context 'when the "exact" radio button is selected and when the first date is supplied' do
      before do
        params_object['exact_or_range'] = 'exact'
        params_object['after_date'] = after_date
      end

      it 'adds parameters that filter results to records whose date matches the supplied parameter' do
        expect(builder_params).to include("{!field f=date_drsim op=Within}[#{after_date} TO #{after_date}]")
        expect(builder_params).to include("{!field f=broadcast_date_drsim op=Within}[#{after_date} TO #{after_date}]")
        expect(builder_params).to include("{!field f=created_date_drsim op=Within}[#{after_date} TO #{after_date}]")
        expect(builder_params).to include("{!field f=copyright_date_drsim op=Within}[#{after_date} TO #{after_date}]")
      end
    end

    context 'when the "range" radio button is selected' do
      before { params_object['exact_or_range'] = 'range' }

      context 'and when the "after_date" param is supplied' do
        before { params_object['after_date'] = after_date }

        it 'adds parameters that filter results to records whose dates are after the supplied parameter' do
          expect(builder_params).to include("{!field f=date_drsim op=Within}[#{after_date} TO *]")
          expect(builder_params).to include("{!field f=broadcast_date_drsim op=Within}[#{after_date} TO *]")
          expect(builder_params).to include("{!field f=created_date_drsim op=Within}[#{after_date} TO *]")
          expect(builder_params).to include("{!field f=copyright_date_drsim op=Within}[#{after_date} TO *]")
        end
      end

      context 'and when the "before_date" param is supplied' do
        before { params_object['before_date'] = before_date }

        it 'adds parameters that filter results to records whose dates are before the supplied parameter' do
          expect(builder_params).to include("{!field f=date_drsim op=Within}[* TO #{before_date}]")
          expect(builder_params).to include("{!field f=broadcast_date_drsim op=Within}[* TO #{before_date}]")
          expect(builder_params).to include("{!field f=created_date_drsim op=Within}[* TO #{before_date}]")
          expect(builder_params).to include("{!field f=copyright_date_drsim op=Within}[* TO #{before_date}]")
        end
      end

      context 'and when both "after_date" and "before_date" are supplied' do
        before do
          params_object['after_date'] = after_date
          params_object['before_date'] = before_date
        end

        it 'adds parameters that filter results to records whose dates are between the supplied parameters' do
          expect(builder_params).to include("{!field f=date_drsim op=Within}[#{after_date} TO #{before_date}]")
          expect(builder_params).to include("{!field f=broadcast_date_drsim op=Within}[#{after_date} TO #{before_date}]")
          expect(builder_params).to include("{!field f=created_date_drsim op=Within}[#{after_date} TO #{before_date}]")
          expect(builder_params).to include("{!field f=copyright_date_drsim op=Within}[#{after_date} TO #{before_date}]")
        end
      end
    end
  end
end
