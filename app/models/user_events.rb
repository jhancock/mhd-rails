class UserEvents
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps::Created

  store_in collection: "user_events"
  
  field :user_id, type: BSON::ObjectId
  field :event, type: String

  index({user_id: 1}, {unique: false})
  index({event: 1}, {unique: false})
  index({ user_id: 1, event: 1 }, { unique: false })
  # should be unique.  setting to not unique to catch odd errors
  index({ user_id: 1, event: 1, created_at: -1 }, { unique: false })
  index({referrer: 1}, {unique: false})

  def self.log(user_id, event, hash = {})
    # hash are the event attributes
    # example: UserEvents.log user.id, :email, {method: "welcome"}
    self.create({:user_id => user_id, :event => event.to_s}.merge(hash))
  end
    
end
