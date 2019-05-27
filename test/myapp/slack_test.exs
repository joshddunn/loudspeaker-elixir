defmodule Myapp.SlackTest do
  use Myapp.DataCase

  alias Myapp.Slack

  describe "users" do
    alias Myapp.Slack.User

    @valid_attrs %{account_id: "some account_id", jti: "some jti", name: "some name"}
    @update_attrs %{account_id: "some updated account_id", jti: "some updated jti", name: "some updated name"}
    @invalid_attrs %{account_id: nil, jti: nil, name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Slack.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Slack.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Slack.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Slack.create_user(@valid_attrs)
      assert user.account_id == "some account_id"
      assert user.jti == "some jti"
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Slack.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Slack.update_user(user, @update_attrs)
      assert user.account_id == "some updated account_id"
      assert user.jti == "some updated jti"
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Slack.update_user(user, @invalid_attrs)
      assert user == Slack.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Slack.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Slack.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Slack.change_user(user)
    end
  end
end
