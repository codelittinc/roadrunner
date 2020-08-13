json.partial! @project, partial: 'projects/project', as: :project

json.servers @project.repositories.map(&:servers).flatten, partial: 'servers/show', as: :server
