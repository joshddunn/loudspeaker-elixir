defmodule MyappWeb.UserView do
  use MyappWeb, :view
  alias MyappWeb.UserView

  # def render("index.json", %{users: users}) do
  #   %{data: render_many(users, UserView, "user.json")}
  # end

  # def render("show.json", %{user: user}) do
  #   %{data: render_one(user, UserView, "user.json")}
  # end

  # def render("user.json", %{user: user}) do
  #   %{id: user.id,
  #     name: user.name,
  #     account_id: user.account_id,
  #     jti: user.jti}
  # end

  def render("slack.json", %{user: user}) do
    %{ text: "go to this url https://recorder.milkcrates.me/?token=#{user.token}" }
  end

  def render("success.json", %{}) do
    %{ message: "success" }
  end
end
