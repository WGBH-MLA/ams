%w(
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
  app/services
  app/jobs
).each { |path| Spring.watch(path) }
