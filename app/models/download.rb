class Download
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :set_update
  after_update :check_approval
  
  mount_uploader :download, DownloadUploader
  belongs_to :submission

  validates :name, presence: true
  validates :version, presence: true
  validates :download, presence: true

  field :name, type: String
  field :version, type: String
  field :approved, type: Boolean, default: false
  field :denied, type: Boolean, default: false

  def check_approval
    if !approved || submission.approved_at
      return
    end
    if submission.ready?
      submission.approved_at = Time.now
      submission.save
      puts "A SUBMISSION WAS APPROVED"
    end
  end

  def set_update
    if not approved
      return
    end
    self.submission.last_update = Time.now
    self.submission.save
  end
end
