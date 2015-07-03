require "teamsnap/version"
require "teamsnap/error"
require "teamsnap/configuration"
require "teamsnap/client"
require "teamsnap/collection"
require "teamsnap/item"

Oj.default_options = {
  :mode => :compat,
  :symbol_keys => true,
  :class_cache => true
}

module TeamSnap
  EXCLUDED_RELS = %w(me apiv2_root root self dude sweet random xyzzy)

  def self.client(options={})
    TeamSnap::Client.new(options)
  end

  def self.method_missing(method, *args, &block)
    return super unless client.respond_to?(method)
    client.send(method, *args, &block)
  end

  # Delegate to Instagram::Client
  def self.respond_to?(method, include_all=false)
    return client.respond_to?(method, include_all) || super
  end

end
