class Feed < ActiveRecord::Base
	validates :desc, presence: true
	validates :title, uniqueness: true
end
