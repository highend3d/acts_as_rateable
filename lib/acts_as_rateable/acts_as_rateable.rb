module ActiveRecord
  module Acts
    module Rateable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module AssignRateWithUserId
        def <<(rate)
          r = Rating.find_or_initialize_by_user_id_and_rateable_type_and_rateable_id(rate.user_id, proxy_association.owner.class.base_class, proxy_association.owner.id)
          r.rate = rate
          r.rater_name = rate.rater_name
          r.save
        end
      end

      module ClassMethods
        def acts_as_rateable(options = { })
          has_many :ratings, :as => :rateable, :dependent => :destroy, :include => :rate
          has_many :rates, :through => :ratings, :extend => AssignRateWithUserId

          include ActiveRecord::Acts::Rateable::InstanceMethods
          extend ActiveRecord::Acts::Rateable::SingletonMethods
        end
      end

      module SingletonMethods
        # Find all objects rated by score.
        def find_average_of(score)
          find(:all, :include => [:rates])
          .collect { |i| i if i.average_rating.to_i == score }
          .compact
        end
      end

      module InstanceMethods
        ##
        # Rates the object by a given score. A user object can be passed to the method.
        # Additionally a rater name and free text can be passed.
        #
        # The passed in user object must respond to methods 'login' and 'id', otherwise an
        # exception is raised.
        # TODO: refactor the 'id' & 'login' method names to the acts_as_rateable options hash and make it configurable
        def rate_it(score, user)
          return unless score
          rate = Rate.find_or_create_by_score(score.to_i)
          raise "User must respond to 'id' in order to set the user ID!" unless user.respond_to? :id
          raise "User must respond to 'nickname' in order to set rater name!" unless user.respond_to? :nickname
          rate.user_id = user.id
          rate.rater_name = user.nickname
          rates << rate
        end

        # Calculates the average rating. Calculation based on the already given scores.
        def average_rating
          return 0 if rates.empty?
          (rates.inject(0) { |total, rate| total += rate.score }.to_f / rates.size)
        end

        # Rounds the average rating value.
        def average_rating_round
          average_rating.round(0)
        end

        # Returns the average rating in percent. The maximal score must be provided	or the default value (5) will be used.
        # TODO make maximum_rating automatically calculated.
        def average_rating_percent(maximum_rating = 5)
          f = 100 / maximum_rating.to_f
          average_rating * f
        end

        # Checks whether a user rated the object or not.
        def rated_by?(user)
          ratings.detect { |r| r.user_id == user.id }
        end

        # Returns ratings with scores in json format
        def jsoned_ratings
          Rating.format(ratings)
        end
      end

    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Rateable)