namespace :chain_blocks do
  desc "Sync transactions for a given chain slug"
  task :sync_chain, [ :chain_slug ] => :environment do |t, args|
    chain_slug = args[:chain_slug] || 'near'
    SyncChainJob.perform_later(chain_slug)
    puts "Scheduled sync for #{chain_slug}"
  end
end
