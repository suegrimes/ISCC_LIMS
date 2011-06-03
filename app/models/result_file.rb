class ResultFile < ActiveRecord::Base

    has_and_belongs_to_many :sample

end
