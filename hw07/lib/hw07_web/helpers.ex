# Code Derived From: https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/13-access-rules/notes.md
alias Hw07.Events
alias Hw07.Invites
alias Hw07.Comments
defmodule Hw07Web.Helpers do
    def have_user?(conn) do
        conn.assigns[:user] != nil
    end 

    def have_current_user?(conn) do
        conn.assigns[:user] != nil
    end

    def current_user_id(conn) do
        user = conn.assigns[:user]
        user && user.id
    end

    def have_event?(conn) do
        conn.assigns[:event] != nil
    end 

    def count_response(invites) do
        result =
        Enum.reduce(invites, %{"yes" => 0, "no" => 0, "maybe" => 0, "unresponded" => 0},  
        fn inv, acc -> 
            case inv.response do
                "yes" -> Map.put(acc, "yes", acc["yes"] + 1)
                "no" ->  Map.put(acc, "no", acc["no"] + 1) 
                "maybe" -> Map.put(acc, "maybe", acc["maybe"] + 1)
                "unresponded" -> Map.put(acc, "unresponded", acc["unresponded"] + 1)
            end
        end)
    end 

    # Owner of the event?
    def is_owner?(conn, event_id) do
        user_id = conn.assigns[:user].id
        event = Events.get_event!(event_id)
        user_id == event.user_id
    end

    # Invitee of the event?
    def is_invitee?(conn, event_id) do
        user_id = conn.assigns[:user].id
        event_id
        |> Events.get_event!()
        |> Events.load_invite()
        |> Map.get(:invites)
        |> Enum.any?(fn x -> x.user_id == user_id end)
    end
    
    def own_invite?(conn, invite_id) do
        invite = Invites.get_invite!(invite_id)
        conn.assigns[:user].id == invite.user_id
    end 

    def belong_to_event?(conn, event_id) do
        is_owner?(conn, event_id) || is_invitee?(conn, event_id)
    end 
    
    # Commenter or Event Owner of the event? 
    def is_commenter?(conn, comm_id) do
        user_id = conn.assigns[:user].id
        comm = Comments.get_comment!(comm_id) 
        comm.user_id == user_id || is_owner?(conn, comm.event_id)
    end  
end 