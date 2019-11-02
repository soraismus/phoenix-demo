alias Assessment.{Accounts,OrderStates,Patients}

[{:ok, _active}, {:ok, _canceled}, {:ok, _delivered}, {:ok, _undeliverable}] =
  Enum.map(
    ~w(active canceled delivered undeliverable)s,
    fn (description) ->
      OrderStates.create_order_state(%{description: description})
    end)

{:ok, _admin} =
  Accounts.create_administrator(%{
    username: "admin",
    administrator: %{
      email: "admin@example.com"
  }})

{:ok, _better_rx} =
  Accounts.create_pharmacy(%{
    username: "better_rx",
    pharmacy: %{
      name: "BetterRx",
      address: "1275 Kinnear Road, Columbus, OH 43212",
      email: "admin@betterrx.com",
  }})

{:ok, _best_rx} =
  Accounts.create_pharmacy(%{
    username: "best_rx",
    pharmacy: %{
      name: "BestRx",
      address: "123 Austin St., Austin, TX 78702",
      email: "admin@bestrx.com",
  }})

{:ok, _drugsrus} =
  Accounts.create_pharmacy(%{
    username: "drugsrus",
    pharmacy: %{
      name: "Drugs R Us",
      address: "4925 LA Ave., Los Angeles, CA 90056",
      email: "admin@drugsrus.com",
  }})

{:ok, _same_day_delivery} =
  Accounts.create_courier(%{
    username: "same_day_delivery",
    courier: %{
      name: "Same Day Delivery",
      address: "900 Trenton Lane, Trenton, NJ 08536",
      email: "admin@samedaydelivery.com",
  }})

{:ok, _previous_day_delivery} =
  Accounts.create_courier(%{
    username: "previous_day_delivery",
    courier: %{
      name: "Previous Day Delivery",
      address: "7433 LA Ct., Los Angeles, CA 90056",
      email: "admin@previousdaydelivery.com",
  }})

{:ok, _john_doe} =
  Patients.create_patient(%{
    name: "John Doe",
    address: "123 Mockingbird Ln., Anywhere, DE 00000"
  })
