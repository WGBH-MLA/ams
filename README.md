# ams

Archival Management System to support the American Archive of Public Broadcasting

`master`:  [![Build Status](https://travis-ci.org/WGBH-MLA/ams.svg?branch=master)](https://travis-ci.org/WGBH-MLA/ams)
`develop`: [![Build Status](https://travis-ci.org/WGBH-MLA/ams.svg?branch=develop)](https://travis-ci.org/WGBH-MLA/ams)

The Archival Managment System is an application using the [Hyrax gem](https://github.com/samvera/hyrax) to provide a repository for [PBCore](http://pbcore.org/) data about externally hosted AV content. It includes models, controllers, actors, and presenters for PBCore-based worktypes of Assets, Contributions, Physical Instantiations, Digital Instantiations, and Essence Tracks.  

AMS also adds the ability to export records in several user-friendly CSV reports and PBCore XML files, as well as using [hyrax-batch_ingest gem](https://github.com/samvera-labs/hyrax-batch_ingest) to implement batch ingest of PBCore XML and spreadsheets, and batch metadata updates via spreadsheets. 
