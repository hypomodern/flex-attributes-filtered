require File.dirname(__FILE__) + '/spec_helper'

describe "FlexAttributes::Filtered" do
  before(:each) do
    class Qberts; end
    
    Qberts.send(:include, Hypomodern::FlexAttributes::Filtered)
  end
  
  describe "successful inclusion" do
    it "should give any class it is included in the helpful macro 'flex_filtered'" do
      Qberts.should respond_to(:flex_filtered)
    end
  end
  
  describe "flex_filtered" do
    before(:each) do
      Qberts.class_eval do
        flex_filtered({
          :happy_baba => true,
          :allowed_attributes => [ :potions, :fury, :weave ]
        })
      end
      
      @zagreb = Qberts.new
    end
    it "should accept a hash of options, with some default values" do
      @zagreb.flex_filtered_options.should be_a_kind_of(Hash)
    end
    it "should make these options available to the base class" do
      @zagreb.flex_filtered_options[:attribute_name_delegate].should be_nil
      @zagreb.flex_filtered_options[:allowed_attributes].should == [ :potions, :fury, :weave ]
    end
    it "should then include the InstanceMethods and ClassMethods into the base class" do
      @zagreb.should respond_to(:extended_attributes)
    end
  end
  
  describe "extended_attribute_names" do
    before(:each) do
      Qberts.class_eval do
        cattr_accessor :flex_options
      end
      Qberts.flex_options = {
        :fields => [ :potions, :fury, :weave ]
      }
      @belgrade = Qberts.new
    end
    
    it "should delegate the name finding if flex_filtered_options[:attribute_name_delegate] is set" do
      class Sofia
        include Hypomodern::FlexAttributes::Filtered
        flex_filtered :attribute_name_delegate => :kismet
        
        def kismet
          [ :bejeweled, :spades ]
        end
      end
      
      Sofia.new.extended_attribute_names.should == [ :bejeweled, :spades ]
    end
    it "should be able to handle delegating to a proxy method" do
      class Sofia
        include Hypomodern::FlexAttributes::Filtered
        flex_filtered :attribute_name_delegate => :kismet
        
        def kismet
          [ :bejeweled, :spades ]
        end
      end
      class Ritterburg
        attr_accessor :capital_of_bulgaria
        def initialize
          @capital_of_bulgaria = Sofia.new
        end
        include Hypomodern::FlexAttributes::Filtered
        flex_filtered :attribute_name_delegate => :capital_of_bulgaria,
                      :attribute_name_delegate_method => :kismet
      end
      
      Ritterburg.new.extended_attribute_names.should == [ :bejeweled, :spades ]
    end
    it "should use the allowed_attributes option otherwise" do
      @belgrade.extended_attribute_names.should == [ :potions, :fury, :weave ]
    end
    it "should fall back to allowing nothing" do
      class Sevastopol
        include Hypomodern::FlexAttributes::Filtered
        flex_filtered
      end
      
      Sevastopol.new.extended_attribute_names.should == []
    end
  end
  
  describe "extended_attributes" do
    before(:each) do
      Qberts.class_eval do
        cattr_accessor :flex_options
      end
      
      module FauxInstanceMethods
        def potions
          "fire, water"
        end
        def fury
          6
        end
        def weave
          "potent"
        end
      end
      Qberts.send(:include, FauxInstanceMethods) # This is meant to simulate flex_attributes
      Qberts.flex_options = {
        :fields => [ :potions, :fury, :weave ]
      }
      @belgrade = Qberts.new
    end
    it "should produce a hash of key-values derived from the extended_attribute_names" do
      @belgrade.extended_attributes.should be_a_kind_of(Hash)
      @belgrade.extended_attributes.should == {
        "potions"=>"fire, water",
        "weave"=>"potent",
        "fury"=>6
      }
    end
    it "should produce an empty hash if there are no extended attrs" do
      class Sevastopol
        include Hypomodern::FlexAttributes::Helpers
        flex_filtered
      end
      
      Sevastopol.new.extended_attributes.should == {}
    end
  end
end
