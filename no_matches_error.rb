# frozen_string_literal: true

class NoMatchesError < StandardError
  def initialize(error_message = "No horoscope matches found.")
    super
  end
end
