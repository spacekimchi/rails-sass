module Admin
  class ApplicationErrorsController < ApplicationController
    def index
      @application_errors = ApplicationError.all
    end
  end
end
