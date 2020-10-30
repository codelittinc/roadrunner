# frozen_string_literal: true

json.partial! @project, partial: 'projects/project', as: :project

@expand.each do |relationship|
  collection = @project.public_send(relationship) if @project.respond_to?(relationship)
  json.set! relationship do
    json.partial! "#{relationship.pluralize}/#{relationship.singularize}", collection: collection, as: relationship.singularize.to_sym
  end
end
