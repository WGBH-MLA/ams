Rails.application.routes.draw do

  mount Hyrax::BatchIngest::Engine, at: '/'
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  get 'catalog_export', to: 'catalog#export'

  mount Hydra::RoleManagement::Engine => '/'

  devise_for :users
  namespace :admin do
    resources :users, only: [:new, :index, :destroy]
    # Post route for creating new Users
    post 'savenew', to: 'users#savenew'
  end

  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resources 'media', only: [:show]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
