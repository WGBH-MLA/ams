Rails.application.routes.draw do

  if ENV['SETTINGS__BULKRAX__ENABLED'] == 'true'
    mount Bulkrax::Engine, at: '/'
  end

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
  get 'concern/assets/:id/download_media', to: 'hyrax/assets#download_media'

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

  # get 'pb_to_aapb', to: 'catalog#pb_to_aapb_form'
  # post 'pb_to_aapb', to: 'catalog#pb_to_aapb'
  # post 'validate_ids', to: 'catalog#validate_ids'
  resources :pushes, only: [:index,:show,:new,:create] do
    collection do
      post 'validate_ids', to: 'pushes#validate_ids'
      get 'transfer_query', to: 'pushes#transfer_query'
      get 'needs_updating', to: 'pushes#needs_updating'
    end
  end

  resources 'audits', only: [:new, :create]
  post "/audits/new" => "audits#create"

  # Routes under /sony_ci/*
  namespace :sony_ci do
    # Routes for the Webhook logs.
    resources :webhook_logs, only: [ :index, :show ]

    # Define routes that receive requests from Sony Ci webhooks.
    post '/webhooks/save_sony_ci_id', controller: 'webhooks',
                                      action: :save_sony_ci_id

    # Define routes for making customized requests to the Sony Ci API
    get '/api/find_media', controller: 'api', action: :find_media, defaults: { format: :json }
    get '/api/get_filename', controller: 'api', action: :get_filename, defaults: { format: :json }
  end

  namespace :api do
    resources :assets, only: [:show], defaults: { format: :json }
  end


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
