class Api::V1::InboxMembersController < Api::BaseController

  before_action :fetch_inbox, only: [:create, :show]
  before_action :current_agents_ids, only: [:create]

  def create #update also done via same action
    #get all the user_ids which the inbox currently has as members.
    #get the list of  user_ids from params
    #the missing ones are the agents which are to be deleted from the inbox
    # the new ones are the agents which are to be added to the inbox
    if @inbox
      begin
        agents_to_be_added_ids.each do |user_id|
          @inbox.add_member(user_id)
        end
        agents_to_be_removed_ids.each do |user_id|
          @inbox.remove_member(user)
        end
        head :ok
      rescue => e
        render_could_not_create_error("Could not add agents to inbox")
      end
    else
      render_not_found_error("Agents or inbox not found")
    end
  end

  def show
    @agents = current_account.users.where(id: @inbox.members.pluck(:user_id))
  end

  private

  def agents_to_be_added_ids
    params[:user_ids] - @current_agents_ids
  end

  def agents_to_be_removed_ids
    @current_agents_ids - params[:user_ids]
  end

  def current_agents_ids
    @current_agents_ids = @inbox.members.pluck(:user_id)
  end

  def fetch_inbox
    @inbox = current_account.inboxes.find(params[:inbox_id])
  end
end
