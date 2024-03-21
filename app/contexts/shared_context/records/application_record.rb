# frozen_string_literal: true

module SharedContext
  module Records
    class ApplicationRecord < ActiveRecord::Base
      primary_abstract_class
    end
  end
end
