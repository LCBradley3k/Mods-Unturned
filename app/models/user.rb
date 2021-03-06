class User
  include Mongoid::Document
  include GlobalID::Identification
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:steam]

  validates :username, presence: true, uniqueness: true, :length => { :maximum => 16 } # Max username length is 16
  validates :email, presence: true, uniqueness: true

  attr_accessor :login

  field :email, type: String, default: ""
  field :encrypted_password, type: String, default: ""
  field :username, type: String, default: ""

  field :admin, type: Boolean, default: false

  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  field :remember_created_at, type: Time

  # Track user history
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  field :ip_history, type: Array, default: []

  field :banned, type: Boolean, default: false

  field :can_blog, type: Boolean, default: false

  # Whether or not we can send this user emails
  field :accepts_emails, type: Boolean, default: true

  # Omniauth
  field :provider, type: String
  field :uid, type: String

  has_many :submissions, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :downloads, class_name: 'Download', inverse_of: :user
  has_many :owned_downloads, inverse_of: :creator, class_name: 'Download'
  has_many :submitted_videos, :inverse_of => :submitter, class_name: 'Video'
  has_many :created_reports, :inverse_of => :creator, class_name: 'Report', foreign_key: 'reporter_id'
  has_many :resolved_reports, :inverse_of => :resolver, class_name: 'Report', foreign_key: 'resolver_id' 
  has_many :blog_posts, :inverse_of => :author, class_name: 'Blog::Post'

  # Track user IP history
  Warden::Manager.after_set_user do |record, warden, opts|
    if !record.ip_history.include?(record.current_sign_in_ip)
      record.ip_history << record.current_sign_in_ip
      record.save
    end
  end

  # Auto remember-me
  def remember_me
    true
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      self.any_of({ :username =>  /^#{Regexp.escape(login)}$/i }, { :email =>  /^#{Regexp.escape(login)}$/i }).first
    else
      super
    end
  end

  def self.from_steam(auth)
    new_user = where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = "#{auth.uid}@steam-provider.com"
      user.username = "SteamUser#{auth.uid}"
      user.password = Devise.friendly_token[0, 20]
    end
    new_user.save(:validate => false)
    return new_user
  end
end
