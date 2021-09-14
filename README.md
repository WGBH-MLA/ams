[Docker development setup](#docker-development-setup)

[Bash into the container](#bash-into-the-container)

[Handling Secrets with SOPS](#handling-secrets-with-sops)

[Deploy a new release](#deploy-a-new-release)
  
[Run import from admin page](#run-import-from-admin-page)

# Docker development setup

We recommend committing .env to your repo with good defaults. .env.development, .env.production etc can be used for local overrides and should not be in the repo. See [Handling Secrets with SOPS](#handling-secrets-with-sops) for how to manage secrets.

1) Install Docker.app

2) Install stack car
    ``` bash
    gem install stack_car
    ```

3) Sign in with dory
    ``` bash
    dory up

4) Start the server
    ``` bash
    sc up
    ```

5) Load and seed the database
    ``` bash
    sc be rake db:migrate db: seed
    ```

6) The app should be visible at in the browser at `hyku.test`

### While in the container you can do the following
- Run rspec
    ``` bash
    bundle exec rspec
    ```
- Access the rails console
    ``` bash
    bundle exec rails c
    ```

### Handling Secrets with SOPS

[**SOPS**](https://github.com/mozilla/sops) is used to handle this project's secrets.

The secrets in this repository include:
- `.env*` files
- `*-values.yaml` files

Scripts (`bin/decrypt-secrets` and `bin/encrypt-secrets`) are included in this project to help with managing secrets.

**To decrypt secrets**:

You will need to do this if you are new to the project or there have been changes to any secrets files that are required for development.

In terminal:
```bash
bin/decrypt-secrets
```

This will find and decrypt files with the `.enc` extension.

**To encrypt secrets**:

You will need to do this when you have edited secrets and are ready to commit them.

In terminal:
```bash
bin/encrypt-secrets
```

This will find and output an encrypted version of secret files with an `.enc` extension.

Release and Deployment are handled by the gitlab ci by default. See ops/deploy-app to deploy from locally, but note all Rancher install pull the currently tagged registry image

## Staging Deploys: N8 Architecture

Staging builds and deploys to Notch8 infrastructure are handled by Gitlab CI.

**Setup your `gitlab` git remote**

You'll only need to do this once. You need to set this remote to push, build and deploy your work.
- Run `git remote add gitlab git@gitlab.com:notch8/ngao.git`
- Run `git remote`. You've successfully added the **gitlab** remote if your output lists it. It will look like:
```
> git remote              # Run git remote
gitlab                    # New gitlab remote
origin
```

- Run `git remote`. You've successfully added the **gitlab** remote if your output lists it. It will look like:
```
> git remote              # Run git remote
gitlab                    # New gitlab remote
origin
```




# ams

Archival Management System to support the American Archive of Public Broadcasting

`master`:  [![Build Status](https://travis-ci.org/WGBH-MLA/ams.svg?branch=master)](https://travis-ci.org/WGBH-MLA/ams)
`develop`: [![Build Status](https://travis-ci.org/WGBH-MLA/ams.svg?branch=develop)](https://travis-ci.org/WGBH-MLA/ams)

The Archival Managment System is an application using the [Hyrax gem](https://github.com/samvera/hyrax) to provide a repository for [PBCore](http://pbcore.org/) data about externally hosted AV content. It includes models, controllers, actors, and presenters for PBCore-based worktypes of Assets, Contributions, Physical Instantiations, Digital Instantiations, and Essence Tracks.  

AMS also adds the ability to export records in several user-friendly CSV reports and PBCore XML files, as well as using [hyrax-batch_ingest gem](https://github.com/samvera-labs/hyrax-batch_ingest) to implement batch ingest of PBCore XML and spreadsheets, and batch metadata updates via spreadsheets.


### Dependencies

* **[Fedora Commons Repository](https://duraspace.org/fedora/)** is the data repository platform. Fedora provides an HTTP endpoint that the AMS application
* **[Solr](https://lucene.apache.org/solr/)** is used for search.
* **[Redis](https://redis.io)** is used for storing information about background jobs.
* **[Sidekiq](https://github.com/mperham/sidekiq)** is used for scheduling and processing background jobs.
* **[Ruby on Rails](https://rubyonrails.org)** is the web framework used for building the application.
* **[Hyrax](https://hyrax.samvera.org)** is the Ruby on Rails plugin that provides many repository features for AMS.
* **[MySQL](https://www.mysql.com)** is the relational database used used by both the web application and by Fedora.
