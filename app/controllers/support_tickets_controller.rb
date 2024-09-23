class SupportTicketsController < ApplicationController
  def new
    @support_ticket = SupportTicket.new
  end

  def create
    @support_ticket = SupportTicket.new(support_ticket_params)
    @support_ticket.user = current_user if signed_in?
    if @support_ticket.save
      # Send email notification, etc.
      redirect_to root_path, notice: 'Your message has been sent.'
    else
      render :new
    end
  end

  private

  def support_ticket_params
    params.require(:support_ticket).permit(:author_email, :subject, :status, :priority, :content)
  end
end
