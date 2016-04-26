class UserSlypSerializer < ActiveModel::Serializer
  attributes :id, :display_url, :title, :site_name, :author, :slyp_id, :url,
  :archived, :favourite, :deleted, :duration, :friends, :slyp_type, :html, :reslyps

  has_many :reslyps, serializer: ReslypSerializer
end
