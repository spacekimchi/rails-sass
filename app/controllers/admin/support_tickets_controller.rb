module Admin
  class SupportTicketsController < ApplicationController
    def index
      @support_tickets = SupportTicket.all
    end

    def assign_to_user
      @support_ticket = SupportTicket.find(params[:id])
      @user = User.find_by(id: params[:user_id])

      if @support_ticket.assign_to_user(@user)
        flash.now[:success] = @user.present? ? "Ticket successfully assigned to User." : "Ticket was successfully unassigned."
      else
        flash.now[:error] = "Failed to assign ticket."
      end

      respond_to do |format|
        format.turbo_stream
      end
    end
  end
end
