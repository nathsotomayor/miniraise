class Investment < ApplicationRecord
  belongs_to :offering

  normalizes :investor_email, with: ->(email) { email.strip.downcase }

  validates :investor_name, presence: true
  validates :investor_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :amount_cents, numericality: { only_integer: true }
  validate :amount_meets_minimum

  private

  def amount_meets_minimum
    return unless offering && amount_cents.is_a?(Integer)
    return if amount_cents >= offering.min_investment_cents

    errors.add(:amount_cents, "must be at least #{format("%.2f", offering.min_investment_cents / 100.0)}")
  end
end
