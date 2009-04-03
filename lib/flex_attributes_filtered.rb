module Hypomodern
  module FlexAttributes
    module Filtered
      def self.included(base)
        base.extend( SingletonMethods )
      end
      
      module SingletonMethods
        ##
        # flex_filtered allows you to easily programmatically control what attributes are allowed on your models
        # It also provides several convienent helpers designed to make your life with a deterministic list of
        # attributes more easy, such as "extended_attributes", "extended_attribute_names", and "write_extended_attributes"
        # all of which contribute much sanity to making forms for these models.
        #
        # flex_filtered accepts the following options
        # attribute_name_delegate::
        #   if this is a method name, it will be called to determine a list of attribute_names
        #   if this is an object or a relationship, please also specify
        # attribute_name_delegate_method::
        #   this will be called on the attribute_name_delegate. It should return a list of attributes
        def flex_filtered(options = {})
          options = {
            :attribute_name_delegate => nil,
            :attribute_name_delegate_method => nil
          }.merge(options)

          write_inheritable_attribute :flex_filtered_options, options
          class_inheritable_reader :flex_filtered_options
          
          include InstanceMethods
          #extend ClassMethods # no class_methods yet :)
        end
        
      end
      
      module InstanceMethods
        ##
        # extended_attribute_names
        # returns an array of permissable attribute names for this model.
        # uses the delegate options if specified, otherwise tries flex_options[:fields]
        def extended_attribute_names
          return @attribute_names if @attribute_names
          @attribute_names ||= []
          if flex_filtered_options[:attribute_name_delegate]
            delegate = flex_filtered_options[:attribute_name_delegate]
            method = flex_filtered_options[:attribute_name_delegate_method]
            @attribute_names = (method) ?
              (delegate = self.send(delegate)
              delegate.send(method) rescue []) :
              self.send(delegate)
          else
            @attribute_names = flex_options[:fields] rescue []
          end
          @attribute_names
        end
        
        
        ##
        # extended_attributes
        # Since the flex_attributes don't show up in the model's attributes hash, this is an easy substitute.
        # returns a hash of attr_name => value pairs for this model. Capital!
        def extended_attributes(reload = false)
          return @extended_attributes if @extended_attributes && !reload
          @extended_attributes ||= {}
          values = extended_attribute_names.map { |attr| self.send(attr) }
          extended_attribute_names.zip(values).each do |attr|
            # k = attr[0], v = attr[1]
            @extended_attributes[attr[0].to_s] = attr[1]
          end
          @extended_attributes
        end
        
        #filter flex attrs
        # uses the extended_attribute_names method to determine if the given attr is permissable.
        def is_flex_attribute?(attr)
          extended_attribute_names.include? attr.to_s
        rescue
          false
        end
      end # /InstanceMethods
      
      module ClassMethods
        # ::nodoc::
        # fooled you, there are no class methods (yet)
      end # /ClassMethods
    end # /Plus
  end # /FlexAttributes
end
