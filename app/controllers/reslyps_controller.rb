class ReslypsController < BaseController
  before_action :authenticate_user!

  def create
    if [:emails, :slyp_id, :comment].all? {|s| params.key? s}
      user_slyp = current_user.user_slyps.
        find_or_create_by({:slyp_id => params.delete(:slyp_id)})
      reslyps = user_slyp.send_slyps(params[:emails], params[:comment])
      reslyps.each do |reslyp|
        return render_422(reslyp) if !reslyp.valid?
      end

      render status: 201, json: present_collection(reslyps),
        each_serializer: ReslypSerializer
    else
      return render_400
    end
  end

  def index
    return render_400 if !params.key? :id
    user_slyp = current_user.user_slyps.find(params[:id])
    @reslyps = user_slyp.reslyps
    render status: 200, json: present_collection(@reslyps.includes(:replies, :sender, :recipient)),
      each_serializer: ReslypSerializer
  end

  def show
    @reslyp = Reslyp.authorized_find(current_user, params[:id])
    render status: 200, json: present(@reslyp), serializer: ReslypSerializer
  end

  private

  def present(reslyp)
    ReslypPresenter.new reslyp
  end

  def present_collection(reslyps)
    reslyps.map { |reslyp| present(reslyp) }
  end
end
