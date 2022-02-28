# ams

Archival Management System to support the American Archive of Public Broadcasting

`master`:  [![Build Status](https://travis-ci.org/WGBH-MLA/ams.svg?branch=master)](https://travis-ci.org/WGBH-MLA/ams)
`develop`: [![Build Status](https://travis-ci.org/WGBH-MLA/ams.svg?branch=develop)](https://travis-ci.org/WGBH-MLA/ams)

The Archival Managment System is an application using the [Hyrax gem](https://github.com/samvera/hyrax) to provide a repository for [PBCore](http://pbcore.org/) data about externally hosted AV content. It includes models, controllers, actors, and presenters for PBCore-based worktypes of Assets, Contributions, Physical Instantiations, Digital Instantiations, and Essence Tracks.

AMS also adds the ability to export records in several user-friendly CSV reports and PBCore XML files, as well as using [hyrax-batch_ingest gem](https://github.com/samvera-labs/hyrax-batch_ingest) to implement batch ingest of PBCore XML and spreadsheets, and batch metadata updates via spreadsheets.

### Enable Bulkrax:

- Add SETTINGS__BULKRAX__ENABLED=true to [.env](.env) files
- Add `  require bulkrax/application` to app/assets/javascripts/application.js and app/assets/stylesheets/application.css files.

(in a `docker-compose exec web bash` if you're doing docker otherwise in your terminal)
```bash
bundle exec rails db:migrate
```

### Dependencies

* **[Fedora Commons Repository](https://duraspace.org/fedora/)** is the data repository platform. Fedora provides an HTTP endpoint that the AMS application
* **[Solr](https://lucene.apache.org/solr/)** is used for search.
* **[Redis](https://redis.io)** is used for storing information about background jobs.
* **[Sidekiq](https://github.com/mperham/sidekiq)** is used for scheduling and processing background jobs.
* **[Ruby on Rails](https://rubyonrails.org)** is the web framework used for building the application.
* **[Hyrax](https://hyrax.samvera.org)** is the Ruby on Rails plugin that provides many repository features for AMS.
* **[MySQL](https://www.mysql.com)** is the relational database used used by both the web application and by Fedora.
