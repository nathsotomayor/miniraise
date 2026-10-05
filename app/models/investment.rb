class Investment < ApplicationRecord
  # The domain must end in a dot and a 2+ letter TLD, so "nath@mail" is rejected
  # while "nath@mail.com" is accepted. This runs on top of URI::MailTo::EMAIL_REGEXP
  # (which enforces the rest of the address), not instead of it.
  EMAIL_DOMAIN_FORMAT = /@[^@\s]+\.[a-z]{2,}\z/i

  belongs_to :offering

  normalizes :investor_email, with: ->(email) { email.strip.downcase }

  validates :investor_name, presence: true
  validates :investor_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :investor_email, format: { with: EMAIL_DOMAIN_FORMAT, allow_blank: true, message: "must include a domain name like example.com" }
  validates :amount_cents, numericality: { only_integer: true }
  validate :amount_meets_minimum

  private

  def amount_meets_minimum
    return unless offering && amount_cents.is_a?(Integer)
    return if amount_cents >= offering.min_investment_cents

    errors.add(:amount_cents, "must be at least #{format("%.2f", offering.min_investment_cents / 100.0)}")
  end
end
