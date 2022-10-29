# frozen_string_literal: true

require 'net/http'

module Tasks
  class SprintsBase
    DEFAULT_NO_DEVOPS_CODE = 'Not assigned'

    def customer_name
      'Codelitt'
    end

    def update!
      customer.sprints.where(source:).destroy_all

      update_info!
    end

    def update_info!
      raise 'override this method'
    end

    def source
      raise 'override this method'
    end

    def customer
      return @customer if @customer

      @customer ||= Customer.find_or_initialize_by(name: customer_name)
      @customer.save!
      @customer
    end

    def initialize_user(_assigned_to)
      raise 'override this method'
    end

    def sprints_per_team
      raise 'override this method'
    end

    def find_user(assigned_to, name)
      new_user = initialize_user(name, assigned_to)
      user = User.find_existing_user(new_user)
      user ||= new_user

      user.save!
      user
    end

    def create_sprint!(_sprint_data, _team)
      raise 'override this method'
    end

    def create_issue!(_data, _sprint, _user)
      raise 'override this method'
    end
  end
end
