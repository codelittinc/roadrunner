# frozen_string_literal: true

json.array! @repositories do |repository|
  json.id repository.id
  json.name repository.name
  json.owner repository.owner
end
