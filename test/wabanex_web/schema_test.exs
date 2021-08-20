defmodule WabanexWeb.SchemaTest do
  use WabanexWeb.ConnCase, async: true

  alias Wabanex.User
  alias Wabanex.Users.Create

  describe "users queries" do
    test "when a valid id is given, returns the user", %{conn: conn} do
      params = %{name: "Rafael", email: "rafael@banana.com", password: "banana"}

      {:ok, %User{id: user_id}} = Create.call(params)

      query = """
        {
          getUser(id: "#{user_id}"){
            id
            name
            email
          }
        }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(:ok)

      expected_response = %{
        "data" => %{
          "getUser" => %{
            "email" => "rafael@banana.com",
            "id" => "#{user_id}",
            "name" => "Rafael"
          }
        }
      }

      assert response == expected_response
    end

    test "when a invalid id is given, returns an error", %{conn: conn} do
      # params = %{name: "Rafael", email: "rafael@banana.com", password: "banana"}

      # {:ok, %User{id: user_id}} = Create.call(params)

      query = """
        {
          getUser(id: "9a55da3a-eb7c-43d4-bf1a-a2f8be526068"){
            id
            name
            email
          }
        }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(:ok)

      expected_response = %{
        "data" => %{"getUser" => nil},
        "errors" => [
          %{
            "locations" => [%{"column" => 5, "line" => 2}],
            "message" => "User not found",
            "path" => ["getUser"]
          }
        ]
      }

      assert response == expected_response
    end
  end

  describe "users mutations" do
    test "when all params are valid, creates the user", %{conn: conn} do
      mutation = """
        mutation{
          createUser(input: {
            name: "Rafael", email: "rafael@banana.com", password: "banana"
          }){
            id
            name
          }
        }
      """

      response =
        conn
        |> post("/api/graphql", %{query: mutation})
        |> json_response(:ok)

      assert %{"data" => %{"createUser" => %{"id" => _id, "name" => "Rafael"}}} = response
    end
  end
end
