# frozen_string_literal: true

class CommitRelease < ApplicationRecord
  belongs_to :commit
  belongs_to :release
end
