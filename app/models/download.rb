class Download
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ip, type: String

  belongs_to :upload
  belongs_to :user # Possibly null if user is not logged in.
  belongs_to :submission

  validates :ip, presence: true
  validates :upload_id, presence: true

  scope :daily, -> { where(:created_at.gte => Date.today - 24.hours) }
  scope :weekly, -> { where(:created_at.gte => Date.today - 1.week) }

  index({ created_at: 1 }, { unique: false, name: "download_timestamp", background: true })
end
