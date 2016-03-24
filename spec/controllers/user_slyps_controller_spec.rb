require "rails_helper"

RSpec.describe UserSlypsController, type: :controller do
  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }
    context "without authentication" do
      it "responds with 401" do
        url = "https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/"
        post :create, url: url, format: :json

        expect(response.status).to eq(401)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with invalid parameters", :vcr do
      it "responds wth 422" do
        sign_in user
        url = "http://www.foobarbaziamafaker.co/"
        post :create, url: url, format: :json

        expect(response.status).to eq 422
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with valid parameters", :vcr do
      it "responds with 201 and minimal slyp attrs" do
        sign_in user
        url = "https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/"
        post :create, url: url, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(201)
        expect(response.content_type).to eq(Mime::JSON)

        expect(response_body_json["archived"]).not_to be_nil
        expect(response_body_json["deleted"]).not_to be_nil
        expect(response_body_json["favourite"]).not_to be_nil
        expect(response_body_json["reslyps_count"]).to be >= 1
        expect(response_body_json["reslyps"]).not_to be_nil
      end
    end
  end

  describe "#index" do
    context "user with reslyps" do
      it "responds with 200 and correct number of slyps" do
        sign_in FactoryGirl.create(:user, :with_reslyps)
        get :index, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response_body_json.length).to eq(10)
      end
    end
  end

  describe "#show" do
    context "friend sends user a slyp" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      let(:friend) { FactoryGirl.create(:user, :with_reslyps) }
      let(:friend_user_slyp) { friend.user_slyps.first }
      before do
        sign_in user
        friend_user_slyp.send_slyp(user.email, "This is a comment")
      end
      it "should not return friend's user_slyp" do
        put :show, id: friend_user_slyp.id, format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end
      it "responds with 200 and correct data" do
        user_slyp = user.user_slyps.find_by({:slyp_id => friend_user_slyp.slyp_id})
        put :show, id: user_slyp.id, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response_body_json["friends"].length).to eq 1
        expect(response_body_json["reslyps"].length).to eq 1
        expect(response_body_json["reslyps"][0]["user"]["id"]).to eq friend.id
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "single user with multiple friends" do
      let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
      let(:user_slyp) { user.user_slyps.first }
      let(:friends) { FactoryGirl.create_list(:user, 10) }
      let(:friend_emails) { friends.map(&:email) }

      it "should respond with 200 and correct data" do
        sign_in user
        user_slyp.send_slyps(friend_emails, "This is a comment")
        put :show, id: user_slyp.id, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response.content_type).to eq Mime::JSON
        expect(response_body_json["friends"].length).to eq 10
        response_body_json["friends"].map { |id| expect(id).
          to be_kind_of Integer }
      end
    end
  end

  describe "#update" do
    let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
    let(:user_slyp) { user.user_slyps.first }
    before do
      sign_in user
    end
    ## Need to figure out how to not permit nil values in controller
    ## See user_slyp_controller.rb#34
    # context "with invalid parameters" do
    #   it "responds with 422" do
    #     put :update, id: user_slyp.to_param, user_slyp: { favourite: nil }, format: :json

    #     expect(response.status).to eq(422)
    #     expect(response.content_type).to eq(Mime::JSON)
    #   end
    # end

    context "with valid parameters" do
      it "toggles favourite and responds with 200" do
        put :update, id: user_slyp.to_param, user_slyp: { favourite: !user_slyp.favourite }, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response.content_type).to eq(Mime::JSON)
        expect(response_body_json["favourite"]).to eq !user_slyp.favourite
      end

      it "toggles archived and responds with 200" do
        put :update, id: user_slyp.to_param, user_slyp: { archived: !user_slyp.archived }, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response.content_type).to eq(Mime::JSON)
        expect(response_body_json["archived"]).to eq !user_slyp.archived
      end

      it "toggles deleted and responds with 200" do
        put :update, id: user_slyp.to_param, user_slyp: { deleted: !user_slyp.deleted }, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response.content_type).to eq(Mime::JSON)
        expect(response_body_json["deleted"]).to eq !user_slyp.deleted
      end
    end
  end
end