class Offering < ApplicationRecord
  has_many :investments, dependent: :destroy

  validates :name, presence: true
  validates :target_amount_cents, :min_investment_cents, numericality: { only_integer: true, greater_than: 0 }

  def raised_amount_cents
    investments.sum(:amount_cents)
  end

  def investor_count
    investments.distinct.count(:investor_email)
  end

  def summary
    {
      id: id,
      name: name,
      target_amount_cents: target_amount_cents,
      min_investment_cents: min_investment_cents,
      raised_amount_cents: raised_amount_cents,
      investor_count: investor_count
    }
  end
end
