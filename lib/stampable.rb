module Ddb #:nodoc:
  module Userstamp
    # Determines what default columns to use for recording the current stamper.
    # By default this is set to false, so the plug-in will use columns named
    # <tt>creator_id</tt>, <tt>updater_id</tt>, and <tt>deleter_id</tt>.
    #
    # To turn compatibility mode on, place the following line in your environment.rb
    # file:
    #
    #   Ddb::Userstamp.compatibility_mode = true
    #
    # This will cause the plug-in to use columns named <tt>created_by</tt>,
    # <tt>updated_by</tt>, and <tt>deleted_by</tt>.
    mattr_accessor :compatibility_mode
    @@compatibility_mode = false

    # Extends the stamping functionality of ActiveRecord by automatically recording the model
    # responsible for creating, updating, and deleting the current object. See the Stamper
    # and Userstamp modules for further documentation on how the entire process works.
    module Stampable
      def self.included(base) #:nodoc:
        super

        base.extend(ClassMethods)
        base.class_eval do
          include InstanceMethods

          # Should ActiveRecord record userstamps? Defaults to true.
          class_attribute  :record_userstamp
          self.record_userstamp = true

          # Which class is responsible for stamping? Defaults to :user.
          class_attribute  :stamper_class_name

          # What column should be used for the creator stamp?
          # Defaults to :creator_id when compatibility mode is off
          # Defaults to :created_by when compatibility mode is on
          class_attribute  :creator_attribute

          # What column should be used for the updater stamp?
          # Defaults to :updater_id when compatibility mode is off
          # Defaults to :updated_by when compatibility mode is on
          class_attribute  :updater_attribute

          # What column should be used for the deleter stamp?
          # Defaults to :deleter_id when compatibility mode is off
          # Defaults to :deleted_by when compatibility mode is on
          class_attribute  :deleter_attribute
        end
      end

      module ClassMethods
        # This method is automatically called on for all classes that inherit from
        # ActiveRecord, but if you need to customize how the plug-in functions, this is the
        # method to use. Here's an example:
        #
        #   class Post < ActiveRecord::Base
        #     stampable :stamper_class_name => :person,
        #               :creator_attribute  => :create_user,
        #               :updater_attribute  => :update_user,
        #               :deleter_attribute  => :delete_user,
        #               :deleter            => true,
        #               :with_deleted       => true
        #   end
        #
        # The method will automatically setup all the associations,
        # and create <tt>before_validation</tt> & <tt>before_destroy</tt> callbacks for doing the stamping.
        #
        # By default, the deleter association and before filter are not defined unless
        # you set the :deleter_attribute or set the :deleter option to true.
        #
        # When using the new acts_as_paranoid gem (https://github.com/goncalossilva/rails3_acts_as_paranoid)
        # the :with_deleted option can be used to setup the associations to return objects that have been soft deleted.
        #
        def stampable(options = {})
          compatability = Ddb::Userstamp.compatibility_mode
          defaults  = {
            :stamper_class_name => :user,
            :creator_attribute  => (compatability ? :created_by : :creator_id),
            :updater_attribute  => (compatability ? :updated_by : :updater_id),
            :deleter_attribute  => (compatability ? :deleted_by : :deleter_id),
            :deleter            => options.has_key?(:deleter_attribute),
            :with_deleted       => false
          }.merge(options)

          self.stamper_class_name = defaults[:stamper_class_name].to_sym
          self.creator_attribute  = defaults[:creator_attribute].to_sym
          self.updater_attribute  = defaults[:updater_attribute].to_sym
          self.deleter_attribute  = defaults[:deleter_attribute].to_sym

          class_eval do
            klass = "::#{stamper_class_name.to_s.singularize.camelize}"

            if defaults[:with_deleted]
              belongs_to :creator, :class_name => klass, :foreign_key => creator_attribute, :with_deleted => true
              belongs_to :updater, :class_name => klass, :foreign_key => updater_attribute, :with_deleted => true
            else
              belongs_to :creator, :class_name => klass, :foreign_key => creator_attribute
              belongs_to :updater, :class_name => klass, :foreign_key => updater_attribute
            end

            before_validation :set_updater_attribute
            before_validation :set_creator_attribute, :on => :create
            before_save :set_updater_attribute
            before_save :set_creator_attribute, :on => :create

            if defaults[:deleter]
              if defaults[:with_deleted]
                belongs_to :deleter, :class_name => klass, :foreign_key => deleter_attribute, :with_deleted => true
              else
                belongs_to :deleter, :class_name => klass, :foreign_key => deleter_attribute
              end

              before_destroy :set_deleter_attribute

            end
          end
        end

        # Temporarily allows you to turn stamping off. For example:
        #
        #   Post.without_stamps do
        #     post = Post.find(params[:id])
        #     post.update_attributes(params[:post])
        #     post.save
        #   end
        def without_stamps
          original_value = self.record_userstamp
          self.record_userstamp = false
          yield
        ensure
          self.record_userstamp = original_value
        end

        def stamper_class #:nodoc:
          stamper_class_name.to_s.camelize.constantize rescue nil
        end
      end

      module InstanceMethods #:nodoc:
        private
          def has_stamper?
            !self.class.stamper_class.nil? && !self.class.stamper_class.stamper.nil? rescue false
          end

          def set_creator_attribute
            return unless self.record_userstamp
            if respond_to?(self.creator_attribute.to_sym) && has_stamper?
              if self.send(self.creator_attribute.to_sym).blank?
                self.send("#{self.creator_attribute}=".to_sym, self.class.stamper_class.stamper)
              end
            end
          end

          def set_updater_attribute
            return unless self.record_userstamp
            # only set updater if the record is new or has changed
            return unless self.new_record? || self.changed?
            if respond_to?(self.updater_attribute.to_sym) && has_stamper?
              self.send("#{self.updater_attribute}=".to_sym, self.class.stamper_class.stamper)
            end
          end

          def set_deleter_attribute
            return unless self.record_userstamp
            if respond_to?(self.deleter_attribute.to_sym) && has_stamper?
              self.send("#{self.deleter_attribute}=".to_sym, self.class.stamper_class.stamper)
              save
            end
          end
        #end private
      end
    end
  end
end

ActiveRecord::Base.send(:include, Ddb::Userstamp::Stampable) if defined?(ActiveRecord)
