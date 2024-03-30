# frozen_string_literal: true

class CodeCommentsCreator
  def initialize(pull_request, source_control_pull_request_client)
    @pull_request = pull_request
    @source_control_pull_request_client = source_control_pull_request_client
  end

  def create
    comments = @source_control_pull_request_client&.new&.comments(@pull_request.repository, @pull_request.source_control_id)
    raise "Backstage user cannot be nil. Author name is #{comment.author} and pull request id is #{@pull_request.id}" if comment.author.nil?

    comments&.each do |comment|
      CodeComment.find_or_create_by!(
        pull_request: @pull_request,
        comment: comment.comment,
        author_id: comment.author,
        published_at: DateTime.parse(comment.published_at).to_date
      )
    end
  end
end
