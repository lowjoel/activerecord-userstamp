require 'rails_helper'

RSpec.describe 'Stamping', type: :model do
  before(:each) do
    define_first_post
    User.stamper = @zeus
    Person.stamper = @delynn
  end

  context 'when creating a Person' do
    context 'when the stamper is an object' do
      it 'sets using the the association' do
        User.stamper = @zeus
        expect(User.stamper).to eq(@zeus)

        person = Person.new
        expect(person).to receive(:creator=)
        person.valid?
      end

      it 'sets the correct creator and updater' do
        expect(User.stamper).to eq(@zeus)

        person = Person.create(name: 'David')
        expect(person.creator_id).to eq(@zeus.id)
        expect(person.updater_id).to eq(@zeus.id)
        expect(person.creator).to eq(@zeus)
        expect(person.updater).to eq(@zeus)
      end

      context 'when a creator is specified' do
        it 'does not reset the creator' do
          expect(User.stamper).to eq(@zeus)

          person = Person.create(name: 'David', creator: @hera)
          expect(person.creator_id).to eq(@hera.id)
          expect(person.updater_id).to eq(@zeus.id)
          expect(person.creator).to eq(@hera)
          expect(person.updater).to eq(@zeus)
        end

        it 'does not reset the creator' do
          expect(User.stamper).to eq(@zeus)

          person = Person.create(name: 'David', creator_id: @hera.id)
          expect(person.creator_id).to eq(@hera.id)
          expect(person.updater_id).to eq(@zeus.id)
          expect(person.creator).to eq(@hera)
          expect(person.updater).to eq(@zeus)
        end

        it 'does not reset the creator when not defined previously' do
          expect(User.stamper).to eq(@zeus)
          person = nil
          Person.without_stamps do
            person = Person.create(name: 'David', updater_id: @hera.id)
            expect(person.creator_id).to be_nil
            expect(person.updater_id).to eq(@hera.id)
          end

          person.name = 'Julian'
          person.save!
          expect(person.creator_id).to be_nil
        end

      end

      context 'when saving without validations' do
        it 'sets the correct creator and updater' do
          expect(User.stamper).to eq(@zeus)

          person = Person.new(name: 'David')
          person.save(validate: false)
          expect(person.creator_id).to eq(@zeus.id)
          expect(person.updater_id).to eq(@zeus.id)
          expect(person.creator).to eq(@zeus)
          expect(person.updater).to eq(@zeus)
        end
      end

      context 'when temporarily disabling stampng' do
        it 'does not set the creator and updater' do
          expect(User.stamper).to eq(@zeus)

          Person.without_stamps do
            person = Person.create(name: 'David')
            expect(person.creator_id).to be_nil
            expect(person.updater_id).to be_nil
            expect(person.creator).to be_nil
            expect(person.updater).to be_nil
          end
        end
      end
    end

    context 'when the stamper is an ID' do
      it 'sets using the the association ID' do
        User.stamper = @zeus.id
        expect(User.stamper).to eq(@zeus.id)

        person = Person.new
        expect(person).to receive(:creator_id=)
        person.valid?
      end

      it 'sets the correct creator and updater' do
        User.stamper = @hera.id
        expect(User.stamper).to eq(@hera.id)

        person = Person.create(name: 'Daniel')
        expect(person.creator_id).to eq(@hera.id)
        expect(person.updater_id).to eq(@hera.id)
        expect(person.creator).to eq(@hera)
        expect(person.updater).to eq(@hera)
      end
    end
  end

  context 'when creating a Post' do
    context 'when the stamper is an object' do
      it 'sets the correct creator and updater' do
        expect(Person.stamper).to eq(@delynn)

        post = Post.create(title: 'Test Post - 1')
        expect(post.creator_id).to eq(@delynn.id)
        expect(post.updater_id).to eq(@delynn.id)
        expect(post.creator).to eq(@delynn)
        expect(post.updater).to eq(@delynn)
      end
    end

    context 'when the stamper is an ID' do
      it 'sets the correct creator and updater' do
        Person.stamper = @nicole.id
        expect(Person.stamper).to eq(@nicole.id)

        post = Post.create(title: 'Test Post - 2')
        expect(post.creator_id).to eq(@nicole.id)
        expect(post.updater_id).to eq(@nicole.id)
        expect(post.creator).to eq(@nicole)
        expect(post.updater).to eq(@nicole)
      end
    end
  end

  context 'when updating a Person' do
    context 'when the stamper is an object' do
      it 'sets the correct updater' do
        User.stamper = @hera
        expect(User.stamper).to eq(@hera)

        @delynn.name = @delynn.name + " Berry"
        @delynn.save
        @delynn.reload
        expect(@delynn.creator).to eq(@zeus)
        expect(@delynn.updater).to eq(@hera)
        expect(@delynn.creator_id).to eq(@zeus.id)
        expect(@delynn.updater_id).to eq(@hera.id)
      end
    end

    context 'when the stamper is an ID' do
      it 'sets the correct updater' do
        User.stamper = @hera.id
        expect(User.stamper).to eq(@hera.id)

        @delynn.name = @delynn.name + " Berry"
        @delynn.save
        @delynn.reload
        expect(@delynn.creator_id).to eq(@zeus.id)
        expect(@delynn.updater_id).to eq(@hera.id)
        expect(@delynn.creator).to eq(@zeus)
        expect(@delynn.updater).to eq(@hera)
      end
    end

    context 'when temporarily disabling stamping' do
      it 'does not set the updater' do
        User.stamper = @zeus
        expect(User.stamper).to eq(@zeus)

        original_updater = @delynn.updater
        Person.without_stamps do
          @delynn.name << " Berry"
          @delynn.save
          @delynn.reload
          expect(@delynn.creator).to eq(@zeus)
          expect(@delynn.updater).to eq(original_updater)
          expect(@delynn.creator_id).to eq(@zeus.id)
          expect(@delynn.updater_id).to eq(original_updater.id)
        end
      end
    end
  end

  context 'when updating a Post' do
    context 'when the stamper is an ID' do
      it 'sets the correct updater' do
        Person.stamper = @nicole.id
        expect(Person.stamper).to eq(@nicole.id)

        @first_post.title = @first_post.title + " - Updated"
        @first_post.save
        @first_post.reload
        expect(@first_post.creator_id).to eq(@delynn.id)
        expect(@first_post.updater_id).to eq(@nicole.id)
        expect(@first_post.creator).to eq(@delynn)
        expect(@first_post.updater).to eq(@nicole)
      end
    end

    context 'when the stamper is an object' do
      it 'sets the correct updater' do
        Person.stamper = @nicole
        expect(Person.stamper).to eq(@nicole)

        @first_post.title = @first_post.title + " - Updated"
        @first_post.save
        @first_post.reload
        expect(@first_post.creator_id).to eq(@delynn.id)
        expect(@first_post.updater_id).to eq(@nicole.id)
        expect(@first_post.creator).to eq(@delynn)
        expect(@first_post.updater).to eq(@nicole)
      end
    end
  end

  context 'when destroying a Post' do
    context 'when the stamper is an ID' do
      it 'sets the deleter' do
        expect(@first_post.deleted_at).to be_nil

        Person.stamper = @nicole.id
        expect(Person.stamper).to eq(@nicole.id)

        @first_post.destroy
        @first_post.save
        @first_post.reload

        expect(@first_post.deleted_at).to be_present
        expect(@first_post.deleter_id).to eq(@nicole.id)
      end
    end
  end

  context 'when using a generated model' do
    it 'does not query the model on the columns' do
      class self.class::Post2 < Post
      end
      allow(self.class::Post2).to receive(:column_names).and_raise(StandardError)

      class self.class::Post2
        has_and_belongs_to_many :tags
      end
    end
  end

  context 'when using an anonymous model' do
    it 'does not query the model on the columns' do
      post_3_class = Class.new(ActiveRecord::Base) do
        def self.table_name
          'Post'
        end
      end
      expect(post_3_class.table_name).not_to be_empty
    end
  end

  context 'when a deleter attribute is specified' do
    it 'creates a deleter relation' do
      expect(@first_post.respond_to?('creator')).to eq(true)
      expect(@first_post.respond_to?('updater')).to eq(true)
      expect(@first_post.respond_to?('deleter')).to eq(true)
    end
  end
end
