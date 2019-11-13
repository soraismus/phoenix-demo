defmodule AssessmentWeb.Api.OrderControllerTest do
  use AssessmentWeb.Api.ConnCase

  import Assessment.DataCase, only: [json_equiv?: 2]
  import AssessmentWeb.Api.ConnCase,
    only: [ add_administrator: 1,
            add_courier: 1,
            add_order: 1,
            add_patient: 1,
            add_pharmacy: 1,
            log_in_admin: 1,
          ]

  @base_attrs %{ "order_state" => "active",
                 "pickup_date" => "2010-04-17",
                 "pickup_time" => "14:00",
                }

  @update_attrs %{pickup_date: "2011-05-18", pickup_time: "15:01"}

  describe "index" do
    setup [:add_administrator, :log_in_admin, :add_order, :add_order]

    test "lists all orders", %{conn: conn, orders: orders} do
      response = get conn, api_order_path(conn, :index, order_state: "all", pickup_date: "all")
      json = json_response(response, 200)
      assert json_equiv?(json["orders"], orders)
    end
  end

  describe "show order" do
    setup [:add_administrator, :log_in_admin, :add_order]

    test "renders a order when the id is valid" , %{conn: conn, orders: orders} do
      order = List.first(orders)
      response1 = get conn, api_order_path(conn, :show, order)
      json = json_response(response1, 200)
      assert json_equiv?(json["order"], order)
    end
  end

  describe "create order" do
    setup [ :add_administrator,
            :log_in_admin,
            :add_courier,
            :add_patient,
            :add_pharmacy,
            :add_order,
          ]

    test "creates and renders a order when the data is valid", %{conn: conn} = params do
      %{courier: courier, patient: patient, pharmacy: pharmacy} = params

      attrs =
        @base_attrs
        |> Enum.into(%{ "courier_id" => courier.id,
                        "patient_id" => patient.id,
                        "pharmacy_id" => pharmacy.id,
                      })

      response0 = post conn, api_order_path(conn, :create), order: attrs
      json = json_response(response0, :created)
      created = json["created"]["order"]
      created_id = created["id"]

      template =
        @base_attrs
        |> Enum.into(%{ "id" => created_id,
                        "courier" => courier,
                        "patient" => patient,
                        "pharmacy" => pharmacy,
                      })

      assert json_equiv?(created, template)

      response1 = get conn, api_order_path(conn, :show, created_id)
      json = json_response(response1, 200)
      assert json_equiv?(json["order"], template)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{}
      response = post conn, api_order_path(conn, :create), order: invalid_attrs
      json_response(response, 400)
    end
  end
end
