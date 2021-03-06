require 'spec_helper'

describe "campaigns/edit" do
  before(:each) do
    @campaign = assign(:campaign, stub_model(Campaign,
      :name => "MyString",
      :from_name => "MyString",
      :from_email => "MyString",
      :subject => "MyString",
      :email_id => 1
    ))
  end

  it "renders the edit campaign form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => campaigns_path(@campaign), :method => "post" do
      assert_select "input#campaign_name", :name => "campaign[name]"
      assert_select "input#campaign_from_name", :name => "campaign[from_name]"
      assert_select "input#campaign_from_email", :name => "campaign[from_email]"
      assert_select "input#campaign_subject", :name => "campaign[subject]"
      assert_select "input#campaign_email_id", :name => "campaign[email_id]"
    end
  end
end
