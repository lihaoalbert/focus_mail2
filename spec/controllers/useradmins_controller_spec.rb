require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe UseradminsController do

  # This should return the minimal set of attributes required to create a valid
  # Useradmin. As you add validations to Useradmin, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UseradminsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all useradmins as @useradmins" do
      useradmin = Useradmin.create! valid_attributes
      get :index, {}, valid_session
      assigns(:useradmins).should eq([useradmin])
    end
  end

  describe "GET show" do
    it "assigns the requested useradmin as @useradmin" do
      useradmin = Useradmin.create! valid_attributes
      get :show, {:id => useradmin.to_param}, valid_session
      assigns(:useradmin).should eq(useradmin)
    end
  end

  describe "GET new" do
    it "assigns a new useradmin as @useradmin" do
      get :new, {}, valid_session
      assigns(:useradmin).should be_a_new(Useradmin)
    end
  end

  describe "GET edit" do
    it "assigns the requested useradmin as @useradmin" do
      useradmin = Useradmin.create! valid_attributes
      get :edit, {:id => useradmin.to_param}, valid_session
      assigns(:useradmin).should eq(useradmin)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Useradmin" do
        expect {
          post :create, {:useradmin => valid_attributes}, valid_session
        }.to change(Useradmin, :count).by(1)
      end

      it "assigns a newly created useradmin as @useradmin" do
        post :create, {:useradmin => valid_attributes}, valid_session
        assigns(:useradmin).should be_a(Useradmin)
        assigns(:useradmin).should be_persisted
      end

      it "redirects to the created useradmin" do
        post :create, {:useradmin => valid_attributes}, valid_session
        response.should redirect_to(Useradmin.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved useradmin as @useradmin" do
        # Trigger the behavior that occurs when invalid params are submitted
        Useradmin.any_instance.stub(:save).and_return(false)
        post :create, {:useradmin => {}}, valid_session
        assigns(:useradmin).should be_a_new(Useradmin)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Useradmin.any_instance.stub(:save).and_return(false)
        post :create, {:useradmin => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested useradmin" do
        useradmin = Useradmin.create! valid_attributes
        # Assuming there are no other useradmins in the database, this
        # specifies that the Useradmin created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Useradmin.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => useradmin.to_param, :useradmin => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested useradmin as @useradmin" do
        useradmin = Useradmin.create! valid_attributes
        put :update, {:id => useradmin.to_param, :useradmin => valid_attributes}, valid_session
        assigns(:useradmin).should eq(useradmin)
      end

      it "redirects to the useradmin" do
        useradmin = Useradmin.create! valid_attributes
        put :update, {:id => useradmin.to_param, :useradmin => valid_attributes}, valid_session
        response.should redirect_to(useradmin)
      end
    end

    describe "with invalid params" do
      it "assigns the useradmin as @useradmin" do
        useradmin = Useradmin.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Useradmin.any_instance.stub(:save).and_return(false)
        put :update, {:id => useradmin.to_param, :useradmin => {}}, valid_session
        assigns(:useradmin).should eq(useradmin)
      end

      it "re-renders the 'edit' template" do
        useradmin = Useradmin.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Useradmin.any_instance.stub(:save).and_return(false)
        put :update, {:id => useradmin.to_param, :useradmin => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested useradmin" do
      useradmin = Useradmin.create! valid_attributes
      expect {
        delete :destroy, {:id => useradmin.to_param}, valid_session
      }.to change(Useradmin, :count).by(-1)
    end

    it "redirects to the useradmins list" do
      useradmin = Useradmin.create! valid_attributes
      delete :destroy, {:id => useradmin.to_param}, valid_session
      response.should redirect_to(useradmins_url)
    end
  end

end
