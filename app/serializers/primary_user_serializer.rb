class PrimaryUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :full_name, :display_name,
             :friends, :notify_reslyp, :notify_activity, :weekly_summary,
             :searchable, :cc_me_on_email_reslyp
end
