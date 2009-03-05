require 'flex_attributes_filtered'
ActiveRecord::Base.class_eval do
  include Hypomodern::FlexAttributes::Filtered
end
