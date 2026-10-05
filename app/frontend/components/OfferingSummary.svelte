<script>
  import { formatCents } from '../lib/money.js'

  // offering is null while loading; the same layout then shows placeholders.
  let { offering } = $props()

  let percentFunded = $derived(
    offering ? Math.floor((offering.raised_amount_cents / offering.target_amount_cents) * 100) : 0
  )
  let barPercent = $derived(Math.min(percentFunded, 100))
  let investorLabel = $derived(
    offering ? `${offering.investor_count} ${offering.investor_count === 1 ? 'investor' : 'investors'}` : ''
  )
</script>

<div class="summary" aria-hidden={!offering}>
  <p class="raised">
    {#if offering}{formatCents(offering.raised_amount_cents)}{:else}<span class="skeleton" style:width="9ch"></span>{/if}
  </p>
  <p class="muted" id="funding-goal">
    {#if offering}raised of {formatCents(offering.target_amount_cents)} goal{:else}<span class="skeleton" style:width="18ch"></span>{/if}
  </p>

  <div
    class="progress"
    role="progressbar"
    aria-valuemin="0"
    aria-valuemax="100"
    aria-valuenow={barPercent}
    aria-valuetext="{percentFunded}% funded"
    aria-labelledby="funding-goal"
  >
    <div class="progress-fill" style:width="{barPercent}%"></div>
  </div>

  <p class="stats">
    {#if offering}
      <span>{percentFunded}% funded</span>
      <span>{investorLabel}</span>
    {:else}
      <span class="skeleton" style:width="10ch"></span>
      <span class="skeleton" style:width="10ch"></span>
    {/if}
  </p>
</div>

<style>
  .summary {
    margin-top: var(--space-6);
  }

  p {
    margin: 0;
  }

  .raised {
    font-size: var(--font-size-2xl);
    font-weight: 700;
    line-height: var(--line-height-tight);
    font-variant-numeric: tabular-nums;
  }

  .muted {
    color: var(--color-muted);
    font-variant-numeric: tabular-nums;
  }

  .progress {
    height: var(--progress-height);
    margin-top: var(--space-4);
    overflow: hidden;
    background: var(--color-track);
    border-radius: var(--radius-sm);
  }

  .progress-fill {
    height: 100%;
    background: var(--color-accent);
    transition: var(--transition-progress);
  }

  @media (prefers-reduced-motion: reduce) {
    .progress-fill {
      transition: none;
    }
  }

  .stats {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--space-4);
    min-height: 1lh;
    margin-top: var(--space-2);
    font-variant-numeric: tabular-nums;
  }
</style>
