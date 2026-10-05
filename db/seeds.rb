# Idempotent: safe to run more than once.
offering = Offering.find_or_create_by!(name: "Solar Kettle Co.") do |record|
  record.target_amount_cents = 50_000_000
  record.min_investment_cents = 10_000
end

[
  [ "Ana Torres", "ana@example.com", 5_000_000 ],
  [ "Bruno Díaz", "bruno@example.com", 4_000_000 ],
  [ "Carla Mendes", "carla@example.com", 2_500_000 ],
  [ "Diego Ruiz", "diego@example.com", 1_000_000 ]
].each do |name, email, amount_cents|
  offering.investments.find_or_create_by!(investor_email: email) do |investment|
    investment.investor_name = name
    investment.amount_cents = amount_cents
  end
end
