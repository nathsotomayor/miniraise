<script>
  import { tick } from 'svelte'
  import { formatCents } from '../lib/money.js'

  let { offering, onsuccess } = $props()

  let name = $state('')
  let email = $state('')
  let amount = $state('')

  // Tracks whether a field has been submitted once (enables re-validate-on-input)
  let nameDirty = $state(false)
  let emailDirty = $state(false)
  let amountDirty = $state(false)

  let nameError = $state('')
  let emailError = $state('')
  let amountError = $state('')

  let submitting = $state(false)
  let formMessage = $state('')
  let formMessageKind = $state('') // 'success' | 'error'

  let nameInput, emailInput, amountInput

  let minFormatted = $derived(formatCents(offering.min_investment_cents))

  function validateName() {
    nameError = name.trim() ? '' : 'Enter your name'
  }

  function validateEmail() {
    const trimmed = email.trim()
    if (!trimmed) {
      emailError = 'Enter your email address'
    } else if (!trimmed.includes('@') || trimmed.startsWith('@') || trimmed.endsWith('@')) {
      emailError = 'Enter a valid email address'
    } else {
      emailError = ''
    }
  }

  function validateAmount() {
    const val = parseFloat(amount)
    if (!amount.trim() || isNaN(val) || val <= 0) {
      amountError = 'Enter an amount'
    } else if (Math.round(val * 100) < offering.min_investment_cents) {
      amountError = `Enter at least ${minFormatted}`
    } else {
      amountError = ''
    }
  }

  function focusFirstError() {
    if (nameError) nameInput.focus()
    else if (emailError) emailInput.focus()
    else if (amountError) amountInput.focus()
  }

  async function handleSubmit(e) {
    e.preventDefault()
    if (submitting) return

    formMessage = ''
    formMessageKind = ''

    nameDirty = true
    emailDirty = true
    amountDirty = true
    validateName()
    validateEmail()
    validateAmount()

    if (nameError || emailError || amountError) {
      await tick()
      focusFirstError()
      return
    }

    submitting = true

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content ?? ''

    try {
      const res = await fetch(`/api/offerings/${offering.id}/investments`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          'X-CSRF-Token': csrfToken,
        },
        body: JSON.stringify({
          investment: {
            investor_name: name.trim(),
            investor_email: email.trim(),
            amount_cents: Math.round(parseFloat(amount) * 100),
          },
        }),
      })

      if (res.status === 201) {
        const updated = await res.json()
        name = ''
        email = ''
        amount = ''
        nameDirty = false
        emailDirty = false
        amountDirty = false
        nameError = ''
        emailError = ''
        amountError = ''
        formMessageKind = 'success'
        formMessage = 'Your investment has been submitted. Thank you!'
        onsuccess(updated)
      } else if (res.status === 422) {
        const { errors = {} } = await res.json()
        nameError = errors.investor_name?.[0] ?? ''
        emailError = errors.investor_email?.[0] ?? ''
        amountError = errors.amount_cents?.[0] ?? ''
        if (nameError || emailError || amountError) {
          await tick()
          focusFirstError()
        } else {
          // Server rejected the investment for a reason with no matching field (e.g. a future
          // offering-level rule), so there is no field to blame — show it in the status banner.
          formMessageKind = 'error'
          formMessage = Object.values(errors).flat()[0] ?? 'Could not submit your investment. Please try again.'
        }
      } else {
        throw new Error(`status ${res.status}`)
      }
    } catch {
      formMessageKind = 'error'
      formMessage = 'Something went wrong. Check your connection and try again.'
    } finally {
      submitting = false
    }
  }
</script>

<h2>Make an investment</h2>

<!-- Always in DOM so screen readers announce state changes -->
<p
  class="form-status"
  class:has-content={!!formMessage}
  class:success={formMessageKind === 'success'}
  class:error={formMessageKind === 'error'}
  aria-live="polite"
  aria-atomic="true"
>{formMessage}</p>

<form onsubmit={handleSubmit} novalidate aria-label="Make an investment">
  <div class="field">
    <label for="investor-name">Name</label>
    <input
      id="investor-name"
      type="text"
      autocomplete="name"
      required
      bind:value={name}
      oninput={() => { if (nameDirty) validateName() }}
      aria-describedby={nameError ? 'name-error' : undefined}
      aria-invalid={nameError ? 'true' : undefined}
      bind:this={nameInput}
    />
    {#if nameError}
      <p class="field-error" id="name-error">{nameError}</p>
    {/if}
  </div>

  <div class="field">
    <label for="investor-email">Email</label>
    <input
      id="investor-email"
      type="email"
      autocomplete="email"
      required
      bind:value={email}
      oninput={() => { if (emailDirty) validateEmail() }}
      aria-describedby={emailError ? 'email-error' : undefined}
      aria-invalid={emailError ? 'true' : undefined}
      bind:this={emailInput}
    />
    {#if emailError}
      <p class="field-error" id="email-error">{emailError}</p>
    {/if}
  </div>

  <div class="field">
    <label for="investment-amount">Amount (USD)</label>
    <input
      id="investment-amount"
      type="text"
      inputmode="decimal"
      autocomplete="off"
      required
      bind:value={amount}
      oninput={() => { if (amountDirty) validateAmount() }}
      aria-describedby={amountError ? 'amount-error' : 'amount-hint'}
      aria-invalid={amountError ? 'true' : undefined}
      bind:this={amountInput}
    />
    {#if amountError}
      <p class="field-error" id="amount-error">{amountError}</p>
    {:else}
      <p class="field-hint" id="amount-hint">Minimum {minFormatted}</p>
    {/if}
  </div>

  <button type="submit" disabled={submitting}>
    {submitting ? 'Investing…' : 'Invest'}
  </button>
</form>

<style>
  h2 {
    margin: var(--space-8) 0 0;
    font-size: var(--font-size-lg);
    font-weight: 600;
    line-height: var(--line-height-tight);
  }

  .form-status {
    margin: 0;
  }

  .form-status.has-content {
    margin-top: var(--space-4);
  }

  .form-status.success {
    color: var(--color-success);
  }

  .form-status.error {
    color: var(--color-error);
  }

  form {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
    margin-top: var(--space-6);
  }

  .field {
    display: flex;
    flex-direction: column;
    gap: var(--space-1);
  }

  label {
    font-weight: 600;
    font-size: var(--font-size-sm);
  }

  input {
    width: 100%;
    min-height: var(--touch-target-min);
    padding: var(--space-2) var(--space-3);
    font: inherit;
    font-size: var(--font-size-base);
    color: var(--color-text);
    background: var(--color-bg);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    outline: none;
  }

  input:focus-visible {
    border-color: var(--color-accent);
    outline: var(--focus-ring);
    outline-offset: 2px;
  }

  input[aria-invalid='true'] {
    border-color: var(--color-error);
  }

  .field-error {
    margin: 0;
    font-size: var(--font-size-sm);
    color: var(--color-error);
  }

  .field-hint {
    margin: 0;
    font-size: var(--font-size-sm);
    color: var(--color-muted);
  }

  button[type='submit'] {
    min-height: var(--touch-target-min);
    padding: var(--space-2) var(--space-6);
    font: inherit;
    font-weight: 600;
    color: var(--color-on-accent);
    background: var(--color-accent);
    border: 0;
    border-radius: var(--radius-md);
    cursor: pointer;
    align-self: flex-start;
  }

  button[type='submit']:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
</style>
