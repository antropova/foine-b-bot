# frozen_string_literal: true

class NoPathFoundError < StandardError
  def initialize(error_message = 'No horoscope path found.')
    super
  end
end
