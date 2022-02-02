def uri
  "postgres://AmazonPgUsername:AmazonPgPassword@#{ENV['POSTGRES_HOST']}/postgres"
end

def use_postgres?
  !ENV['POSTGRES_HOST'].nil?
end

def container_type
  use_postgres? ? uri : 'sqlite::memory'
end
