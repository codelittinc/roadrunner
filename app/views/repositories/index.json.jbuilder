# frozen_string_literal: true

json.array! @repositories, partial: 'repository', as: :repository
