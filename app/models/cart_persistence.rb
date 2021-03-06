# frozen_string_literal: true

require_relative "cart"

class CartPersistence
  attr_accessor :serialized_cart, :id

  def self.find(id)
    serialized_cart = $redis.get redis_key(id)
    return unless serialized_cart

    new(id: id, serialized_cart: serialized_cart)
  end

  def self.redis_key(id)
    "webstore:CartPersistence:#{id}"
  end

  def initialize(args = {})
    args.each { |k, v| send("#{k}=", v) }
  end

  def cart
    Marshal.load serialized_cart # rubocop:disable Security/MarshalLoad
  end

  def save(cart)
    self.serialized_cart = Marshal.dump cart
    self.id = SecureRandom.uuid unless id

    ttl = 1.week.to_i
    $redis.setex redis_key, ttl, serialized_cart
  end

  def redis_key
    self.class.redis_key id
  end
end
