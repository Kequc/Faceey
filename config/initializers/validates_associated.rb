# Creates error messages of a has_many or has_one child model when validating an instance of a parent model and adds them to
# the parent.
# Example
#
# class Garage < ActiveRecord::Base
#   has_many :cars
#   validates_associated_attributes :cars
# end
#
# class Car < ActiveRecord::Base
#   validates_presence_of :license_plate, :message => 'must be registered'
# end
#
# garage.valid? ==> "License plate must be registered"
# (The standard message would be "Car is invalid" and thus much less instructive"
#
# (c) 2009, Wolfram Arnold, wolfram@wtaconsulting.net, www.wtaconsulting.net

module ValidatesAssociatedAttributes
  module ActiveModel::Validations::ClassMethods
    def validates_associated_attributes(*associations)
      class_eval do
        validates_each(associations) do |record, associate_name, value|
          record.errors.delete_if { |err| err[0] == associate_name.to_sym }
          associates = value.respond_to?(:each) ? value : [value]  # this lets you use it with both has_one and has_many
          associates.each do |associate|
            if associate && !associate.valid?
              associate.errors.each do |key, value|
                record.errors.add(key, value)
              end
            end
          end
        end
      end
    end
  end
end
