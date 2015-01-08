class Comment
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Timestamps

  field :text, type: String
  field :deleted_at, type: String
  belongs_to :submission
  belongs_to :user

  validates :text, presence: true
end
