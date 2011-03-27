namespace :lonely_accounts do
  desc "List accounts of missing profiles"
  task :list => :environment do
    accounts.each do |account|
      puts account.email
    end
  end

  desc "List and destroy accounts of missing profiles"
  task :destroy => :list do
    accounts.each do |account|
      account.destroy
    end
  end
  
  def accounts
    Account.not_in(:_id => Profile.criteria.collect(&:account_id))
  end
end
